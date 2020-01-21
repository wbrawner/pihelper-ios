//
//  ContentView.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/17/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        if self.dataStore.baseUrl?.isEmpty ?? true || self.dataStore.apiKey?.isEmpty ?? true {
            return AddPiHoleView(self.dataStore).toAnyView()
        } else {
            return PiHoleDetailsView(self.dataStore).toAnyView()
        }
    }
    
    @ObservedObject var dataStore: PiHoleDataStore
    init(_ dataStore: PiHoleDataStore) {
        self.dataStore = dataStore
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(PiHoleDataStore())
    }
}
