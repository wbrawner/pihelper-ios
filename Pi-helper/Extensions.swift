//
//  Extensions.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 11/16/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Pihelper
import SwiftUI
import CryptoKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension String {
    func sha256Hash() -> String? {
        if let data = data(using: .utf8) {
            return SHA256.hash(data: data).hexStr
        } else {
            return nil
        }
    }
}

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }
            .joined()
            .lowercased()
    }
}

extension Status {
    var localizedStringKey: LocalizedStringKey {
        return LocalizedStringKey(self.name)
    }
    
    var foregroundColor: Color {
        switch self {
        case is Enabled:
            return .green
        case is Disabled:
            return .red
        default:
            return .gray
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
