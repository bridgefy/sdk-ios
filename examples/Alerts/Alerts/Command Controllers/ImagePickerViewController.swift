//
//  ImagePickerViewController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class ImagePickerViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var image1Button: UIButton!
    @IBOutlet weak var image2Button: UIButton!

    override func viewDidLoad() {
        
        self.image1Button.layer.cornerRadius = 8.0
        self.image2Button.layer.cornerRadius = 8.0
        
        self.image1Button.layer.borderWidth = 1.0
        self.image2Button.layer.borderWidth = 1.0
        
        self.image1Button.layer.borderColor = appTintColor.cgColor
        self.image2Button.layer.borderColor = appTintColor.cgColor
        
        self.image1Button.clipsToBounds = true
        self.image2Button.clipsToBounds = true
        
        self.image1Button.backgroundColor = UIColor.white
        self.image2Button.backgroundColor = UIColor.white
        
        self.image1Button.setTitleColor(appTintColor, for: .normal)
        self.image2Button.setTitleColor(appTintColor, for: .normal)
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func imageButtonPressed(_ sender: Any) {
        let selectedButton = sender as! UIButton
        
        selectedButton.backgroundColor = appTintColor
        selectedButton.setTitleColor(UIColor.white, for: .normal)
        
        if selectedButton == self.image1Button {
            self.image2Button.backgroundColor = UIColor.white
            self.image2Button.setTitleColor(appTintColor, for: .normal)
        } else {
            self.image1Button.backgroundColor = UIColor.white
            self.image1Button.setTitleColor(appTintColor, for: .normal)
        }
        
        var image: UIImage!
        if selectedButton.tag == 0 {
            image = #imageLiteral(resourceName: "map")
        } else {
            image = #imageLiteral(resourceName: "telephone")
        }
        self.imageView.image = image
        
        if (self.tabBarController != nil) {
            let tabBarController = self.tabBarController as! AdminViewTabBarController
            tabBarController.sendCommand(.image, withObject: selectedButton.tag as Any)
        }
    }

}
