//
//  DisableCustomTimeView.swift
//  Pi-Helper
//
//  Created by William Brawner on 7/4/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import Pihelper
import SwiftUI

struct DisableCustomTimeView: View {
    @EnvironmentObject var store: PihelperStore
    @Binding var showCustom: Bool
    @SwiftUI.State var duration: String = ""
    @SwiftUI.State var unit: Int = 0
    private let units = ["seconds", "minutes", "hours"]
    
    var body: some View {
        VStack {
            Text("disable_custom")
            TextField("duration", text: $duration)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            Picker("", selection: $unit) {
                ForEach(0 ..< 3) {
                    Text(LocalizedStringKey(self.units[$0])).tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            Button(action: {
                let multiplier = NSDecimalNumber(decimal: pow(60, unit)).intValue
                self.store.dispatch(ActionDisable(duration: KotlinLong(value: Int64((Int(duration) ?? 0) * multiplier))))
                self.showCustom = false
            }, label: { Text(LocalizedStringKey("disable")) })
                .buttonStyle(PiHelperButtonStyle())
        }
        .padding()
        .keyboardAwarePadding()
    }
}

struct DisableCustomTimeView_Previews: PreviewProvider {
    static var previews: some View {
        DisableCustomTimeView(showCustom: .constant(true))
    }
}
