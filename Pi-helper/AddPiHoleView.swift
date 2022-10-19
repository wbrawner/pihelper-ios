//
//  AddPiHoleView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Pihelper
import SwiftUI

struct AddPiHoleView: View {
    @EnvironmentObject var store: PihelperStore
    @SwiftUI.State var ipAddress: String = ""
    @SwiftUI.State var showScanFailed = false
    @SwiftUI.State var showConnectFailed = false
    var hideNavigationBar: Bool {
        get {
            if case .scan = self.store.state.route {
                return true
            } else {
                return false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Image("logo")
                    ScanButton()
                        .alert(isPresented: self.$showScanFailed, content: {
                            Alert(title: Text("scan_failed"), message: Text("try_direct_connection"), dismissButton: .default(Text("OK"), action: {
                                self.store.sideEffect = nil
                            }))
                        })
                    OrDivider()
                    Text("add_pihole")
                        .multilineTextAlignment(.center)
                    TextField("ip_address", text: $ipAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.default)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .onSubmit {
                            self.store.dispatch(ActionScan(deviceIp: self.ipAddress))
                        }
                    Button(action: { self.store.dispatch(ActionConnect(host: ipAddress))
                    }, label: { Text("connect") })
                        .buttonStyle(PiHelperButtonStyle())
                        .alert(isPresented: self.$showConnectFailed, content: {
                            Alert(title: Text("connection_failed"), message: Text("verify_ip_address"), dismissButton: .default(Text("OK"), action: {
                                self.store.sideEffect = nil
                            }))
                        })
                }
                .padding()
                .keyboardAwarePadding()
            }
            .navigationBarHidden(self.hideNavigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ScanButton: View {
    @EnvironmentObject var store: PihelperStore

    @ViewBuilder
    var body: some View {
        if let deviceIpAddress = resolver_get_device_ip() {
            let ipAddress = String(cString: deviceIpAddress)
            VStack(spacing: 30) {
                Text("scan_for_pihole")
                    .multilineTextAlignment(.center)
                Button(action: {
                    self.store.dispatch(ActionScan(deviceIp: ipAddress))
                }, label: { Text("scan") })
                    .buttonStyle(PiHelperButtonStyle())
                NavigationLink(
                    destination: ScanningView(),
                    isActive: .constant(store.state.route == Route.scan),
                    label: { EmptyView() }
                )
                NavigationLink(
                    destination: RetrieveApiKeyView(),
                    isActive: .constant(store.state.route == Route.auth),
                    label: { EmptyView() }
                )
            }
        } else {
            Text("no_wireless_connection")
                .multilineTextAlignment(.center)
        }
    }
}

struct AddPiHoleView_Previews: PreviewProvider {
    static var previews: some View {
        AddPiHoleView()
    }
}
