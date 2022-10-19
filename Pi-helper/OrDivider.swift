//
//  OrDivider.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 12/13/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct OrDivider: View {
    let orientation: Orientation
    
    @ViewBuilder
    var body: some View {
        if orientation == .horizontal {
            HStack {
                Rectangle()
                    .frame(height: 2)
                Text("or")
                Rectangle()
                    .frame(height: 2)
            }
        } else {
            VStack {
                Rectangle()
                    .frame(width: 2)
                Text("or")
                Rectangle()
                    .frame(width: 2)
            }
        }
    }
    
    init(_ orientation: Orientation = .horizontal) {
        self.orientation = orientation
    }
}

enum Orientation {
    case horizontal
    case vertical
}

struct OrDivider_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            OrDivider(.horizontal)
            OrDivider(.vertical)
        }
    }
}
