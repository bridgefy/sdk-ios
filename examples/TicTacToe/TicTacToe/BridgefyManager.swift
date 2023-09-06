//
//  BridgefyManager.swift
//  TicTacToe
//
//  Created by Francisco on 09/08/23.
//  Copyright © 2023 Bridgefy Inc. All rights reserved.
//

import Foundation
import BridgefySDK


protocol BridgefyManagerDelegate: AnyObject {
    
    
    func bridgefyDidConnect(with userID: UUID)

    func bridgefyDidDisconnect(from userID: UUID)
    
    func bridgefyDidReceiveData(_ data: Data, with messageID: UUID, using transmissionMode: BridgefySDK.TransmissionMode)
    
}


class BridgefyManager {
    weak var delegate: BridgefyManagerDelegate?
    var bridgefy: Bridgefy?
    static var shared: BridgefyManager = {
        let instance = BridgefyManager()
        return instance
    }()
    
    private init() {}
    
    public func start() throws {
        bridgefy = try Bridgefy(withApiKey: "YOUR-API-KEY",
                                delegate: self,
                                verboseLogging: true)
        bridgefy?.start()
    }
    
    public func  stop() {
        bridgefy?.stop()
        bridgefy = nil
    }
    
}

extension BridgefyManager: BridgefyDelegate {
    func bridgefyDidFailToDestroySession(with error: BridgefySDK.BridgefyError) {}
    
    func bridgefyDidStart(with userId: UUID) {
        print("bridgefyDidStart: \(userId)")
    }
    
    func bridgefyDidDestroySession() {}
    
    func bridgefyDidFailToDestroySession() {}
    
    func bridgefyDidFailToStart(with error: BridgefySDK.BridgefyError) {}
    
    func bridgefyDidStop() {}
    
    func bridgefyDidFailToStop(with error: BridgefySDK.BridgefyError) {}
    
    func bridgefyDidConnect(with userID: UUID) {
        print("bridgefyDidConnect: \(userID)")
        delegate?.bridgefyDidConnect(with: userID)
    }
    
    func bridgefyDidDisconnect(from userID: UUID) {
        delegate?.bridgefyDidDisconnect(from: userID)
    }
    
    func bridgefyDidEstablishSecureConnection(with userId: UUID) {
    }
    
    func bridgefyDidFailToEstablishSecureConnection(with userId: UUID,
                                                    error: BridgefySDK.BridgefyError) {
    }
    
    func bridgefyDidSendMessage(with messageID: UUID) {
    }
    
    func bridgefyDidFailSendingMessage(with messageID: UUID,
                                       withError error: BridgefySDK.BridgefyError) {
    }
    
    func bridgefyDidReceiveData(_ data: Data,
                                with messageID: UUID,
                                using transmissionMode: BridgefySDK.TransmissionMode) {
        delegate?.bridgefyDidReceiveData(data,
                                         with: messageID,
                                         using: transmissionMode)
    }
    
    func bridgefyShouldProcessMessage(withID messageID: UUID) -> Bool {
        return true
    }
}
