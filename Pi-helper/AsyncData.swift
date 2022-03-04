//
//  AsyncData.swift
//  Pi-helper
//
//  Created by William Brawner on 1/2/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

enum AsyncData<Data>: Equatable where Data: Equatable {
    case empty
    case loading
    case error(Error)
    case success(Data)
    
    var value: Data? {
        get {
            if case let .success(data) = self {
                return data
            } else {
                return nil
            }
        }
        set {}
    }
    
    var error: Error? {
        get {
            if case let .error(error) = self {
                return error
            } else {
                return nil
            }
        }
        set {}
    }
    
    static func == (lhs: AsyncData, rhs: AsyncData) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.loading, .loading):
            return true
        case (.error(let lError), .error(let rError)):
            return rError.localizedDescription == lError.localizedDescription
        case (.success(let lData), .success(let rData)):
            return lData == rData
        default:
            return false
        }
    }
}
