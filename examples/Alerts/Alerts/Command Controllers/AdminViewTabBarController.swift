//
//  AdminViewTabBarController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class AdminViewTabBarController: UITabBarController {
    
    public var transmissionManager: TransmissionManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Administrator panel"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func sendCommand(_ command: Command, withObject object: Any?) {
        guard let transmissionManager = self.transmissionManager else{
            return
        }
        transmissionManager.sendCommand(command, withObject: object)
    }
    
}
