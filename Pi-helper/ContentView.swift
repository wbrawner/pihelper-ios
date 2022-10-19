//
//  ContentView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/17/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Pihelper
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PihelperStore
    
    @ViewBuilder
    var body: some View {
        if [Route.home, Route.about].contains(self.store.state.route) {
            PiHoleDetailsView()
        } else {
            AddPiHoleView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
