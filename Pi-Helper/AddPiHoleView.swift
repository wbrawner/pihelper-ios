//
//  AddPiHoleView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct AddPiHoleView: View {
    var statefulContent: AnyView {
        switch self.dataStore.pihole {
        case .failure(let piholeError):
            switch piholeError {
            case .scanning(let ipAddress):
                return ScanningView(dataStore: self.dataStore, ipAddress: ipAddress).toAnyView()
            default:
                return ManuallyAddPiHoleView(dataStore: self.dataStore).toAnyView()
            }
        default:
            return ManuallyAddPiHoleView(dataStore: self.dataStore).toAnyView()
        }
    }
    
    var body: some View {
        statefulContent
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
    init(_ dataStore: PiHoleDataStore) {
        self.dataStore = dataStore
    }
}

struct ManuallyAddPiHoleView: View {
    @State var ipAddress: String = ""
    @State var apiKey: String = ""
    @ObservedObject var dataStore: PiHoleDataStore
    
    var body: some View {
        VStack {
            Text("add_pihole")
            TextField("ip_address", text: $ipAddress)
            SecureField("api_key_optional", text: $apiKey)
            Button(action: {
                self.dataStore.baseUrl = self.ipAddress
                self.dataStore.apiKey = self.apiKey
                self.dataStore.loadSummary()
            }, label: { Text("connect") })
                .padding()
            ScanButton(dataStore: self.dataStore)
        }
        .padding()
    }
}

struct ScanButton: View {
    @ObservedObject var dataStore: PiHoleDataStore
    
    var statefulContent: AnyView {
        if let deviceIpAddress = resolver_get_device_ip() {
            return Button(action: {
                self.dataStore.beginScanning(String(cString: deviceIpAddress))
            }, label: { Text("scan") }).padding().toAnyView()
        } else {
            return EmptyView().toAnyView()
        }
    }
    
    var body: some View { statefulContent }
}

struct ScanningView: View {
    let dataStore: PiHoleDataStore
    let ipAddress: String
    
    var body: some View {
        VStack {
            ActivityIndicatorView(.constant(true))
            Text("scanning_ip_address")
            Text(verbatim: ipAddress)
            Button(action: {
                self.dataStore.cancelRequest()
            }, label: { Text("cancel") }
            )
                .padding()
        }
    }
}

struct AddPiHoleView_Previews: PreviewProvider {
    static var previews: some View {
        AddPiHoleView(PiHoleDataStore())
    }
}
