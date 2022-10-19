//
//  RetrieveApiKeyView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 11/28/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Pihelper
import SwiftUI

struct RetrieveApiKeyView: View {
    @EnvironmentObject var store: PihelperStore
    @SwiftUI.State var apiKey: String = ""
    @SwiftUI.State var password: String = ""
    
    var showAlert: Bool {
        get {
            if let error = self.store.sideEffect, error is EffectError {
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
//                        self.store.dispatch(ActionAuthenticate(authString: AuthenticationStringPassword(value: password)))
                        // TODO: Fix shared implementation and then use that instead
                        self.store.dispatch(ActionAuthenticate(authString: AuthenticationStringToken(value: password.sha256Hash()?.sha256Hash() ?? "")))
                    }
                Button(action: {
//                    self.store.dispatch(ActionAuthenticate(authString: AuthenticationStringPassword(value: password)))
                    // TODO: Fix shared implementation and then use that instead
                    self.store.dispatch(ActionAuthenticate(authString: AuthenticationStringToken(value: password.sha256Hash()?.sha256Hash() ?? "")))
                }, label: {
                    Text("connect_with_password")
                })
                .buttonStyle(PiHelperButtonStyle())
                OrDivider()
                SecureField("prompt_api_key", text: self.$apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        self.store.dispatch(ActionAuthenticate(authString: AuthenticationStringToken(value: apiKey)))
                    }
                Button(action: {
                    self.store.dispatch(ActionAuthenticate(authString: AuthenticationStringToken(value: apiKey)))
                }, label: {
                    Text("connect_with_api_key")
                })
                .buttonStyle(PiHelperButtonStyle())
            }
            .padding()
            .keyboardAwarePadding()
            .alert(isPresented: .constant(showAlert), content: {
                Alert(title: Text("connection_failed"), message: Text("verify_credentials"), dismissButton: .default(Text("OK"), action: {
                    self.store.sideEffect = nil
                }))
            })
        }
        .onDisappear {
            self.store.dispatch(ActionBack())
        }
    }
}

struct RetrieveApiKeyView_Previews: PreviewProvider {
    static var previews: some View {
        RetrieveApiKeyView()
    }
}
