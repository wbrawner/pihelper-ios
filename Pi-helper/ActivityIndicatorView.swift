//
//  ActivityIndicatorView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: View {
    @State private var rotation = 0.0
    
    var body: some View {
        Image("logo")
            .resizable()
            .frame(width: 100, height: 100)
            .rotationEffect(.degrees(self.rotation))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: self.rotation)
            .onAppear {
                self.rotation = 360
            }
    }
}

struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView()
    }
}
