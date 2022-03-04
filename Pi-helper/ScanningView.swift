//
//  ScanningView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 12/14/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ScanningView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var dataStore: PiHoleDataStore
    
    @ViewBuilder
    var body: some View {
        switch dataStore.pihole {
        case .scanning(let ipAddress):
            ScrollView {
                VStack(spacing: 10) {
                    ActivityIndicatorView()
                    Text("scanning_ip_address")
                    Text(verbatim: ipAddress)
                    Button(action: {
                        self.dataStore.cancelScanning()
                    }, label: { Text("cancel") })
                        .buttonStyle(PiHelperButtonStyle())
                }.padding()
            }
        default:
            EmptyView().onAppear {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
    
struct ScanningView_Previews: PreviewProvider {
    static var dataStore: PiHoleDataStore {
        get {
            let dataStore = PiHoleDataStore()
            dataStore.pihole = .scanning("127.0.0.1")
            return dataStore
        }
    }
    
    static var previews: some View {
        ScanningView(dataStore: self.dataStore)
    }
}
