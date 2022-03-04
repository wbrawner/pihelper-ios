//
//  PiHoleDetailsView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct PiHoleDetailsView: View {
    @ViewBuilder
    func stateContent() -> some View {
        switch self.dataStore.pihole {
        case .success(let pihole):
            PiHoleActionsView(dataStore: self.dataStore, status: pihole)
        case .loading(let previousStatus):
                if let status = previousStatus {
                    PiHoleActionsView(dataStore: self.dataStore, status: status)
                } else {
                    ActivityIndicatorView()
                }
        case .error(let error):
            switch (error) {
            default:
                PiHoleActionsView(dataStore: self.dataStore, status: .unknown)
            }
        default:
            ActivityIndicatorView()
        }
    }
    
    var body: some View {
        NavigationView {
            stateContent()
                .animation(.default, value: self.dataStore.pihole)
                .navigationBarTitle("Pi-helper")
                .navigationBarItems(trailing: NavigationLink(destination: AboutView(self.dataStore), label: {
                    Image(systemName: "info.circle")
                        .padding()
                }))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            Task {
                await self.dataStore.monitorStatus()
            }
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
                PiholeStatusView(status)
            }
            PiHoleActions(self.dataStore, status: status)
        }
    }
    
    let dataStore: PiHoleDataStore
    let status: Status
}

struct PiholeStatusView: View {
    @ViewBuilder
    var body: some View {
        HStack {
            Text(status.localizedStringKey)
                .foregroundColor(status.foregroundColor)
            if case let .disabled(duration) = status, let durationString = duration {
                Text("(\(durationString))")
                    .monospacedDigit()
                    .foregroundColor(status.foregroundColor)
            }
        }
    }
    
    let status: Status
    init(_ status: Status) {
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
            return Button(action: { Task {
                await self.dataStore.enable()
            } }, label: { Text("enable") })
                .buttonStyle(PiHelperButtonStyle(.green))
                .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                .toAnyView()
        case .enabled:
            return VStack {
                Button(action: { Task {
                    await self.dataStore.disable(10)
                } }, label: { Text("disable_10_sec") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: { Task{
                        await self.dataStore.disable(30)
                } }, label: { Text("disable_30_sec") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: { Task {
                    await self.dataStore.disable(300)
                } }, label: { Text("disable_5_min") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: {
                    self.dataStore.showCustomDisableView = true
                }, label: { Text("disable_custom") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: { Task {
                    await self.dataStore.disable()
                } }, label: { Text("disable_permanent") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                NavigationLink(
                    destination: DisableCustomTimeView(self.dataStore),
                    isActive: self.$dataStore.showCustomDisableView,
                    label: { EmptyView() }
                )
            }.toAnyView()
        default:
            return Text("Unable to load Pi-hole status. Please verify your credentials and ensure the Pi-hole is accessible from your current network.")
                .toAnyView()
        }
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
    let status: Status
    init(_ dataStore: PiHoleDataStore, status: Status) {
        self.dataStore = dataStore
        self.status = status
    }
}

struct PiHoleDetailsView_Previews: PreviewProvider {
    static var dataStore: PiHoleDataStore {
        get {
            let _dataStore = PiHoleDataStore()
            _dataStore.pihole = PiholeStatus.success(Status.disabled("20"))
            return _dataStore
        }
    }
    
    static var previews: some View {
        PiHoleDetailsView(self.dataStore)
    }
}
