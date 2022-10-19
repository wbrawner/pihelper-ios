//
//  ScanningView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 12/14/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Pihelper
import SwiftUI

struct ScanningView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: PihelperStore
    
    @ViewBuilder
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ActivityIndicatorView()
                Text("scanning_ip_address")
                if let ipAddress = store.state.scanning {
                    Text(verbatim: ipAddress)
                }
                Button(action: {
                    self.store.dispatch(ActionBack())
                }, label: { Text("cancel") })
                .buttonStyle(PiHelperButtonStyle())
            }.padding()
        }
        .onDisappear {
            store.dispatch(ActionBack())
        }
    }
}
    
struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView()
    }
}
