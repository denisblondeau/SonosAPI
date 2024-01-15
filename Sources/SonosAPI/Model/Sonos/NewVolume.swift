// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let newVolume = try? JSONDecoder().decode(NewVolume.self, from: jsonData)

import Foundation

// MARK: - NewVolume
public struct NewVolume: Codable {
    public let volume: Int

    enum CodingKeys: String, CodingKey {
        case volume = "NewVolume"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(String.self, forKey: .volume)
        volume = Int(value) ?? 0
    }
}

