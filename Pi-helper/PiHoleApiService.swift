//
//  PiHoleApiService.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

enum NetworkError: Error, Equatable {
    case loading
    case cancelled
    case badRequest
    case notFound
    case unauthorized
    case unknown(Error?)
    case invalidUrl
    case jsonParsingFailed(Error)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.cancelled, .cancelled):
            return true
        case (.badRequest, .badRequest):
            return true
        case (.notFound, .notFound):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.unknown(let error1), .unknown(let error2)):
            return error1?.localizedDescription == error2?.localizedDescription
        case (.invalidUrl, .invalidUrl):
            return true
        case (.jsonParsingFailed(let error1), .jsonParsingFailed(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}
