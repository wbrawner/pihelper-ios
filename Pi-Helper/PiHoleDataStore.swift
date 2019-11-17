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

class PiHoleDataStore: ObservableObject {
    private let IP_MIN = 0
    private let IP_MAX = 255
    private var currentRequest: AnyCancellable? = nil
    @Published var pihole: Result<PiHole, PiHoleError> = .failure(.notConfigured)
    var apiKey: String? = nil {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: PiHoleDataStore.API_KEY)
            apiService.apiKey = apiKey
        }
    }
    var baseUrl: String? = nil {
        didSet {
            let safeHost = prependScheme(baseUrl)
            UserDefaults.standard.set(safeHost, forKey: PiHoleDataStore.HOST_KEY)
            apiService.baseUrl = safeHost
        }
    }
    
    private func prependScheme(_ ipAddress: String?) -> String? {
        guard let host = ipAddress else {
            return nil
        }
        
        if !host.starts(with: "http://") && !host.starts(with: "https://") {
            return "http://" + host
        }
        
        return host
    }
    
    func beginScanning(_ ipAddress: String) {
        var addressParts = ipAddress.split(separator: ".")
        var chunks = 1
        var ipAddresses = [String]()
        while chunks <= IP_MAX {
            let chunkSize = (IP_MAX - IP_MIN + 1) / chunks
            if chunkSize == 1 {
                return
            }
            for chunk in 0..<chunks {
                let chunkStart = IP_MIN + (chunk * chunkSize)
                let chunkEnd = IP_MIN + ((chunk + 1) * chunkSize)
                addressParts[3] = Substring(String(((chunkEnd - chunkStart) / 2) + chunkStart))
                ipAddresses.append(addressParts.joined(separator: "."))
            }
            chunks *= 2
        }
        scan(ipAddresses)
    }
    
    private func scan(_ ipAddresses: [String]) {
        if ipAddresses.isEmpty {
            self.pihole = .failure(.notConfigured)
            return
        }
        
        guard let ipAddress = prependScheme(ipAddresses[0]) else {
            return
        }
        self.apiService.baseUrl = ipAddress
        self.pihole = .failure(.scanning(ipAddress))
        print("Scanning \(ipAddress)")
        currentRequest = self.apiService.getVersion()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    // ignore if timeout, otherwise handle
                    print(error)
                    self.scan(Array(ipAddresses.dropFirst()))
                }
            }, receiveValue: { version in
                // Stop scans, load summary
                self.baseUrl = ipAddress
                self.loadSummary()
            })
    }
    
    func cancelRequest() {
        self.currentRequest?.cancel()
        self.pihole = .failure(.networkError(.cancelled))
    }
    
    func loadSummary() {
        self.pihole = .failure(.networkError(.loading))
        
        currentRequest = apiService.loadSummary()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    // no-op
                    return
                case .failure(let error):
                    self.pihole = .failure(.networkError(error))
                }
            }, receiveValue: { pihole in
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
                self.pihole = .success(pihole)
            })
    }
    
    func enable() {
        let oldPihole = try! pihole.get()
        self.pihole = .failure(.networkError(.loading))
        currentRequest = self.apiService.enable()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    // no-op
                    return
                case .failure(let error):
                    self.pihole = .failure(.networkError(error))
                }
            }, receiveValue: { newStatus in
                self.pihole = .success(oldPihole.copy(status: newStatus.status))
            })
    }
    
    func disable(_ forSeconds: Int? = nil) {
        let oldPihole = try! pihole.get()
        self.pihole = .failure(.networkError(.loading))
        currentRequest = self.apiService.disable(forSeconds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    // no-op
                    return
                case .failure(let error):
                    self.pihole = .failure(.networkError(error))
                }
            }, receiveValue: { newStatus in
                self.pihole = .success(oldPihole.copy(status: newStatus.status))
            })
    }
    
    let apiService = PiHoleApiService()
    static let HOST_KEY = "host"
    static let API_KEY = "apiKey"
}

enum ShortcutAction: String {
    case enable = "EnableAction"
    case disable = "DisableAction"
}

enum PiHoleError : Error {
    case networkError(_ error: NetworkError)
    case scanning(_ ipAddress: String)
    case notConfigured
}
