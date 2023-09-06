//
//  MainMenuViewController.swift
//  Remote Control
//
//  Created by Danno on 8/21/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    
    @IBOutlet var menuButtons: [UIButton]!
    @IBOutlet weak var remoteMenuButton: UIButton!
    @IBOutlet weak var chatMenuButton: UIButton!
    

    weak var transmissionManager: TransmissionManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.posisionateButtons()
        self.selectButton(button: remoteMenuButton)
        
    }
    
    override func viewWillLayoutSubviews() {
        self.posisionateButtons()
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
                self.selectButton(button: self.chatMenuButton)
            } else if  let commandController = controller as? CommandClientViewController {
                commandController.transmissionManager = self.transmissionManager
                self.selectButton(button: self.remoteMenuButton)
            }
        }
    }
    
    func selectButton(button: UIButton) {
        for menuButton in menuButtons {
            if button == menuButton {
                menuButton.setTitleColor(#colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1), for: .normal)
                menuButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                menuButton.tintColor = #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1)
            } else {
                menuButton.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
                menuButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                menuButton.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        }
    }
    
    func posisionateButtons() {
        var padding: CGFloat = 18.0
        if #available(iOS 11, *) {
            guard let rootView = UIApplication.shared.keyWindow else { return  }
            if rootView.safeAreaInsets.left > 0.0 {
                padding = rootView.safeAreaInsets.left
            }
        }
        for menuButton in menuButtons {
            menuButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: padding, bottom: 0, right: 0)
            menuButton.titleEdgeInsets = menuButton.imageEdgeInsets
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
