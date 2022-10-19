//
//  PihelperDataStore.swift
//  Pi-helper
//
//  Created by William Brawner on 10/17/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation
import Pihelper
import SwiftUI

class PihelperStore: ObservableObject {
    @Published public var state: Pihelper.State = State(apiKey: nil, host: nil, status: nil, scanning: nil, loading: false, route: Route.connect, initialRoute: Route.connect)
    @Published public var sideEffect: Effect? {
        didSet {
            print("sideEffect: \(sideEffect)")
        }
    }
    
    let store: Store
    
    var stateWatcher : Closeable?
    var sideEffectWatcher : Closeable?

    init(store: Store) {
        self.store = store
        stateWatcher = self.store.watchState { [weak self] state in
            self?.state = state
        }
        sideEffectWatcher = self.store.watchEffects { [weak self] effect in
            self?.sideEffect = effect
        }
    }
    
    public func dispatch(_ action: Action) {
        store.dispatch(action: action)
    }
    
    deinit {
        stateWatcher?.close()
        sideEffectWatcher?.close()
    }
}
