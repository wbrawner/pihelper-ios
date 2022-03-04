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
    @State var showScanFailed = false
    @State var showConnectFailed = false
    var hideNavigationBar: Bool {
        get {
            if case .scanning(_) = self.dataStore.pihole {
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
                    ScanButton(dataStore: self.dataStore)
                        .alert(isPresented: self.$showScanFailed, content: {
                            Alert(title: Text("scan_failed"), message: Text("try_direct_connection"), dismissButton: .default(Text("OK"), action: {
                                self.dataStore.pihole = .missingIpAddress
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
                            Task {
                                await self.dataStore.connect(self.ipAddress)
                            }
                        }
                    Button(action: { Task {
                        await self.dataStore.connect(self.ipAddress)
                    } }, label: { Text("connect") })
                        .buttonStyle(PiHelperButtonStyle())
                        .alert(isPresented: self.$showConnectFailed, content: {
                            Alert(title: Text("connection_failed"), message: Text("verify_ip_address"), dismissButton: .default(Text("OK"), action: {
                                self.dataStore.pihole = .missingIpAddress
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
    
    @ObservedObject var dataStore: PiHoleDataStore
    init(_ dataStore: PiHoleDataStore) {
        self.dataStore = dataStore
    }
}

struct ScanButton: View {
    @ObservedObject var dataStore: PiHoleDataStore
    
    var statefulContent: AnyView {
        guard let deviceIpAddress = resolver_get_device_ip() else {
            return Text("no_wireless_connection")
                .multilineTextAlignment(.center)
                .toAnyView()
        }
        
        let ipAddress = String(cString: deviceIpAddress)
        
        return VStack(spacing: 30) {
            Text("scan_for_pihole")
                .multilineTextAlignment(.center)
            Button(action: {
                self.dataStore.scanTask = Task {
                    await self.dataStore.beginScanning(ipAddress)
                }
            }, label: { Text("scan") })
                .buttonStyle(PiHelperButtonStyle())
            NavigationLink(
                destination: ScanningView(dataStore: self.dataStore),
                isActive: $dataStore.isScanning,
                label: { EmptyView() }
            )
            NavigationLink(
                destination: RetrieveApiKeyView(dataStore: self.dataStore),
                isActive: .constant(self.dataStore.pihole == .missingApiKey),
                label: { EmptyView() }
            )
        }.toAnyView()
    }
    
    var body: some View { statefulContent }
}

struct AddPiHoleView_Previews: PreviewProvider {
    static var previews: some View {
        AddPiHoleView(PiHoleDataStore())
    }
}
