//
//  BridgefyViewModel.swift
//  BridgefyLiveActivityExample
//
//  Created by Bridgefy on 05/10/26.
//


import SwiftUI
import Combine
import BridgefySDK

final class BridgefyViewModel: NSObject, ObservableObject, BridgefyDelegate {
    @Published var status = "Stopped"
    @Published var liveActivityStatus = "Not started"
    @Published var peers: [UUID] = []
    private var bridgefy: Bridgefy?

    func start() {
        do {
            bridgefy = try Bridgefy(withApiKey: "YOUR_API_KEY",
                                    delegate: self,
                                    verboseLogging: true)
            // supportsBackgroundScanning: true automatically starts the Live Activity
            bridgefy?.start(withUserId: nil,
                            andPropagationProfile: .standard,
                            supportsBackgroundScanning: true)
            status = "Starting..."
        } catch {
            status = "Error: \(error)"
        }
    }

    func stop() { bridgefy?.stop() }

    func restartLiveActivity() {
        if #available(iOS 26, *) {
            bridgefy?.restartLiveActivity()
        }
    }

    var isLiveActivityActive: Bool {
        if #available(iOS 26, *) { return bridgefy?.isLiveActivityActive ?? false }
        return false
    }

    // MARK: - BridgefyDelegate

    func bridgefyDidStart(with userId: UUID) {
        DispatchQueue.main.async { self.status = "Active" }
    }
    func bridgefyDidFailToStart(with error: BridgefyError) {
        DispatchQueue.main.async { self.status = "Failed to start: \(error)" }
    }
    func bridgefyDidStop() {
        DispatchQueue.main.async { self.status = "Detenido"; self.peers = [] }
    }
    func bridgefyDidConnect(with userId: UUID) {
        DispatchQueue.main.async { self.peers.append(userId) }
    }
    func bridgefyDidDisconnect(from userId: UUID) {
        DispatchQueue.main.async { self.peers.removeAll { $0 == userId } }
    }
    func bridgefyDidReceiveData(_ data: Data, with messageId: UUID,
                                using transmissionMode: TransmissionMode) {}
    func bridgefyDidSendMessage(with messageId: UUID) {}
    func bridgefyDidFailSendingMessage(with messageId: UUID, withError error: BridgefyError) {}
    func bridgefyDidFailToStop(with error: BridgefySDK.BridgefyError) {}
    func bridgefyDidDestroySession() {}
    func bridgefyDidFailToDestroySession(with error: BridgefySDK.BridgefyError) {}
    func bridgefyDidEstablishSecureConnection(with userId: UUID) {}
    func bridgefyDidFailToEstablishSecureConnection(with userId: UUID, error: BridgefySDK.BridgefyError) {}
    // Live Activity (Opcional)
    func bridgefyDidStartLiveActivity() {
        DispatchQueue.main.async { self.liveActivityStatus = "Activa" }
    }
    func bridgefyDidDismissLiveActivity() {
        DispatchQueue.main.async { self.liveActivityStatus = "Descartada por el usuario" }
    }
    func bridgefyDidFailToStartLiveActivity(withError error: Error) {
        DispatchQueue.main.async { self.liveActivityStatus = "Error: \(error.localizedDescription)" }
    }
}
