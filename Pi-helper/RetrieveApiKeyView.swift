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
    var showAlert: Bool {
        get {
            if case .invalidCredentials = self.dataStore.error {
                return true
            } else {
                return false
            }
        }
    }
    
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
                    .onSubmit {
                        Task {
                            await self.dataStore.connectWithPassword(self.password)
                        }
                    }
                Button(action: { Task {
                    await self.dataStore.connectWithPassword(self.password)
                } }, label: {
                    Text("connect_with_password")
                })
                    .buttonStyle(PiHelperButtonStyle())
                OrDivider()
                SecureField("prompt_api_key", text: self.$apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        Task {
                            await self.dataStore.connectWithApiKey(self.apiKey)
                        }
                    }
                Button(action: { Task {
                    await self.dataStore.connectWithApiKey(self.apiKey)
                } }, label: {
                    Text("connect_with_api_key")
                })
                    .buttonStyle(PiHelperButtonStyle())
            }
            .padding()
            .keyboardAwarePadding()
            .alert(isPresented: .constant(showAlert), content: {
                Alert(title: Text("connection_failed"), message: Text("verify_credentials"), dismissButton: .default(Text("OK"), action: {
                    self.dataStore.pihole = .missingApiKey
                }))
            })
        }
        .onDisappear {
            self.dataStore.pihole = .missingIpAddress
        }
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
}

struct RetrieveApiKeyView_Previews: PreviewProvider {
    static var previews: some View {
        RetrieveApiKeyView(dataStore: PiHoleDataStore())
    }
}
