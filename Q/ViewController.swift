//
//  ViewController.swift
//  Q
//
//  Created by JAM on 09/02/16.
//  Copyright © 2016 JAM. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    let kClientID = "623552e65ea74f4192e6dbe15b3014d5"
    let kCallbackURL = "q-login://callback"
    
    var session:SPTSession!
    var player:SPTAudioStreamingController?
    
    
    @IBOutlet weak var loginSpotify: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var songNameVar = String()
    
    var songArtistVar = String()
    
// ----------------------------------------------------------
// ----------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
// ----------------------------------------------------------
// ----------------------------------------------------------
    
    @IBAction func loginSpotify(sender: AnyObject) {
        let spotifyAuth = SPTAuth.defaultInstance()
        spotifyAuth.clientID = kClientID
        spotifyAuth.redirectURL = NSURL(string: kCallbackURL)
        spotifyAuth.requestedScopes = [SPTAuthStreamingScope]
        
        let spotifyLoginUrl : NSURL = spotifyAuth.loginURL
        
        UIApplication.sharedApplication().openURL(spotifyLoginUrl)
    }
    
// ----------------------------------------------------------
// ----------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var DestViewController : ViewTwo = segue.destinationViewController as! ViewTwo
        
        DestViewController.songNameLabel = self.songNameVar
        DestViewController.songArtistLabel = self.songArtistVar
    }

// ----------------------------------------------------------
// ----------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that kan be recreated
    } 

}



    
    





