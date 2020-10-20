//
//  PiHole.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/19/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

struct PiHole: Codable, Equatable {
    let domainsBeingBlocked: Int
    let dnsQueriesToday: Int
    let adsBlockedToday: Int
    let adsPercentageToday: Float
    let uniqueDomains: Int
    let queriesForwarded: Int
    let clientsEverSeen: Int
    let uniqueClients: Int
    let dnsQueriesAllTypes: Int
    let queriesCached: Int
    let noDataReplies: Int
    let nxDomainReplies: Int
    let cnameReplies: Int
    let ipReplies: Int
    let privacyLevel: Int
    let status: String
    let gravity: Gravity
    
    enum CodingKeys: String, CodingKey {
        case domainsBeingBlocked = "domains_being_blocked"
        case dnsQueriesToday = "dns_queries_today"
        case adsBlockedToday = "ads_blocked_today"
        case adsPercentageToday = "ads_percentage_today"
        case uniqueDomains = "unique_domains"
        case queriesForwarded = "queries_forwarded"
        case queriesCached = "queries_cached"
        case clientsEverSeen = "clients_ever_seen"
        case uniqueClients = "unique_clients"
        case dnsQueriesAllTypes = "dns_queries_all_types"
        case noDataReplies = "reply_NODATA"
        case nxDomainReplies = "reply_NXDOMAIN"
        case cnameReplies = "reply_CNAME"
        case ipReplies = "reply_IP"
        case privacyLevel = "privacy_level"
        case status
        case gravity = "gravity_last_updated"
    }
    
    func copy(
        domainsBeingBlocked: Int? = nil,
        dnsQueriesToday: Int? = nil,
        adsBlockedToday: Int? = nil,
        adsPercentageToday: Float? = nil,
        uniqueDomains: Int? = nil,
        queriesForwarded: Int? = nil,
        clientsEverSeen: Int? = nil,
        uniqueClients: Int? = nil,
        dnsQueriesAllTypes: Int? = nil,
        queriesCached: Int? = nil,
        noDataReplies: Int? = nil,
        nxDomainReplies: Int? = nil,
        cnameReplies: Int? = nil,
        ipReplies: Int? = nil,
        privacyLevel: Int? = nil,
        status: String? = nil,
        gravity: Gravity? = nil
    ) -> PiHole {
        return PiHole(
            domainsBeingBlocked: domainsBeingBlocked ?? self.domainsBeingBlocked,
            dnsQueriesToday: dnsQueriesToday ?? self.dnsQueriesToday,
            adsBlockedToday: adsBlockedToday ?? self.adsBlockedToday,
            adsPercentageToday: adsPercentageToday ?? self.adsPercentageToday,
            uniqueDomains: uniqueDomains ?? self.uniqueDomains,
            queriesForwarded: queriesForwarded ?? self.queriesForwarded,
            clientsEverSeen: clientsEverSeen ?? self.clientsEverSeen,
            uniqueClients: uniqueClients ?? self.uniqueClients,
            dnsQueriesAllTypes: dnsQueriesAllTypes ?? self.dnsQueriesAllTypes,
            queriesCached: queriesCached ?? self.queriesCached,
            noDataReplies: noDataReplies ?? self.noDataReplies,
            nxDomainReplies: nxDomainReplies ?? self.nxDomainReplies,
            cnameReplies: cnameReplies ?? self.cnameReplies,
            ipReplies: ipReplies ?? self.ipReplies,
            privacyLevel: privacyLevel ?? self.privacyLevel,
            status: status ?? self.status,
            gravity: gravity ?? self.gravity
        )
    }
    
    static func == (lhs: PiHole, rhs: PiHole) -> Bool {
        return lhs.domainsBeingBlocked == rhs.domainsBeingBlocked
            && lhs.dnsQueriesToday == rhs.dnsQueriesToday
            && lhs.adsBlockedToday == rhs.adsBlockedToday
            && lhs.adsPercentageToday == rhs.adsPercentageToday
            && lhs.uniqueDomains == rhs.uniqueDomains
            && lhs.queriesForwarded == rhs.queriesForwarded
            && lhs.clientsEverSeen == rhs.clientsEverSeen
            && lhs.uniqueClients == rhs.uniqueClients
            && lhs.dnsQueriesAllTypes == rhs.dnsQueriesAllTypes
            && lhs.queriesCached == rhs.queriesCached
            && lhs.noDataReplies == rhs.noDataReplies
            && lhs.nxDomainReplies == rhs.nxDomainReplies
            && lhs.cnameReplies == rhs.cnameReplies
            && lhs.ipReplies == rhs.ipReplies
            && lhs.privacyLevel == rhs.privacyLevel
            && lhs.status == rhs.status
            && lhs.gravity == rhs.gravity
    }
}

struct Gravity: Codable, Equatable {
    let fileExists: Bool
    let absolute: Int
    let relative: Relative
    
    enum CodingKeys: String, CodingKey {
        case fileExists = "file_exists"
        case absolute
        case relative
    }
    
    static func == (lhs: Gravity, rhs: Gravity) -> Bool {
        return lhs.fileExists == rhs.fileExists
            && lhs.absolute == rhs.absolute
            && lhs.relative == rhs.relative
    }
}

struct Relative: Codable, Equatable {
    let days: Int
    let hours: Int
    let minutes: Int
    
    static func == (lhs: Relative, rhs: Relative) -> Bool {
        return lhs.days == rhs.days
            && lhs.hours == rhs.hours
            && lhs.minutes == rhs.minutes
    }
}

struct StatusUpdate: Codable {
    let status: String
}

struct VersionResponse: Codable {
    let version: Int
}

struct TopItemsResponse: Codable {
    let topQueries: [String:Int]
    let topAds: [String:Int]
    
    enum CodingKeys: String, CodingKey {
        case topQueries = "top_queries"
        case topAds = "top_ads"
    }
}

enum PiHoleStatus: Equatable {
    case enabled
    case disabled(_ duration: String? = nil)
    case unknown
    
    var localizedStringKey: LocalizedStringKey {
        var key: String
        switch self {
        case .enabled:
            key = "enabled"
        case .disabled:
            key = "disabled"
        default:
            key = "unknown"
        }
        return LocalizedStringKey(key)
    }
    
    var foregroundColor: Color {
        switch self {
        case .enabled:
            return .green
        case .disabled:
            return .red
        default:
            return .gray
        }
    }
}
