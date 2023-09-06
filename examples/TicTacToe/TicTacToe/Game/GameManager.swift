//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit
import BridgefySDK

let event_key = "event"
let content_key = "content"
let nick_key = "nick"
let status_key = "status"
let matchid_key = "mid"
let participants_key = "participants"
let board_key = "board"
let sequence_key = "seq"
let already_playing_key = "already_playing"
let x_key = "X"
let o_key = "O"
let uuid_key = "uuid"
let wins_key = "wins"
let winner_key = "winner"
let board_side_size = 3

protocol GameManagerDelegate: AnyObject {
    func gameManager(_ gameManager: GameManager, didDetectPlayerConnection player: Player)
    func gameManager(_ gameManager: GameManager, didDetectPlayerDisconnection player: Player)
    func gameManager(_ gameManager: GameManager, didDetectStatusChange status: PlayerStatus, withPlayer player: Player)
    func gameManager(_ gameManager: GameManager, didAcceptGameWithPlayer player: Player)
    func gameManager(_ gameManager: GameManager, didReceiveOpponentMove opponent: Player)
    func gameManager(_ gameManager: GameManager, didPlayerLeaveGame player: Player)
}

protocol SpectatorDelegate {
    func gameManager(_ gameManager: GameManager, didDetectNewSpectatorGame othersGame: OthersGame)
    func gameManager(_ gameManager: GameManager, didFinishGame othersGame: OthersGame)
    func gameManager(_ gameManager: GameManager, didDetectMoveInSpectatorGame othersGame: OthersGame)
}

class GameManager: NSObject, Game, ActiveGame {
    var delegate: GameManagerDelegate?
    var spectatorDelegate: SpectatorDelegate?
    var players: [Player]
    var othersGames : [OthersGame]
    var username: String
    var currentStatus: PlayerStatus
    
    fileprivate (set) var isOnMatch: Bool
    fileprivate (set) var currentMatchID: String?
    fileprivate (set) var currentOpponent: Player?
    fileprivate (set) var currentSymbol: TTTSymbol!
    fileprivate (set) var matchSequence: Int
    fileprivate (set) var wins: Int
    fileprivate (set) var loses: Int
    fileprivate (set) var started: Bool
    
    fileprivate var _isLocalTurn: Bool
    fileprivate (set) var _boardState: [[TTTSymbol]]!
    fileprivate (set) var _lastMatchState: MatchState
    
    var connectedPlayers: [Player] {
        get {
            return players.filter{ $0.playerStatus !=  PlayerStatus.NoAvailable }
        }
    }
    
    override init() {
        players = []
        othersGames = []
        username = ""
        currentStatus = .NoAvailable
        _isLocalTurn = false
        isOnMatch = false
        matchSequence = 0
        wins = 0
        loses = 0
        _lastMatchState = .mustContinue
        started = false
        super.init()
    }
    
    func start(withUsername username: String) {
        if started {
            return
        }
        started = true
        self.username = username
        currentStatus = .Available
        try? BridgefyManager.shared.start()
        BridgefyManager.shared.delegate = self
    }
    
    func stop() {
        if !started {
            return
        }
        started = false
        BridgefyManager.shared.stop()
        for player in players {
            if delegate != nil {
                delegate?.gameManager(self, didDetectPlayerDisconnection: player)
            }
        }
        players = []
    }
}

// MARK: - Game logic

extension GameManager {
    
    func startGame(with player:Player) {
        _isLocalTurn = true
        currentMatchID = UUID().uuidString
        currentOpponent = player
        isOnMatch = true
        matchSequence = 0
        currentSymbol = TTTSymbol.cross
        currentStatus = .Occupied
        _lastMatchState = .mustContinue
        resetBoard()
        updateStatus(.Occupied, forPlayer: player)
    }
    
    func acceptGame(from player:Player, withInfo info: [String: Any]) {
        
        _isLocalTurn = true
        currentMatchID = info[matchid_key] as? String
        currentOpponent = player
        isOnMatch = true
        matchSequence = info[sequence_key] as! Int
        currentSymbol = TTTSymbol.ball
        currentStatus = .Occupied
        
        let intBoard = info[board_key] as! [[Int]]
        _boardState = intBoard.map{ $0.map{ TTTSymbol(rawValue: $0)! } }
        player.playerStatus = .Occupied
        _lastMatchState = .mustContinue
        delegate?.gameManager(self, didAcceptGameWithPlayer: player)
    }
    
    func continueGame(withContent content: [String : Any]) {
        _isLocalTurn = true
        let recSequence = content[sequence_key] as! Int
        if matchSequence >= recSequence {
            return
        }
        matchSequence = recSequence
        let intBoard = content[board_key] as! [[Int]]
        _boardState = intBoard.map{ $0.map{ TTTSymbol(rawValue: $0)! } }
        _lastMatchState = checkMatchState()
        if _lastMatchState != .mustContinue {
            updateScores(withResult: _lastMatchState)
        }
        delegate?.gameManager(self, didReceiveOpponentMove: currentOpponent!)
    }
    
    func checkMatchState() -> MatchState {
        var results = [Int](repeating: 0, count: (board_side_size * 2 + 2))
        var emptyPositions = 0
        for (y, rowSymbols) in _boardState.enumerated() {
            for (x, symbol) in rowSymbols.enumerated() {
                let value: Int!
                switch symbol {
                case .cross:
                    value = 1
                case .ball:
                    value = -1
                case .empty:
                    value = 0
                    emptyPositions += 1
                }
                
                results[x] += value
                results[board_side_size + y] += value
                if x == y {
                    results[board_side_size * 2] += value
                }
                
                if (board_side_size - x - 1) == y {
                    results[board_side_size * 2 + 1] += value
                }
                
            }
        }
        
        for result in results {
            if result == board_side_size {
                return .wonX
            } else if result == board_side_size * -1 {
                return .wonO
            }
        }
        
        if emptyPositions == 0 {
            return .tie
        } else {
            return .mustContinue
        }
    }
    
    func clearGame() {
        _isLocalTurn = true
        currentMatchID = UUID().uuidString
        isOnMatch = false
        matchSequence = 0
        currentSymbol = TTTSymbol.empty
        currentStatus = .Available
        currentMatchID = nil
        currentOpponent = nil
        wins = 0
        loses = 0
        resetBoard()
        sendAvailableMessage()
    }
    
    fileprivate func createMovePacket(_ board:[[TTTSymbol]]) -> [String: Any] {
        
        var movePacket: [String: Any] = [:]
        movePacket[matchid_key] = currentMatchID
        
        guard let currentUser =  BridgefyManager.shared.bridgefy?.currentUserId?.uuidString else {
            return [:]
        }
        
        
        let currentPlayer = [uuid_key: currentUser,
                              nick_key: username,
                              wins_key: wins] as [String : Any]
        let opponentPlayer = [uuid_key: currentOpponent!.identifier,
                              nick_key: currentOpponent!.userName,
                              wins_key: loses] as [String : Any]
        
        let x_participant: [String : Any]!
        let o_participant: [String : Any]!
        if currentSymbol == TTTSymbol.cross {
            x_participant = currentPlayer
            o_participant = opponentPlayer
        } else {
            x_participant = opponentPlayer
            o_participant = currentPlayer
        }
        let participants: [String: Any] = [x_key: x_participant as Any, o_key: o_participant as Any]
        movePacket[participants_key] = participants
        movePacket[board_key] = board.map{ $0.map{ $0.rawValue }}
        movePacket[sequence_key] = matchSequence
        if _lastMatchState == .wonX {
            movePacket[winner_key] = 1
        } else if _lastMatchState == .wonO {
            movePacket[winner_key] = 2
        } else if _lastMatchState == .tie {
            movePacket[winner_key] = -1
        }
        
        return movePacket
    }
    
    fileprivate func updateScores(withResult result: MatchState) {
        
        if result == .tie {
            return
        }
        if result == .wonX && currentSymbol == .cross ||
            result == .wonO && currentSymbol == .ball {
            wins += 1
        } else {
            loses += 1
        }
        
    }
    
    func isLocalMove(move: [String: Any]) -> Bool{
        guard let currentUser = BridgefyManager.shared.bridgefy?.currentUserId?.uuidString else {
            return false
        }
        
        let participants = move[participants_key] as! [String: Any]
        let player_x = participants[x_key] as! [String: Any]
        let player_o = participants[o_key] as! [String: Any]
        let player_x_uuid = player_x[uuid_key] as! String
        let player_o_uuid = player_o[uuid_key] as! String
        return player_o_uuid == currentUser  || player_x_uuid == currentUser
    }
    
    func cleanOldOthersGames() -> Bool {
        var indexes = [Int]()
        for (index, othersGame) in othersGames.enumerated() {
            let seconds = othersGame.lastMoveDate.timeIntervalSinceNow * -1
            if seconds > Timeout.match {
                indexes.append(index)
            }
        }
        
        for index in indexes {
            othersGames.remove(at: index)
        }
        
        return indexes.count > 0
    }
}

// MARK: - Message sending

private extension GameManager {
    
    func sendPacket(_ packet:[String: Any],
                    toPlayer player: Player?,
                    withType type: EventType,
                    mode: BridgefySDK.TransmissionMode) {
        
        let packet: [String : Any] = [ event_key: type.rawValue, content_key: packet ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: packet, options: .prettyPrinted)
            _ = try BridgefyManager.shared.bridgefy?.send(jsonData, using: mode)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func sendHandshake(to player: Player) {
        let content: [String: Any] = [ nick_key: username, status_key: currentStatus.rawValue ]
        sendPacket(content,
                   toPlayer: player,
                   withType: .Handhsake,
                   mode: .p2p(userId: UUID(uuidString: player.identifier)!))
    }
    
    func sendMove() {
        guard let currentUser = BridgefyManager.shared.bridgefy?.currentUserId else {
            return
        }
        matchSequence += 1
        sendPacket(createMovePacket(_boardState),
                   toPlayer: nil,
                   withType: .Move,
                   mode: .broadcast(senderId: currentUser))
    }
    
    func sendRejection(to player: Player, withMatch match_id: String, isBusy busy: Bool) {
        guard let currentUser = BridgefyManager.shared.bridgefy?.currentUserId else {
            return
        }
        let content: [String: Any] = [ matchid_key: match_id, already_playing_key: busy ]
        sendPacket(content,
                   toPlayer: nil,
                   withType: .RefuseMatch,
                   mode: .broadcast(senderId: currentUser))
    }
    
    func sendAvailableMessage() {
        guard let currentUser = BridgefyManager.shared.bridgefy?.currentUserId else {
            return
        }
        let content: [String: Any] = [:]
        sendPacket(content,
                   toPlayer: nil,
                   withType: .Available,
                   mode: .broadcast(senderId: currentUser))
    }
}

// MARK: - Received packets processment

private extension GameManager {
    
    func processReceivedPacket(_ packet: [String : Any], fromPlayer player: Player) {
        let eventType: EventType = EventType(rawValue: packet[event_key] as! Int)!
        switch eventType {
        case .Handhsake:
            guard let content = packet[content_key] as? [String : Any] else { return }
            processReceivedHandshake(content, fromPlayer: player)
        case .Available:
            processReceivedAvailableMsg(player)
        case .Move:
            guard let content = packet[content_key] as? [String : Any] else { return }
            processReceivedMovement(content, fromPlayer: player)
        case .RefuseMatch:
            guard let content = packet[content_key] as? [String : Any] else { return }
            processReceivedRefusal(content, fromPlayer: player)
        }
    }
    
    func processReceivedHandshake(_ content: [String : Any], fromPlayer player: Player) {
        player.userName = content[nick_key] as! String
        let maxLen = 7
        if player.userName.count > maxLen {
            let index = player.userName.index(player.userName.startIndex , offsetBy: maxLen)
            player.userName = String(player.userName[..<index])
        }
        let rawStatus = content[status_key] as! Int
        player.playerStatus = PlayerStatus(rawValue: rawStatus)!
        processOthersAvailableMsg(playerId: player.identifier)
        if delegate != nil && !player.connectionNotified{
            player.connectionNotified = true
            delegate?.gameManager(self, didDetectPlayerConnection: player)
        }
    }
    
    func processReceivedMovement(_ content: [String : Any], fromPlayer player: Player) {
        
        if !isLocalMove(move: content) {
            updatePlayersStatus(withMovement: content)
            return
        }
        
        if (currentStatus == .Available) {
            let sequence: Int = content[sequence_key] as! Int
            if sequence > 1 {
                // Should be an expired move
                sendRejection(to: player, withMatch: content[matchid_key] as! String, isBusy: false)
                return
            }
            let alert = UIAlertController(title: "Request",
                                          message: "\(player.userName) wants to play. Do you accept the match?",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Not", style: .default, handler: { action in
                self.sendRejection(to: player, withMatch: content[matchid_key] as! String, isBusy: false)
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.acceptGame(from: player, withInfo: content)
            }))
            let window = UIApplication.shared.windows.last!
            window.rootViewController?.present(alert, animated: true, completion: nil)
            
        } else {
            if (content[matchid_key] as! String) == currentMatchID {
                continueGame(withContent: content)
            } else {
                sendRejection(to: player, withMatch: content[matchid_key] as! String, isBusy: true)
            }
        }
        
    }
    

    
    func processReceivedRefusal(_ content: [String : Any], fromPlayer player: Player) {
        
        let match_id = content[matchid_key] as! String
        
        if currentMatchID == match_id {
            clearGame()
            if delegate != nil {
                delegate?.gameManager(self, didPlayerLeaveGame: player)
            }
        }
        
        let wasBusy = content[already_playing_key] as! Bool
        updatePlayerStatus(forPlayer: player, occupied: wasBusy)
    }
    
    func processReceivedAvailableMsg(_ player: Player) {
        
        updateStatus(.Available, forPlayer: player)
    }
}

// MARK: - Received packets processment (spectators data)

extension GameManager {
    
    func processReceivedSpectatorsPacket(_ packet: [String : Any], fromUser user: String) {
        
        if user == currentOpponent?.identifier {
            // It's the local game
            return
        }
        
        let eventType: EventType = EventType(rawValue: packet[event_key] as! Int)!
        switch eventType {
        case .Available:
            processOthersAvailableMsg(playerId: user)
        case .Move:
            let content = packet[content_key] as! [String : Any]
            processOthersMovement(move: content, sender: user)
        case .RefuseMatch:
            let content = packet[content_key] as! [String : Any]
            processOthersRefusal(matchId: content[matchid_key] as! String)
        default:
            break
            
        }
    }
    
    func processOthersMovement(move: [String: Any], sender: String) {
        if isLocalMove(move: move) {
            // If the movement refers to the local user,
            // is about the local game and should not be 
            // treated as an spectator game
            return
        }
        let gameId = move[matchid_key] as! String
        if let othersGame = (othersGames.filter{ $0.gameId == gameId}.first) {
            let updated = othersGame.update(withMove: move, sender: sender)
            if updated {
                spectatorDelegate?.gameManager(self, didDetectMoveInSpectatorGame: othersGame)
            }
        } else {
            let othersGame = OthersGame(withMove: move, sender: sender)
            othersGames.append(othersGame)
            spectatorDelegate?.gameManager(self, didDetectNewSpectatorGame: othersGame)
        }
    }

    func processOthersRefusal(matchId: String) {
        guard let index = othersGames.firstIndex(where: { $0.gameId == matchId}) else{
            return
        }
        let othersGame = othersGames[index]
        othersGames.remove(at: index)
        spectatorDelegate?.gameManager(self, didFinishGame: othersGame)
    }
    
    func processOthersAvailableMsg(playerId: String) {
        guard let index = othersGames.firstIndex(where: { $0.player1Id ==  playerId || $0.player2Id ==  playerId }) else {
            return
        }
        let othersGame = othersGames[index]
        othersGames.remove(at: index)
        spectatorDelegate?.gameManager(self, didFinishGame: othersGame)
    }
    
}


// MARK: - Status update

private extension GameManager {
    
    func updateStatus(_ status: PlayerStatus, forPlayer player: Player) {
        if player.playerStatus != status {
            player.playerStatus = status
            delegate?.gameManager(self, didDetectStatusChange: player.playerStatus, withPlayer: player)
        }
    }
    
    func updatePlayersStatus(withMovement content: [String: Any]) {
        
        let participants = content[participants_key] as! [String: Any]
        let player_x_dict = participants[x_key] as! [String: Any]
        let player_o_dict = participants[o_key] as! [String: Any]
        let player_x_id = player_x_dict[uuid_key] as! String
        let player_o_id = player_o_dict[uuid_key] as! String
        let player_x: Player? = players.filter{ $0.identifier == player_x_id}.first
        let player_o: Player? = players.filter{ $0.identifier == player_o_id}.first
        
        if player_x != nil {
            updateStatus(.Occupied, forPlayer: player_x!)
        }
        
        if player_o != nil {
            updateStatus(.Occupied, forPlayer: player_o!)
        }
    }
    
    func updatePlayerStatus(forPlayer player: Player, occupied busy: Bool) {
        let status: PlayerStatus!
        if busy {
            status = PlayerStatus.Occupied
        } else {
            status = PlayerStatus.Available
        }
        updateStatus(status, forPlayer: player)
    }
}

// MARK: - Game Delegate

extension GameManager {
    
    var gameId: String {
        return currentMatchID ?? ""
    }
    
    var isLocalTurn: Bool {
        return _isLocalTurn
    }
    var player1Name: String {
        return "You"
    }
    var player2Name: String {
        return currentOpponent?.userName ?? ""
    }
    
    var player1Symbol: TTTSymbol {
        return currentSymbol
    }
    var player2Symbol: TTTSymbol {
        return currentSymbol == TTTSymbol.cross ? TTTSymbol.ball : TTTSymbol.cross
    }
    var player1Wins: Int {
        return wins
    }
    var player2Wins: Int {
        return loses
    }
    var isPlayer1Turn: Bool {
        return _isLocalTurn
    }
    var isPlayer2Turn: Bool {
        return !_isLocalTurn
    }
    var boardState: [[TTTSymbol]] {
        return _boardState
    }
    var lastMatchState: MatchState {
        return _lastMatchState
    }
}

// MARK: Active game delegate

extension GameManager {
    
    func resetBoard() {
        _boardState = []
        let sideSize = 3
        for _ in 0..<sideSize {
            let row = [TTTSymbol](repeating: TTTSymbol.empty, count: sideSize)
            _boardState.append(row)
        }
    }
    
    func endGame() {
        if currentMatchID != nil {
            updateStatus(.Available, forPlayer: currentOpponent!)
            sendRejection(to: currentOpponent!,
                               withMatch: currentMatchID!,
                               isBusy: false)
        }
        clearGame()
    }
    
    func checkIfValidMove(posX x: Int, posY y: Int) -> Bool {
        return _boardState[y][x] == .empty
    }
    
    func playMove(posX x: Int, posY y: Int) {
        _boardState[y][x] = currentSymbol
        _lastMatchState = checkMatchState()
        _isLocalTurn = false
        if _lastMatchState != .mustContinue {
            updateScores(withResult: _lastMatchState)
        }
        sendMove()
        
    }
}

// MARK: - BFTransmitterDelegate

extension GameManager: BridgefyManagerDelegate {

    
    
    func bridgefyDidConnect(with userId: UUID) {
        let player = Player(userId.uuidString)
        players.append(player)
        sendHandshake(to: player)
    }
    
    func bridgefyDidDisconnect(from userId: UUID) {
        guard let index = players.firstIndex(where: { $0.identifier == userId.uuidString}) else {
            return
        }
        let player = players[index]
        players.remove(at: index)
        if delegate != nil {
            delegate?.gameManager(self, didDetectPlayerDisconnection: player)
        }
    }
    
    func bridgefyDidReceiveData(_ data: Data,
                                with messageId: UUID,
                                using transmissionMode: BridgefySDK.TransmissionMode) {
        
        let decoded = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = decoded as? [String: Any] {
            switch transmissionMode {
            case .p2p(let userId):
                processReceivedSpectatorsPacket(dictionary,
                                                fromUser: userId.uuidString)
                guard let player = ( players.filter{ $0.identifier == userId.uuidString}.first ) else {
                    return
                }
                processReceivedPacket(dictionary, fromPlayer: player)
            case .broadcast(let userId):
                processReceivedSpectatorsPacket(dictionary,
                                                fromUser: userId.uuidString)
                guard let player = ( players.filter{ $0.identifier == userId.uuidString}.first ) else {
                    return
                }
                processReceivedPacket(dictionary, fromPlayer: player)
            default: return
            }
        }
    }
}
