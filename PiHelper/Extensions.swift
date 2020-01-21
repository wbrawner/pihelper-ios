//
//  Extensions.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 11/16/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

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
