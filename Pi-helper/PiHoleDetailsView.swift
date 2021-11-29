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
            return PiHoleActionsView(dataStore: self.dataStore, status: pihole).toAnyView()
        case .failure(.loading(let previousStatus)):
                if let status = previousStatus {
                    return PiHoleActionsView(dataStore: self.dataStore, status: status).toAnyView()
                } else {
                    return ActivityIndicatorView(.constant(true)).toAnyView()
                }
        case .failure(.networkError(let error)):
            switch (error) {
            default:
                return PiHoleActionsView(dataStore: self.dataStore, status: .unknown).toAnyView()
            }
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
                PiHoleStatusView(status)
            }
            DurationView(status)
            PiHoleActions(self.dataStore, status: status)
        }
    }
    
    let dataStore: PiHoleDataStore
    let status: PiHoleStatus
}

struct PiHoleStatusView: View {
    var body: some View {
        Text(status.localizedStringKey).foregroundColor(status.foregroundColor)
    }
    
    let status: PiHoleStatus
    init(_ status: PiHoleStatus) {
        self.status = status
    }
}

struct DurationView: View {
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch status {
        case .disabled(let duration):
            if let durationString = duration {
                return HStack {
                    Text("time_remaining")
                    Text(durationString)
                        .frame(minWidth: 30)
                }
                .toAnyView()
            } else {
                return EmptyView().toAnyView()
            }
        default:
            return EmptyView().toAnyView()
        }
    }
    
    let status: PiHoleStatus
    init(_ status: PiHoleStatus) {
        self.status = status
    }
}

struct PiHoleActions: View {
    var body: some View {
        stateContent.padding()
    }
    
    var stateContent: AnyView {
        switch status {
        case .disabled:
            return Button(action: { self.dataStore.enable() }, label: { Text("enable") })
                .buttonStyle(PiHelperButtonStyle(.green))
                .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                .toAnyView()
        case .enabled:
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
                NavigationLink(
                    destination: DisableCustomTimeView(self.dataStore),
                    isActive: .constant(self.dataStore.showCustomDisableView),
                    label: { EmptyView() }
                )
                Button(action: {
                    self.dataStore.showCustomDisableView = true
                }, label: { Text("disable_custom") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
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
    let status: PiHoleStatus
    init(_ dataStore: PiHoleDataStore, status: PiHoleStatus) {
        self.dataStore = dataStore
        self.status = status
    }
}

struct PiHoleDetailsView_Previews: PreviewProvider {
    static var dataStore: PiHoleDataStore {
        get {
            let _dataStore = PiHoleDataStore()
            _dataStore.pihole = .success(.disabled("20"))
            return _dataStore
        }
    }
    
    static var previews: some View {
        PiHoleDetailsView(self.dataStore)
    }
}
