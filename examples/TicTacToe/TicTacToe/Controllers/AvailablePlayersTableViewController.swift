//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

class AvailablePlayersTableViewController: UITableViewController, GameManagerDelegate, OnboardingViewControllerDelegate {
    var gameManager: GameManager!
    var players: [Player] = []
    var noPlayersView: UIView?
    weak var showingmatchController: MatchViewController?
    
    fileprivate lazy var userName: String? = {
        return UserDefaults.standard.value(forKey: StoredValues.username) as? String
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: APP_RED_COLOR]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: APP_RED_COLOR]
        checkNoPlayersView()
        registerForNotifications()
        
        if !UserDefaults.standard.bool(forKey: "onboarding") {
            let vc = OnboardingViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false)
        } else {
            gameManager = (tabBarController as! TicTacToeTabBarController).gameManager
            gameManager.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "onboarding") {
            presentSetUsername()
        }
    }
    
    private func presentSetUsername() {
        if (userName == nil) {
            parent!.performSegue(withIdentifier: StoryboardSegues.setName, sender: self)
        } else if !gameManager.started {
            gameManager.start(withUsername: userName!)
        }
    }
    
    func didFinishOnboarding() {
        gameManager = (tabBarController as! TicTacToeTabBarController).gameManager
        gameManager.delegate = self
        UserDefaults.standard.set(true, forKey: "onboarding")
        presentedViewController?.dismiss(animated: false) {
            self.presentSetUsername()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkNoPlayersView() {
        if players.count == 0 {
            noPlayersView = Bundle.main.loadNibNamed("EmptyTable", owner: self, options: nil)?.first as? UIView
            tableView.tableHeaderView = noPlayersView
        } else {
            noPlayersView = nil
            tableView.tableHeaderView = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Table view data source

extension AvailablePlayersTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.user, for: indexPath) as! PlayerTableViewCell
        let player = players[indexPath.row]
        cell.configure(withPlayer: player)
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}

// MARK: - Table view delegate

extension AvailablePlayersTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = players[indexPath.row]
        if player.playerStatus == .Available {
            gameManager.startGame(with: player)
            performSegue(withIdentifier: StoryboardSegues.startmatch, sender: gameManager)
        } else {
            let alert = UIAlertController(title: "Alert",
                                          message: "The player is already playing!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
    
// MARK: - Notifications
extension AvailablePlayersTableViewController {
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationNames.userReady),
                                               object: nil,
                                               queue: nil) { (notification) in
                                                self.userName = (notification.userInfo![StoredValues.username] as! String)
                                                self.gameManager.start(withUsername: self.userName!)
        }
    }
}

// MARK: - GameManagerDelegate

extension AvailablePlayersTableViewController {
    func gameManager(_ gameManager: GameManager, didDetectPlayerConnection player: Player) {
        players.append(player)
        checkNoPlayersView()
        tableView.reloadData()
    }
    func gameManager(_ gameManager: GameManager, didDetectPlayerDisconnection player: Player) {
        guard let index = players.firstIndex(of: player) else {
            return
        }
        players.remove(at: index)
        checkNoPlayersView()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func gameManager(_ gameManager: GameManager, didDetectStatusChange status: PlayerStatus, withPlayer player: Player) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func gameManager(_ gameManager: GameManager, didAcceptGameWithPlayer player: Player) {
        performSegue(withIdentifier: StoryboardSegues.startmatch, sender: gameManager)
    }
    
    func gameManager(_ gameManager: GameManager, didReceiveOpponentMove opponent: Player) {
        showingmatchController?.updateState()
    }
    
    func gameManager(_ gameManager: GameManager, didPlayerLeaveGame player: Player) {
        if showingmatchController != nil {
            showingmatchController?.dismiss(animated: true, completion: nil)
            let alert = UIAlertController(title: "The game has ended",
                                          message: "Sorry, your opponent leaved the game",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
    }
}

// MARK: - Segue management
extension AvailablePlayersTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegues.startmatch {
            let navController = segue.destination as! UINavigationController
            let matchController = navController.topViewController  as! MatchViewController
            showingmatchController = matchController
            matchController.game = gameManager
            matchController.activeGame = gameManager
        }
    }
}
