//
//  ViewController.swift
//  Q
//
//  Created by JAM on 09/02/16.
//  Copyright © 2016 JAM. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    // Client & Callback vars
    let kClientID = "623552e65ea74f4192e6dbe15b3014d5"
    let kCallbackURL = "q-login://callback"
    
    // Session & Player vars
    var session:SPTSession!
    var player:SPTAudioStreamingController?
    
    // Outlet vars
    @IBOutlet weak var loginSpotify: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    // Placeholders to be sent to ViewTwo
    var songNameVar = String()
    var songArtistVar = String()
    
// ----------- ViewDidLoad() --------------------------------
// ----------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
// ----------- Spotify login --------------------------------
// ----------------------------------------------------------
    
    @IBAction func loginSpotify(sender: AnyObject) {
        let spotifyAuth = SPTAuth.defaultInstance()
        spotifyAuth.clientID = kClientID
        spotifyAuth.redirectURL = NSURL(string: kCallbackURL)
        spotifyAuth.requestedScopes = [SPTAuthStreamingScope]
        
        let spotifyLoginUrl : NSURL = spotifyAuth.loginURL
        
        UIApplication.sharedApplication().openURL(spotifyLoginUrl)
    }
    
// ------------ Prepare for segue ---------------------------
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



    
    





