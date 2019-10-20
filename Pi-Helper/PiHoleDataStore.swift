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
    var pihole: Result<PiHole, NetworkError> = .failure(.notFound) {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    func loadSummary(_ host: String, apiKey: String? = nil) {
        self.pihole = .failure(.loading)
        
        var safeHost = host
        if !host.starts(with: "http://") || !host.starts(with: "https://") {
            safeHost = "http://" + safeHost
        }
        apiService.baseUrl = safeHost
        apiService.apiKey = apiKey
        _ = apiService.loadSummary()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    // no-op
                    return
                case .failure(let error):
                    self.pihole = .failure(error)
                }
            }, receiveValue: { pihole in
                UserDefaults.standard.set(host, forKey: PiHoleDataStore.HOST_KEY)
                UserDefaults.standard.set(apiKey, forKey: PiHoleDataStore.API_KEY)
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
        self.pihole = .failure(.loading)
        _ = self.apiService.enable()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    // no-op
                    return
                case .failure(let error):
                    self.pihole = .failure(error)
                }
            }, receiveValue: { newStatus in
                self.pihole = .success(oldPihole.copy(status: newStatus.status))
            })
    }
    
    func disable(_ forSeconds: Int? = nil) {
        let oldPihole = try! pihole.get()
        self.pihole = .failure(.loading)
        _ = self.apiService.disable(forSeconds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    // no-op
                    return
                case .failure(let error):
                    self.pihole = .failure(error)
                }
            }, receiveValue: { newStatus in
                self.pihole = .success(oldPihole.copy(status: newStatus.status))
            })
    }
    
    let objectWillChange = ObservableObjectPublisher()
    let apiService = PiHoleApiService()
    static let HOST_KEY = "host"
    static let API_KEY = "apiKey"
    init() {
        if let host = UserDefaults.standard.string(forKey: PiHoleDataStore.HOST_KEY) {
            let apiKey = UserDefaults.standard.string(forKey: PiHoleDataStore.API_KEY)
            loadSummary(host, apiKey: apiKey)
        }
    }
}

enum ShortcutAction: String {
    case enable = "EnableAction"
    case disable = "DisableAction"
}
