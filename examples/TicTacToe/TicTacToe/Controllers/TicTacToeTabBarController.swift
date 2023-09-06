//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

class TicTacToeTabBarController: UITabBarController {
    
    let gameManager: GameManager = GameManager()
    
    override func viewDidLoad() {
        setupTabBar()
    }
    
    private func setupTabBar() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBar.scrollEdgeAppearance = appearance
            tabBar.standardAppearance = appearance
        }
        tabBar.layer.masksToBounds = false
    }

}
