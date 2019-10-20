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
        switch self.dataStore.pihole {
        case .success(_):
            return AnyView(PiHoleDetailsView(self.dataStore))
        case .failure(.loading):
            return AnyView(ActivityIndicatorView(.constant(true)))
        default:
            return AnyView(AddPiHoleView(self.dataStore))
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
