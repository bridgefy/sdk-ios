//
//  MainViewController.swift
//  Remote Control
//
//  Created by Danno on 8/22/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class MainViewController: SWRevealViewController {

    fileprivate lazy var transmissionManager: TransmissionManager = {
        return TransmissionManager()
    }()
    
    fileprivate lazy var username: String? = {
        guard let value = UserDefaults.standard.value(forKey: StoredValues.username) as? String else {
            return nil
        }
        return value
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let username = self.username {
            self.startTransmission(withUsername: username)
        } else {
            self.performSegue(withIdentifier: StoryboardSegues.setName, sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            let controller = navController.viewControllers.first!
            if let chatController = controller as? ChatViewController {
                chatController.transmissionManager = self.transmissionManager
            } else if  let commandController = controller as? CommandClientViewController {
                commandController.transmissionManager = self.transmissionManager
            }
        } else if let menuController = segue.destination as? MainMenuViewController {
            menuController.transmissionManager = transmissionManager
        }
    }
    
    func startTransmission(withUsername username: String) {
        self.transmissionManager.username = username
        self.transmissionManager.start()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - Notifications

extension MainViewController {
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationNames.userReady),
                                               object: nil,
                                               queue: nil) { (notification) in
                                                let receivedUsername = (notification.userInfo![StoredValues.username] as! String)
                                                self.username = receivedUsername
                                                self.startTransmission(withUsername: receivedUsername)
        }
    }
}
