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
            _dataStore.pihole = .success(.enabled)
            return _dataStore
        }
    }
    
    static var previews: some View {
        DisableCustomTimeView(self.dataStore)
    }
}
