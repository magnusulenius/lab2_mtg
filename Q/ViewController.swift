//
//  ViewController.swift
//  new
//
//  Created by Johannes Swenson on 09/02/16.
//  Copyright © 2016 Johannes Swenson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    let kClientID = "623552e65ea74f4192e6dbe15b3014d5"
    let kCallbackURL = "q-login://callback"
    
    var session:SPTSession!
    var player:SPTAudioStreamingController?
    

    @IBOutlet weak var artworkImageView: UIImageView!
    
    @IBOutlet weak var songLength: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var loginSpotify: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAfterFirstLogin", name:"spotifyLoginSuccessful", object: nil)
        
        loginSpotify.hidden = true
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") { // Session availible
            let sessionDataOBJ = sessionObj as! NSData
            
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataOBJ) as! SPTSession
            
            if !session.isValid() {
                SPTAuth.defaultInstance().renewSession(session, callback: { (error: NSError!, renewdsession :SPTSession!) -> Void in
                    if error == nil {
                        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                        userDefaults.setObject(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                        self.session = renewdsession
                        self.playUsingSession(renewdsession)
                    }else {
                        print("error refreshing session")
                    }
                    
                })
            }else{
                print("session valid")
                self.session = session
                playUsingSession(session)
            }
            
        }else{
            loginSpotify.hidden = false
        }
    }
    
    func updateAfterFirstLogin () {
        loginSpotify.hidden = true
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            let sessionDataObj = sessionObj as! NSData
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            playUsingSession(firstTimeSession)
        }
    }
    
    func playUsingSession(sessionObj:SPTSession!){
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self
        }
        
        player?.loginWithSession(sessionObj, callback: { (error : NSError!) -> Void in
            if error != nil {
                print("Enabling playback got error")
                return
            }
            
            SPTRequest.requestItemAtURI(NSURL(string: "spotify:track:6LUGAFpbYVek4rRY0G9dV0"), withSession: sessionObj, callback: { (error : NSError!, trackObj:AnyObject!) -> Void in
                if error != nil {
                    print("Track lookup got error")
                    return
            
                }
                
                let track = trackObj as! SPTTrack
                
                self.player?.playTrackProvider(track, callback: nil)
            
            })
            
        })
    }
    
    
    

    @IBAction func loginSpotify(sender: AnyObject) {
        let spotifyAuth = SPTAuth.defaultInstance()
        spotifyAuth.clientID = kClientID
        spotifyAuth.redirectURL = NSURL(string: kCallbackURL)
        spotifyAuth.requestedScopes = [SPTAuthStreamingScope]
        
        let spotifyLoginUrl : NSURL = spotifyAuth.loginURL
        
        UIApplication.sharedApplication().openURL(spotifyLoginUrl)
    }
    
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if player!.currentTrackURI != nil {
            print("Track changed")
            
            print(trackMetadata["SPTAudioStreamingMetadataTrackName"])
            
            print(trackMetadata[SPTAudioStreamingMetadataTrackURI])
            
            print(trackMetadata["SPTAudioStreamingMetadataArtistName"])
            
            print(trackMetadata["SPTAudioStreamingMetadataAlbumURI"])
            
            songArtist.text = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String
            
            songName.text = trackMetadata["SPTAudioStreamingMetadataTrackName"] as? String
            
            var uri = trackMetadata[SPTAudioStreamingMetadataTrackURI] as! String
            var uri2 = NSURL(string: uri)
            
            SPTTrack.trackWithURI(uri2, session: session, callback: { (error, track) -> Void in
                var URL = track!.album!.largestCover.imageURL
                
                print(URL)
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    //var error2 = NSError()
                    var image = UIImage()
                    let imageData = NSData(contentsOfURL: URL)
                    
                    if (imageData != nil) {
                        dispatch_async(dispatch_get_main_queue()) {
                            image = UIImage(data:imageData!)!
                            
                            self.artworkImageView.image = image
                        }
                    } else {
                        // Set blank image if cover not found
                        self.artworkImageView.image = UIImage(named: "blankart")
                    }
                }
            })
        
        }else {
            print("Nothing to play")
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that kan be recreated
    } 

}



    
    





