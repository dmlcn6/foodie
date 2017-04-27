//
//  LaunchViewController.swift
//  foodieApp
//
//  Created by Mr. Lopez on 4/26/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit
import AVKit
import Foundation
import AVFoundation
import NotificationCenter


class LaunchViewController: UIViewController {

    var splashPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get the launch screen video URL
        if let launchVideoURL = Bundle.main.url(forResource: "launchScreen", withExtension: ".mp4") {
            
            //splash player controls the playback of specific media
            let splashPlayer = AVPlayer.init(url: launchVideoURL)
            splashPlayer.actionAtItemEnd = .none
            splashPlayer.isMuted = true
            
            //Layer can be used as the backing layer for a UIView
            let layer = AVPlayerLayer(player: splashPlayer)
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.zPosition = -1
            
            //set the video frame to the entire view
            layer.frame = view.frame
            view.layer.addSublayer(layer)
            
            //PLAY THAT SHIZZ!!!
            splashPlayer.play()
            
            //get Notification for when video ends
            let notifCenter = NotificationCenter.default
            
            notifCenter.addObserver(self, selector: #selector(LaunchViewController.loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime , object: nil)
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loopVideo() {
        
        //loop THAT SHIZZ!!
        if let player = splashPlayer {
            
            //CCCAAAANN D00000!!!
            player.seek(to: kCMTimeZero)
            player.play()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
