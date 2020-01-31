//
//  PiHoleDetailsView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct PiHoleDetailsView: View {
    var stateContent: AnyView {
        switch self.dataStore.pihole {
        case .success(let pihole):
            return PiHoleActionsView(dataStore: self.dataStore, pihole: pihole).toAnyView()
        case .failure(.networkError(let possiblePihole, _)):
            guard let pihole = possiblePihole else {
                return ActivityIndicatorView(.constant(true)).toAnyView()
            }
            return PiHoleActionsView(dataStore: self.dataStore, pihole: pihole).toAnyView()
        default:
            return ActivityIndicatorView(.constant(true)).toAnyView()
        }
    }
    
    var body: some View {
        NavigationView {
            stateContent
                .navigationBarTitle("PiHelper")
                .navigationBarItems(trailing: NavigationLink(destination: AboutView(self.dataStore), label: {
                    Image(systemName: "info.circle")
                        .padding()
                }))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.dataStore.monitorStatus()
        }
        .onDisappear {
            self.dataStore.stopMonitoring()
        }
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
    init(_ dataStore: PiHoleDataStore) {
        self.dataStore = dataStore
    }
}

struct PiHoleActionsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("status")
                PiHoleStatusView(pihole)
            }
            PiHoleActions(self.dataStore, pihole: pihole)
        }
    }
    
    let dataStore: PiHoleDataStore
    let pihole: PiHole
}

struct PiHoleStatusView: View {
    var body: some View {
        Text(localizedStringKey).foregroundColor(foregroundColor)
    }
    
    var localizedStringKey: LocalizedStringKey {
        return LocalizedStringKey(pihole.status)
    }
    
    var foregroundColor: Color {
        switch pihole.status {
        case "enabled":
            return .green
        case "disabled":
            return .red
        default:
            return .gray
        }
    }
    
    let pihole: PiHole
    init(_ pihole: PiHole) {
        self.pihole = pihole
    }
}

struct PiHoleActions: View {
    var body: some View {
        stateContent.padding()
    }
    
    var stateContent: AnyView {
        switch pihole.status {
        case "disabled":
            return Button(action: { self.dataStore.enable() }, label: { Text("enable") })
                .buttonStyle(PiHelperButtonStyle(.green))
                .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                .toAnyView()
        case "enabled":
            return VStack {
                Button(action: { self.dataStore.disable(10) }, label: { Text("disable_10_sec") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: { self.dataStore.disable(30) }, label: { Text("disable_30_sec") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: { self.dataStore.disable(300) }, label: { Text("disable_5_min") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                //                Button(action: { self.dataStore.disable(300) }, label: { Text("disable_custom") })
                //                    .buttonStyle(PiHelperButtonStyle())
                //                    .padding(.horizontal)
                Button(action: { self.dataStore.disable() }, label: { Text("disable_permanent") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
            }.toAnyView()
        default:
            return Text("Unable to load Pi-hole status. Please verify your credentials and ensure the Pi-hole is accessible from your current network.")
                .toAnyView()
        }
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
    let pihole: PiHole
    init(_ dataStore: PiHoleDataStore, pihole: PiHole) {
        self.dataStore = dataStore
        self.pihole = pihole
    }
}

struct PiHoleDetailsView_Previews: PreviewProvider {
    static var dataStore: PiHoleDataStore {
        get {
            let _dataStore = PiHoleDataStore()
            _dataStore.pihole = .success(PiHole(
                domainsBeingBlocked: 0,
                dnsQueriesToday: 0,
                adsBlockedToday: 0,
                adsPercentageToday: 0.0,
                uniqueDomains: 0,
                queriesForwarded: 0,
                clientsEverSeen: 0,
                uniqueClients: 0,
                dnsQueriesAllTypes: 0,
                queriesCached: 0,
                noDataReplies: 0,
                nxDomainReplies: 0,
                cnameReplies: 0,
                ipReplies: 0,
                privacyLevel: 0,
                status: "enabled",
                gravity: Gravity(
                    fileExists: true,
                    absolute: 0,
                    relative: Relative(
                        days: "",
                        hours: "",
                        minutes: ""
                    )
                )
            ))
            return _dataStore
        }
    }
    
    static var previews: some View {
        PiHoleDetailsView(self.dataStore)
    }
}
