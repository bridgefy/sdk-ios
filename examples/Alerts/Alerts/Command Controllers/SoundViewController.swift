//
//  SoundViewController.swift
//  Remote Control
//
//  Created by Danno on 8/24/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class SoundViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playButton.layer.cornerRadius = 12.0
        self.playButton.layer.borderColor = UIColor.lightGray.cgColor
        self.playButton.layer.borderWidth = 2.0
        self.playButton.imageEdgeInsets = UIEdgeInsets.init(top: 0.0,
                                                            left: 10.0,
                                                            bottom: 0.0,
                                                            right: 0.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendSound(_ sender: Any) {
        self.playButton.isEnabled = false
        self.playLabel.text = "Playing sound on the remote devices, please wait..."
        
        self.perform(#selector(enablePlayButton),
                     with: nil,
                     afterDelay: Sound.length)
        
        if (self.tabBarController != nil) {
            let tabBarController = self.tabBarController as! AdminViewTabBarController
            tabBarController.sendCommand(.sound, withObject: nil)
            self.playButton.alpha = 0.2
        }
    }
    
    @objc func enablePlayButton() {
        self.playButton.isEnabled = true
        self.playButton.alpha = 1.0
        self.playLabel.text = "Press the button to play an alert on the remote devices."
    }
    
}
