//
//  BridgefyManager.swift
//  Remote Control
//
//  Created by Francisco on 17/07/23.
//  Copyright © 2023 Bridgefy Inc. All rights reserved.
//

import UIKit
import BridgefySDK

protocol BridgefyManagerDelegate: AnyObject {
    func didFailBLEIssue()
    func didConnectPlayer(with userId: UUID)
    func didDisconnectPlayer(with userId: UUID)
    func processData(_ data: Data, from user: UUID)
    func bridgefyManagerDidStop()
    func didStart(with userId: UUID)
}

class BridgefyManager {
    weak var delegate: BridgefyManagerDelegate?
    var bridgefy: Bridgefy?
    var currentUserId: UUID? {
        return bridgefy?.currentUserId
    }
    
    static var shared: BridgefyManager = {
        let instance = BridgefyManager()
        return instance
    }()
    
    private init() {}
    
    public func start() {
        do {
            bridgefy = try Bridgefy(withApiKey: "YOUR-API-KEY",
                                    delegate: self,
                                    verboseLogging: true)
            bridgefy?.start()
        } catch {}
        
    }
    
    public func stop() {
        delegate?.bridgefyManagerDidStop()
        bridgefy?.stop()
        bridgefy = nil
    }
    
}

extension BridgefyManager: BridgefyDelegate {
    func bridgefyDidFailToDestroySession(with error: BridgefySDK.BridgefyError) {
        
    }
    
    func bridgefyDidStart(with userId: UUID) {
        print("bridgefyDidStart: \(userId.uuidString)")
        delegate?.didStart(with: userId)
    }
    
    func bridgefyDidFailToStart(with error: BridgefySDK.BridgefyError) {
        print("bridgefyDidFailToStart: \(error)")
        switch error {
        case .BLEPoweredOff, .BLEUsageRestricted, .BLEUsageNotGranted :
            delegate?.didFailBLEIssue()
        default: return
        }
    }
    
    func bridgefyDidStop() {
        print("bridgefyDidStop")
        
    }
    
    func bridgefyDidFailToStop(with error: BridgefySDK.BridgefyError) {
        print("bridgefyDidFailToStart: \(error)")
        delegate?.bridgefyManagerDidStop()
    }
    
    func bridgefyDidDestroySession() {}
    
    func bridgefyDidFailToDestroySession() {}
    
    func bridgefyDidConnect(with userId: UUID) {
        print("bridgefyDidConnect: \(userId.uuidString)")
        delegate?.didConnectPlayer(with: userId)
    }
    
    func bridgefyDidDisconnect(from userId: UUID) {
        print("bridgefyDidDisconnect: \(userId.uuidString)")
        delegate?.didDisconnectPlayer(with: userId)
    }
    
    func bridgefyDidEstablishSecureConnection(with userId: UUID) {
        print("bridgefyDidEstablishSecureConnection: \(userId.uuidString)")
     
    }
    
    func bridgefyDidFailToEstablishSecureConnection(with userId: UUID,
                                                    error: BridgefySDK.BridgefyError) {
        
    }
    
    func bridgefyDidSendMessage(with messageId: UUID) {
        print("bridgefyDidSendMessage")
    }
    
    func bridgefyDidFailSendingMessage(with messageId: UUID,
                                       withError error: BridgefySDK.BridgefyError) {
        
    }
    
    func bridgefyDidReceiveData(_ data: Data,
                                with messageId: UUID,
                                using transmissionMode: BridgefySDK.TransmissionMode) {
        print("bridgefyDidSendMessage")
        switch transmissionMode {
        case .broadcast(let user):
            delegate?.processData(data, from: user)
        case .p2p(_):
            return
        case .mesh(_):
            return
        @unknown default:
            return
        }
    }
}

