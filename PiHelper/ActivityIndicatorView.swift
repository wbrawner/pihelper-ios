//
//  ActivityIndicatorView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: View {
    var isAnimating: Binding<Bool>
    @State private var rotation = 0.0
    
    var body: some View {
        Image("logo")
            .rotationEffect(.degrees(rotation))
            .onAppear {
                return withAnimation(self.isAnimating.wrappedValue ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : Animation.linear) {
                    self.rotation = 360.0
                }
        }
    }
    
    init(_ isAnimating: Binding<Bool>) {
        self.isAnimating = isAnimating
    }
}

struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView(.constant(true))
    }
}
