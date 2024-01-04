//
//  SonosGroup.swift
//  SonosController
//
//  Created by Denis Blondeau on 2023-12-20.
//

import Foundation

public struct SonosGroup: Identifiable {
    public var id: String
    public let coordinatorURL: URL
    public let name: String
    
    public init(id: String, coordinatorURL: URL, name: String) {
        self.id = id
        self.coordinatorURL = coordinatorURL
        self.name = name
    }
}
