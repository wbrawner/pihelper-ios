//
//  PiHoleDetailsView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Pihelper
import SwiftUI

struct PiHoleDetailsView: View {
    @EnvironmentObject var store: PihelperStore
    
    @ViewBuilder
    var stateContent: some View {
        if self.store.state.loading {
            ActivityIndicatorView()
        } else {
            PiHoleActionsView()
        }
    }
    
    var body: some View {
        NavigationView {
            stateContent
                .animation(.default, value: self.store.state.status)
                .navigationBarTitle("Pi-helper")
                .navigationBarItems(trailing: NavigationLink(destination: AboutView(), label: {
                    Image(systemName: "info.circle")
                        .padding()
                }))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PiHoleActionsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("status")
                PiholeStatusView()
            }
            PiHoleActions()
        }
    }
}

struct PiholeStatusView: View {
    @EnvironmentObject var store: PihelperStore

    @ViewBuilder
    var body: some View {
        HStack {
            if let status = store.state.status {
                Text(status.localizedStringKey)
                    .foregroundColor(status.foregroundColor)
                if status is Status.Disabled, let timeRemaining = (status as! Status.Disabled).timeRemaining {
                    Text("(\(timeRemaining))")
                        .monospacedDigit()
                        .foregroundColor(status.foregroundColor)
                }
            }
        }
    }
}

struct PiHoleActions: View {
    @EnvironmentObject var store: PihelperStore
    @SwiftUI.State var showCustomDisable: Bool = false

    var body: some View {
        stateContent.padding()
    }

    @ViewBuilder
    var stateContent: some View {
        switch self.store.state.status {
        case is Pihelper.Status.Disabled:
            Button(action: {
                self.store.dispatch(ActionEnable())
            }, label: { Text("enable") })
                .buttonStyle(PiHelperButtonStyle(.green))
                .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
        case is Pihelper.Status.Enabled:
            VStack {
                Button(action: {
                    self.store.dispatch(ActionDisable(duration: 10))
                }, label: { Text("disable_10_sec") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: {
                    self.store.dispatch(ActionDisable(duration: 30))
                }, label: { Text("disable_30_sec") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: {
                    self.store.dispatch(ActionDisable(duration: 300))
                }, label: { Text("disable_5_min") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: {
                    self.showCustomDisable = true
                }, label: { Text("disable_custom") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                Button(action: {
                    self.store.dispatch(ActionDisable(duration: nil))
                }, label: { Text("disable_permanent") })
                    .buttonStyle(PiHelperButtonStyle())
                    .padding(Edge.Set(arrayLiteral: [.bottom, .top]), 5.0)
                NavigationLink(
                    destination: DisableCustomTimeView(showCustom: self.$showCustomDisable),
                    isActive: self.$showCustomDisable,
                    label: { EmptyView() }
                )
            }
        default:
            Text("Unable to load Pi-hole status. Please verify your credentials and ensure the Pi-hole is accessible from your current network.")
        }
    }
}

struct PiHoleDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PiHoleDetailsView()
    }
}
