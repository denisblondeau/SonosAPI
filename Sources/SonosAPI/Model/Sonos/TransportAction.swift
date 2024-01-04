//
//  TransportAction.swift
//  SonosController
//
//  Created by Denis Blondeau on 2023-12-26.
//

//   let transportAction = try? JSONDecoder().decode(TransportAction.self, from: jsonData)

import Foundation

// MARK: - TransportAction
public struct TransportAction: Codable {
    public let actions: String

    enum CodingKeys: String, CodingKey {
        case actions = "Actions"
    }
}

