//
//  PiHoleDetailsView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct PiHoleDetailsView: View {
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("status")
                    PiHoleStatusView(self.pihole)
                }
                Divider()
                PiHoleActions(self.dataStore, pihole: self.pihole)
            }.navigationBarTitle("Pi-Helper")
        }
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
    let pihole: PiHole
    init(_ dataStore: PiHoleDataStore) {
        self.dataStore = dataStore
        self.pihole = try! dataStore.pihole.get()
    }
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
        stateContent
    }
    
    var stateContent: AnyView {
        switch pihole.status {
        case "disabled":
            return AnyView(Button(action: { self.dataStore.enable() }, label: { Text("enable") }))
        default:
            return AnyView(VStack {
                Button(action: { self.dataStore.disable(10) }, label: { Text("disable_10_sec") })
                Divider()
                Button(action: { self.dataStore.disable(30) }, label: { Text("disable_30_sec") })
                Divider()
                Button(action: { self.dataStore.disable(300) }, label: { Text("disable_5_min") })
                Divider()
                Button(action: { self.dataStore.disable(300) }, label: { Text("disable_custom") })
                Divider()
                Button(action: { self.dataStore.disable() }, label: { Text("disable_permanent") })
            })
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
    static var previews: some View {
        PiHoleDetailsView(PiHoleDataStore())
    }
}
