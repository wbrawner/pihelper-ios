//
//  DisableCustomTimeView.swift
//  Pi-Helper
//
//  Created by William Brawner on 7/4/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import SwiftUI

struct DisableCustomTimeView: View {
    @State var duration: String = ""
    @State var unit: Int = 0
    private let units = ["seconds", "minutes", "hours"]
    
    var body: some View {
        VStack {
            Text("disable_custom")
            TextField("duration", text: $duration)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            Picker("", selection: $unit) {
                ForEach(0 ..< units.count) {
                    Text(LocalizedStringKey(self.units[$0])).tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            Button(action: {
                self.dataStore.disable(Int(self.duration) ?? 0, unit: self.unit)
            }, label: { Text(LocalizedStringKey("disable")) })
                .buttonStyle(PiHelperButtonStyle())
        }
        .padding()
        .keyboardAwarePadding()
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
    init(_ dataStore: PiHoleDataStore) {
        self.dataStore = dataStore
    }
}

struct DisableCustomTimeView_Previews: PreviewProvider {
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
                        days: 0,
                        hours: 0,
                        minutes: 0
                    )
                )
            ))
            return _dataStore
        }
    }
    
    static var previews: some View {
        DisableCustomTimeView(self.dataStore)
    }
}
