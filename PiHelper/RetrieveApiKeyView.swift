//
//  RetrieveApiKeyView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 11/28/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct RetrieveApiKeyView: View {
    @State var apiKey: String = ""
    @State var password: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Image("logo")
                Text("connection_successful")
                    .multilineTextAlignment(.center)
                Text("instructions_add_api_key")
                    .multilineTextAlignment(.center)
                SecureField("prompt_password", text: self.$password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    self.dataStore.connectWithPassword(self.password)
                }, label: {
                    Text("connect_with_password")
                })
                    .buttonStyle(PiHelperButtonStyle())
                OrDivider()
                SecureField("prompt_api_key", text: self.$apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    self.dataStore.connectWithApiKey(self.apiKey)
                }, label: {
                    Text("connect_with_api_key")
                })
                    .buttonStyle(PiHelperButtonStyle())
            }
            .padding()
            .keyboardAwarePadding()
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onDisappear {
            self.dataStore.pihole = .failure(.missingIpAddress)
        }
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
}

struct RetrieveApiKeyView_Previews: PreviewProvider {
    static var previews: some View {
        RetrieveApiKeyView(dataStore: PiHoleDataStore())
    }
}
