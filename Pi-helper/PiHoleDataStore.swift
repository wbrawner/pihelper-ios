//
//  PiHoleDataStore.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import UIKit
import Pihelper

@MainActor
class PiHoleDataStore: ObservableObject {
    private let IP_MIN = 0
    private let IP_MAX = 255
    var isScanning: Bool {
        get {
            if case .scanning(_) = self.pihole {
                return true
            } else {
                return false
            }
        }
        set {
            // No op
        }
    }
    @Published var showCustomDisableView = false
    @Published var pihole: PiholeStatus = .empty
    @Published var error: PiHoleError? = nil
    @Published var apiKey: String? = nil {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: PiHoleDataStore.API_KEY)
            apiService.apiKey = apiKey
        }
    }
    @Published var baseUrl: String? = nil {
        didSet {
            UserDefaults.standard.set(baseUrl, forKey: PiHoleDataStore.HOST_KEY)
            apiService.baseUrl = baseUrl
        }
    }
    private var shouldMonitorStatus = false
    var scanTask: Task<Any, Error>? = nil
    
    func monitorStatus() async {
        while apiKey != nil && baseUrl != nil && !Task.isCancelled {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                await loadSummary()
            } catch {
                break
            }
        }
    }
        
    func beginScanning(_ ipAddress: String) async {
        var addressParts = ipAddress.split(separator: ".")
        let lastOctal = Int(addressParts[3])
        for octal in 0..<IP_MAX {
            if Task.isCancelled {
                return
            }
            if octal == lastOctal {
                // Don't scan the current device
                continue
            }
            addressParts[3] = Substring(String(octal))
            if await scan(addressParts.joined(separator: ".")) {
                return
            }
        }
        self.error = .scanFailed
    }
    
    func cancelScanning() {
        scanTask?.cancel()
        scanTask = nil
        self.pihole = .missingIpAddress
    }
    
    func connect(_ ipAddress: String) async {
        self.apiService.baseUrl = ipAddress
        do {
            _ = try await self.apiService.getVersion()
            self.baseUrl = ipAddress
            self.pihole = .missingApiKey
        } catch {
            self.error = .connectionFailed(ipAddress)
        }
    }
    
    func scan(_ ipAddress: String) async -> Bool {
        self.pihole = PiholeStatus.scanning(ipAddress)
        do {
            self.apiService.baseUrl = ipAddress
            _ = try await self.apiService.getVersion()
            self.baseUrl = self.apiService.baseUrl
            self.pihole = PiholeStatus.missingApiKey
            return true
        } catch {
            return false
        }
    }
    
    func forgetPihole() {
        self.baseUrl = nil
        self.apiKey = nil
        self.pihole = PiholeStatus.missingIpAddress
    }

    func connectWithPassword(_ password: String) async {
        if let hash = password.sha256Hash()?.sha256Hash() {
            await connectWithApiKey(hash)
        } else {
            self.error = .invalidCredentials
        }
    }
    
    func connectWithApiKey(_ apiToken: String) async {
        self.apiService.apiKey = apiToken
        do {
            _ = try await self.apiService.getTopItems()
            self.apiKey = apiToken
        } catch {
            self.error = .invalidCredentials
        }
    }

    func loadSummary() async {
        var loadingTask: Task<Void, Error>? = nil
        if case let .success(previousState) = self.pihole {
            // Avoid showing the loading spinner immediately
            loadingTask = Task {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                self.pihole = .loading(previousState)
            }
        } else {
            self.pihole = .loading()
        }
        do {
            let pihole = try await apiService.getSummary()
            await MainActor.run {
                UIApplication.shared.shortcutItems = [
                    UIApplicationShortcutItem(
                        type: ShortcutAction.enable.rawValue,
                        localizedTitle: Bundle.main.localizedString(forKey: "enable", value: "Enable", table: nil),
                        localizedSubtitle: nil,
                        icon: UIApplicationShortcutIcon(type: .play),
                        userInfo: nil
                    ),
                    UIApplicationShortcutItem(
                        type: ShortcutAction.disable.rawValue,
                        localizedTitle: Bundle.main.localizedString(forKey: "disable_10_sec", value: "Disable 10 Secs", table: nil),
                        localizedSubtitle: nil,
                        icon: UIApplicationShortcutIcon(type: .pause),
                        userInfo: ["forSeconds": 10 as NSSecureCoding]
                    ),
                    UIApplicationShortcutItem(
                        type: ShortcutAction.disable.rawValue,
                        localizedTitle: Bundle.main.localizedString(forKey: "disable_30_sec", value: "Disable 30 Secs", table: nil),
                        localizedSubtitle: nil,
                        icon: UIApplicationShortcutIcon(type: .pause),
                        userInfo: ["forSeconds": 30 as NSSecureCoding]
                    ),
                    UIApplicationShortcutItem(
                        type: ShortcutAction.disable.rawValue,
                        localizedTitle: Bundle.main.localizedString(forKey: "disable_5_min", value: "Disable 5 Min", table: nil),
                        localizedSubtitle: nil,
                        icon: UIApplicationShortcutIcon(type: .pause),
                        userInfo: ["forSeconds": 300 as NSSecureCoding]
                    )
                ]
            }
            await self.updateStatus(pihole.status.name)
            loadingTask?.cancel()
        } catch {
            if let error = error as? NetworkError {
                self.error = .networkError(error)
            } else {
                print("Unhandled error! \(error)")
            }
        }
    }
    
    func enable() async {
        var previousStatus: Status? = nil
        if case let .success(status) = self.pihole {
            previousStatus = status
        }
        self.pihole = .loading(previousStatus)
        do {
            let status = try await self.apiService.enable()
            await self.updateStatus(status.status.name)
        } catch {
            self.error = .networkError(error as! NetworkError)
        }
    }
    
    func disable(_ forDuration: Int, unit: Int) async {
        let multiplier = NSDecimalNumber(decimal: pow(60, unit)).intValue
        await disable(forDuration * multiplier)
    }
    
    func disable(_ forSeconds: Int? = nil) async {
        var previousStatus: Status? = nil
        if case let .success(status) = self.pihole {
            previousStatus = status
        }
        self.pihole = .loading(previousStatus)
        do {
            var duration: KotlinLong? = nil
            if let seconds = forSeconds {
                duration = KotlinLong(integerLiteral: seconds)
            }
            let status = try await self.apiService.disable(duration: duration)
            await self.updateStatus(status.status.name)
        } catch {
            if let error = error as? NetworkError {
                self.error = .networkError(error)
            }
        }
    }
    
    private func updateStatus(_ status: String) async {
        switch status {
        case "disabled":
            await self.getDisabledDuration()
        default:
            self.pihole = .success(.enabled)
        }
    }
    
    private var customDisableTimeRequest: AnyCancellable? = nil
    
    private func getDisabledDuration() async {
        self.pihole = .success(.disabled())
//        do {
            
//            let timestamp = try await self.apiService.getCustomDisableTimer()
//            let disabledUntil = TimeInterval(round(Double(timestamp) / 1000.0))
//            let now = Date().timeIntervalSince1970
//            if now > disabledUntil {
//                self.pihole = .success(.disabled())
//            } else {
//                self.pihole = .success(.disabled(UInt(disabledUntil - now).toDurationString()))
//            }
//            self.customDisableTimeRequest = nil
//        } catch {
//            self.pihole = .success(.disabled())
//        }
    }
    
    let apiService = PiholeAPIService.companion.create()
    static let HOST_KEY = "host"
    static let API_KEY = "apiKey"
    
    init(baseUrl: String? = nil, apiKey: String? = nil) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        if baseUrl == nil {
            self.pihole = .missingIpAddress
        } else if apiKey == nil {
            self.pihole = .missingApiKey
        } else {
            self.pihole = .loading(nil)
        }
    }
}

enum ShortcutAction: String {
    case enable = "EnableAction"
    case disable = "DisableAction"
}

enum PiholeStatus: Equatable {
    case empty
    case loading(_ previousStatus: Status? = nil)
    case error(_ error: Error)
    case scanning(_ ipAddress: String)
    case missingIpAddress
    case missingApiKey
    case success(_ status: Status)
    
    static func == (lhs: PiholeStatus, rhs: PiholeStatus) -> Bool {
        switch (lhs, rhs) {
        case (.loading(let left), .loading(let right)):
            return left == right
        case (.scanning(let left), .scanning(let right)):
            return left == right
        case (.missingIpAddress, .missingIpAddress):
            return true
        case (.missingApiKey, .missingApiKey):
            return true
        case (.success(let left), .success(let right)):
            return left == right
        default:
            return false
        }
    }
}

enum PiHoleError : Error, Equatable {
    case networkError(_ error: NetworkError)
    case invalidCredentials
    case scanFailed
    case connectionFailed(_ host: String)
    
    static func == (lhs: PiHoleError, rhs: PiHoleError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(let error1), .networkError(let error2)):
            return error1 == error2
        case (.invalidCredentials, .invalidCredentials):
            return true
        case (.scanFailed, .scanFailed):
            return true
        case (.connectionFailed(let lIp), .connectionFailed(let rIp)):
            return lIp == rIp
        default:
            return false
        }
    }
}

extension UInt {
    func toDurationString() -> String {
        // I add one to the timestamp to prevent showing 0 seconds remaining
        if (self < 60) {
            return String(self + 1)
        }
        
        var seconds: UInt = self + 1
        var hours: UInt = 0
        if (seconds >= 3600) {
            hours = seconds / 3600
            seconds -= hours * 3600
        }
        
        var minutes: UInt = 0
        if (seconds >= 60) {
            minutes = seconds / 60
            seconds -= minutes * 60
        }
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
