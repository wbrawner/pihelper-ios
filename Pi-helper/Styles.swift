//
//  Styles.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 12/13/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

struct PiHelperButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var backgroundColorPressed: Color
    var foregroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(10)
            .foregroundColor(foregroundColor)
            .background(configuration.isPressed ? backgroundColor : backgroundColorPressed)
            .cornerRadius(6)
    }
    
    init(_ backgroundColor: Color = .red, backgroundColorPressed: Color? = nil, foregroundColor: Color? = nil) {
        self.backgroundColor = backgroundColor
        if let backgroundColorPressed = backgroundColorPressed {
            self.backgroundColorPressed = backgroundColorPressed
        } else {
            self.backgroundColorPressed = backgroundColor
        }
        if let foregroundColor = foregroundColor {
            self.foregroundColor = foregroundColor
        } else {
            self.foregroundColor = .white
        }
    }
}
