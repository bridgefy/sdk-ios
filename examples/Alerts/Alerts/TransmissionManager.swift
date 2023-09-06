//
//  TransmissionManager.swift
//  Remote Control
//
//  Created by Danno on 8/21/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

let kLastID = "lastId"


public enum Command : Int {
    case image = 1
    case color
    case flashlight
    case text
    case chat
    case sound
}

protocol TransmissionManagerChatDelegate: AnyObject {
    func transmissionManager(_ manager: TransmissionManager, didReceiveMessage message: Message)
    func transmissionManager(_ manager: TransmissionManager, didSendMessage message: Message)
}

protocol TransmissionManagerCommandDelegate: AnyObject {
    func transmissionManager(_ manager: TransmissionManager, didReceiveCommand command: Command, dictionary: [String: Any])
}

class TransmissionManager: NSObject {
    
    weak var chatDelegate: TransmissionManagerChatDelegate?
    weak var commandDelegate: TransmissionManagerCommandDelegate?
    fileprivate(set) var lastCommand: Command?
    fileprivate(set) var lastCommandDictionary: [String: Any]?
    fileprivate(set) var dataController: DataController
    fileprivate(set) var isStarted: Bool
    
    private var currentUserID: UUID?
    
    var username: String = ""{
        didSet {
            self.dataController.username = self.username
        }
    }
    
    public override init() {
        self.dataController = DataController()
        self.isStarted = false
        super.init()
    }
    
    func start() {
        if !self.isStarted {
            self.isStarted = true
            BridgefyManager.shared.start()
            BridgefyManager.shared.delegate = self
        }
    }
    
    func stop() {
        self.isStarted = false
        BridgefyManager.shared.stop()
    }
    
}

// MARK: Data processing

extension TransmissionManager {
    
    fileprivate func processReceived(dict: [String: Any]?) {
        
        guard let dict = dict else {
            return
        }
        guard let command = Command(rawValue: dict[PacketKeys.command] as! Int) else {
            return
        }
        
        if command == Command.chat {
            let content = dict[PacketKeys.content] as! [String: Any]
            self.processReceived(messageDictionary: content)
            
        } else {
            let receivedID = dict[PacketKeys.id] as! Double
            let result = self.updateLastCommand(receivedId: receivedID, command: command, dictionary: dict)
            if result {
                self.commandDelegate?.transmissionManager(self, didReceiveCommand: command, dictionary: dict)
            }
        }
    }
    
    fileprivate func processReceived(messageDictionary: [String: Any]) {
        self.dataController.processReceivedMessage(withDictionary: messageDictionary) { [unowned self] (sucess, message) in
            self.chatDelegate?.transmissionManager(self, didReceiveMessage: message!)
        }
        
    }
    
    func sendCommand(_ command: Command, withObject object: Any?) {
        var dict: [String: Any] = Dictionary.init()
        dict[PacketKeys.id] = floor(Date.init().timeIntervalSince1970 * 1000) as Any
        dict[PacketKeys.command] = command.rawValue
        switch command {
        case .image:
            dict[PacketKeys.image] = object
        case .color:
            dict[PacketKeys.color] = object
        case .text:
            dict[PacketKeys.text] = object
        case .flashlight:
            break
        case .sound:
            break
        default:
            print("ERROR: Unknown sender")
            return
        }
        do {
            guard let currentUserID = currentUserID else {
                return
            }
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let _ = try BridgefyManager.shared.bridgefy?.send(data,
                                                              using: .broadcast(senderId: currentUserID))
            
        } catch let err as NSError {
            print("ERROR: \(err.localizedDescription)")
        }
    }
    
    func sendMessage(text: String) {
        self.dataController.insertOwnMessage(withText: text) { [unowned self] (success, message) in
            self.sendMessage(message: message!)
        }
    }
    
    fileprivate func sendMessage(message: Message) {
        var dictionary = [String: Any]()
        var content = [String: Any]()
        
        content[PacketKeys.text] = message.text!
        let time = UInt64(message.time)
        content[PacketKeys.date] = time
        content[PacketKeys.sender] = message.user!.username
        content[PacketKeys.platform] = message.platform
        dictionary[PacketKeys.command] = Command.chat.rawValue
        dictionary[PacketKeys.content] = content
        
        do {
            guard let currentUserID = currentUserID else {
                return
            }
            
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let _ = try BridgefyManager.shared.bridgefy?.send(data,
                                                              using: .broadcast(senderId: currentUserID))
            
        } catch let err as NSError {
            print("ERROR: \(err.localizedDescription)")
        }
        
    }
    
    func updateLastCommand(receivedId: Double, command: Command, dictionary: [String: Any]) -> Bool {
        let userDefaults = UserDefaults.standard
        
        let savedId = userDefaults.double(forKey: kLastID)
        
        if receivedId > savedId {
            userDefaults.set(receivedId, forKey: kLastID)
            userDefaults.synchronize()
            self.lastCommand = command
            self.lastCommandDictionary = dictionary
            return true
        }
        
        return false
    }
}

// MARK: - BFTransmitterDelegate

extension TransmissionManager: BridgefyManagerDelegate {
    func didFailBLEIssue() {
        
    }
    
    func didConnectPlayer(with userId: UUID) {
        
    }
    
    func didDisconnectPlayer(with userId: UUID) {
        
    }
    
    func processData(_ data: Data, from user: UUID) {
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            self.processReceived(dict: dictionary)
        } catch let error {
            print(error)
        }
    }
    
    func bridgefyManagerDidStop() {
        
    }
    
    func didStart(with userId: UUID) {
        currentUserID = userId
    }

}

