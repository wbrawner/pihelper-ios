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
    
    var stateContent: AnyView {
        switch dataStore.pihole {
        case .failure(.scanning(let ipAddress)):
            return ScrollView {
                VStack(spacing: 10) {
                ActivityIndicatorView(.constant(true))
                Text("scanning_ip_address")
                Text(verbatim: ipAddress)
                Button(action: {
                    self.dataStore.cancelRequest()
                }, label: { Text("cancel") })
                    .buttonStyle(PiHelperButtonStyle())
                }.padding()
        }.toAnyView()
        default:
            self.presentationMode.wrappedValue.dismiss()
            return EmptyView().toAnyView()
        }
    }
    
    var body: some View {
        stateContent
            .onDisappear {
                self.dataStore.cancelRequest()
            }
    }
}

struct ScanningView_Previews: PreviewProvider {
    static var dataStore: PiHoleDataStore {
        get {
            let dataStore = PiHoleDataStore()
            dataStore.pihole = .failure(.scanning("127.0.0.1"))
            return dataStore
        }
    }
    
    static var previews: some View {
        ScanningView(dataStore: self.dataStore)
    }
}
