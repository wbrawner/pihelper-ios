//
//  Extensions.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 11/16/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI
import CryptoKit

extension View {
    func toAnyView() -> AnyView {
        return AnyView(self)
    }
}

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
