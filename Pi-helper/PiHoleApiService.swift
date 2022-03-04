//
//  PiHoleApiService.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

class PiHoleApiService {
    let decoder: JSONDecoder
    var baseUrl: String? = nil
    var apiKey: String? = nil
    
    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }
    
    func getVersion() async throws -> VersionResponse {
        return try await get(queries: ["version": ""])
    }
    
    func loadSummary() async throws -> PiHole {
        return try await get()
    }
    
    func enable() async throws -> StatusUpdate {
        return try await get(true, queries: ["enable": ""])
    }
    
    func getTopItems() async throws -> TopItemsResponse {
        return try await get(true, queries: ["topItems": "25"])
    }
    
    func disable(_ forSeconds: Int? = nil) async throws -> StatusUpdate {
        var params = [String: String]()
        if let timeToDisable = forSeconds {
            params["disable"] = String(timeToDisable)
        } else {
            params["disable"] = ""
        }
        return try await get(true, queries: params)
    }
    
    func getCustomDisableTimer() async throws -> UInt {
        guard let baseUrl = self.baseUrl else {
            throw NetworkError.invalidUrl
        }
        guard let url = URL(string: baseUrl + "/custom_disable_timer") else {
            throw NetworkError.invalidUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 0.5
        let (data, res) = try await URLSession.shared.data(for: request)
        guard let response = res as? HTTPURLResponse, 200...299 ~= response.statusCode else {
            switch (res as? HTTPURLResponse)?.statusCode {
            case 400: throw NetworkError.badRequest
            case 401, 403: throw NetworkError.unauthorized
            case 404: throw NetworkError.notFound
            default: throw NetworkError.unknown(nil)
            }
        }
        let dataString = String(data: data, encoding: .utf8) ?? "0"
        return UInt(dataString) ?? 0
    }
    
    private func get<ResultType: Codable>(
        _ requiresAuth: Bool = false,
        queries: [String: String]? = nil
    ) async throws -> ResultType {
        guard let baseUrl = self.baseUrl else {
            throw NetworkError.invalidUrl
        }
        
        var combinedEndPoint = baseUrl + "/admin/api.php"
        
        var modifiedQueries = queries ?? [:]
        if requiresAuth, let apiKey = self.apiKey {
            modifiedQueries["auth"] = apiKey
        }
        for (key, value) in modifiedQueries {
            let separator = combinedEndPoint.contains("?") ? "&" : "?"
            combinedEndPoint += separator + key
            if !value.isEmpty {
                combinedEndPoint += "=" + value
            }
        }
        
        guard let url = URL(string: combinedEndPoint) else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.timeoutInterval = 0.5
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            guard let response = res as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                switch (res as? HTTPURLResponse)?.statusCode {
                case 400: throw NetworkError.badRequest
                case 401, 403: throw NetworkError.unauthorized
                case 404: throw NetworkError.notFound
                default: throw NetworkError.unknown(nil)
                }
            }
            return try self.decoder.decode(ResultType.self, from: data)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

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
