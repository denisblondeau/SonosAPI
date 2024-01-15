// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let newVolume = try? JSONDecoder().decode(NewVolume.self, from: jsonData)

import Foundation

// MARK: - NewVolume
public struct NewVolume: Codable {
    public let newVolume: Int

    enum CodingKeys: String, CodingKey {
        case newVolume = "NewVolume"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var value = try container.decode(String.self, forKey: .newVolume)
        newVolume = Int(value) ?? 0
    }
}

