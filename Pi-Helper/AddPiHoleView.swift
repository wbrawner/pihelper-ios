//
//  AddPiHoleView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct AddPiHoleView: View {
    @State var ipAddress: String = ""
    @State var apiKey: String = ""
    
    var body: some View {
        VStack {
            Text("add_pihole")
            TextField("ip_address", text: $ipAddress)
            SecureField("api_key_optional", text: $apiKey)
            Button(action: { self.dataStore.loadSummary(self.ipAddress, apiKey: self.apiKey) }, label: { Text("connect") })
        }
        .padding()
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
    init(_ dataStore: PiHoleDataStore) {
        self.dataStore = dataStore
    }
}

struct AddPiHoleView_Previews: PreviewProvider {
    static var previews: some View {
        AddPiHoleView(PiHoleDataStore())
    }
}
