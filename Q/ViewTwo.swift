//
//  ViewTwo.swift
//  Q
//
//  Created by Axel Jonsson on 16/02/16.
//  Copyright © 2016 JAM. All rights reserved.
//

import UIKit

class ViewTwo: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    // Outlet vars
    @IBOutlet weak var artworkImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var songArtist: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var logoutBtn: UIButton!
    
    // Placeholder vars to be sent between controllers
    var songNameLabel = String()
    var songArtistLabel = String()
    
    // Client & Callback vars
    let kClientID = "623552e65ea74f4192e6dbe15b3014d5"
    let kCallbackURL = "q-login://callback"
    
    // Session & Player vars
    var session:SPTSession!
    var player:SPTAudioStreamingController!
    
    var trackURI = String()

    // ----------- ViewDidLoad() ------------
    // --------------------------------------
    
    override func viewDidLoad() {
        
        print(trackURI)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAfterFirstLogin", name:"spotifyLoginSuccessful", object: nil)
        
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
                print(songArtistLabel)
                print(songArtist?.text)
                print(songNameLabel)
                print(songName?.text)
                getUserInformation()
            }
            
        }else{

        }
        
    }
    
    // ------ Logout button ------------
    // ------ (Doesn't work) -----------

    @IBAction func logoutSpotify(sender: AnyObject) {

        self.player?.logout({ (error : NSError!) -> Void in
            if error != nil {
                print("Logout error")
                return
            }
            SPTAuth.defaultInstance().session = nil
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.synchronize()
            print("logout complete")
        })
    }
    
    
    // --- Update session -------
    // --------------------------
    
    func updateAfterFirstLogin () {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            let sessionDataObj = sessionObj as! NSData
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            playUsingSession(firstTimeSession)
            getUserInformation()
        }
    }
    

    // --- Initialize player -------
    // -----------------------------
    
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
            
            
            SPTRequest.requestItemAtURI(NSURL(string: self.trackURI), withSession: sessionObj, callback: { (error : NSError!, trackObj:AnyObject!) -> Void in
                if error != nil {
                    print("Track lookup got error")
                    return
                    
                }
                
                let track = trackObj as! SPTTrack
                
                self.player?.playTrackProvider(track, callback: nil)
                
            })
            
        })
    }

    // --- Get metadata from track -------
    // -----------------------------------
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if player!.currentTrackURI != nil {
            
            // Console prints
            print("Track changed")
            print(trackMetadata["SPTAudioStreamingMetadataTrackName"])
            print(trackMetadata[SPTAudioStreamingMetadataTrackURI])
            print(trackMetadata["SPTAudioStreamingMetadataArtistName"])
            print(trackMetadata["SPTAudioStreamingMetadataAlbumURI"])
            
            // Assign trackname/artist to Labels
            songArtist?.text = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String
            songName?.text = trackMetadata["SPTAudioStreamingMetadataTrackName"] as? String
            
            // Assign URI:s for artwork
            var uri = trackMetadata[SPTAudioStreamingMetadataTrackURI] as! String
            var uri2 = NSURL(string: uri)
            
            // Get artwork
            SPTTrack.trackWithURI(uri2, session: session, callback: { (error, track) -> Void in
                var URL = track!.album!.largestCover.imageURL
                
                // Console print URL
                print(URL)

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                    var image = UIImage()
                    let imageData = NSData(contentsOfURL: URL)
                
                    if (imageData != nil) {
                        dispatch_async(dispatch_get_main_queue()) {
                            image = UIImage(data:imageData!)!
                            self.artworkImageView?.image = image
                        }
                    }
                    else {
                    // Set blank image if cover not found
                    self.artworkImageView?.image = UIImage(named: "blankart")
                    }
                }
            })
        }
        else {
            print("Nothing to play")
        }
    }
    
    // --- Get user information -------------------------------
    // --------------------------------------------------------
    
    func getUserInformation () {
        SPTRequest.userInformationForUserInSession(session, callback:  { (error : NSError!, userObj:AnyObject?) -> Void in
          
            if error != nil {
                print("Fetching User information got error")
            }
            
            let user = userObj
            let name = user?.displayName
            let spotifyName = user?.canonicalUserName
            
            // Console prints
            print(user)
            print(name)
            print(spotifyName)
            
            // Check for name
            if (name != "") {
                
                // Assign name to label
                self.userName.text = name
                
                let profile = user?.largestImage
                let profileURL = profile!.imageURL
                
                print(profile)
                print(profileURL)
                
                // Assign profile picture to imageview
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    var profileImage = UIImage()
                    let profileImageData = NSData(contentsOfURL: profileURL)
                    
                    if (profileImageData != nil) {
                        dispatch_async(dispatch_get_main_queue()) {
                            profileImage = UIImage(data:profileImageData!)!
                            self.profileImageView?.image = profileImage
                        }
                    }
                    else {
                        self.profileImageView?.image = UIImage(named: "blankart")
                    }
                }
                
            }else {
                // Assign username to label
                self.userName.text = spotifyName
            }
            
        })

    }

}