//
//  ColorPickerViewController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var sendColorButton: UIButton!
    var pickedColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendColorButton.layer.cornerRadius = 8.0
        self.sendColorButton.clipsToBounds = true
        
        self.updateColor()
        
        self.colorView.layer.borderWidth = 3.0
        self.colorView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func slidersValueChanged(_ sender: Any) {
        self.updateColor()
    }
    
    func updateColor() {
        let redAmount = self.redSlider.value / 255.0
        let greenAmount = self.greenSlider.value / 255.0
        let blueAmount = self.blueSlider.value / 255.0
        
        self.pickedColor = UIColor(red: CGFloat(redAmount),
                                   green: CGFloat(greenAmount),
                                   blue: CGFloat(blueAmount),
                                   alpha: 1.0)
        
        self.colorView.backgroundColor = self.pickedColor
    }
    
    func int(from color:UIColor) -> Int32 {
        let red: Int32 = (Int32(self.redSlider.value) << 16)
        let green: Int32 = (Int32(self.greenSlider.value) << 8)
        let blue: Int32 = Int32(self.blueSlider.value)
        let rgb: Int32 = (Int32(255) << 24) + red + green + blue
        
        return rgb
    }
    
    @IBAction func sendColorButtonPressed(_ sender: Any) {
        print("Color")
        let color = "\(Int(redSlider.value))-\(Int(greenSlider.value))-\(Int(blueSlider.value))"
        print(color)
        
        if (self.tabBarController != nil) {
            let tabBarController = self.tabBarController as! AdminViewTabBarController
            tabBarController.sendCommand(.color,
                                         withObject: color as Any)
        }
    }

}
