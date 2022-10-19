//
//  AboutView.swift
//  Pi-Helper
//
//  Created by William Brawner on 1/26/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import Pihelper
import SwiftUI

struct AboutView: View {
    @EnvironmentObject var store: PihelperStore
    
    var version: String? {
        get {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        }
    }
    var currentYear: String {
        get {
            String(Calendar.current.dateComponents([.year], from: Date()).year ?? 2022)
        }
    }
    var body: some View {
        VStack {
            Image("logo")
            Text("pihelper")
                .font(.title)
            Text("version \(version ?? "")")
                .font(.subheadline)
            Text("copyright \(currentYear)")
                .font(.subheadline)
                .padding(.bottom)
            Button(action: {
                self.store.dispatch(ActionForget())
            }, label: { Text("forget_pihole") })
            .buttonStyle(PiHelperButtonStyle())
        }.padding()
            .onDisappear {
                self.store.dispatch(ActionBack())
            }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
