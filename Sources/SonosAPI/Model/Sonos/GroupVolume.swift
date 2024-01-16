// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let currentVolume = try? JSONDecoder().decode(CurrentVolume.self, from: jsonData)

import Foundation

// MARK: - GroupVolume
public struct GroupVolume: Codable {
    public let currentVolume: Int

    enum CodingKeys: String, CodingKey {
        case currentVolume = "CurrentVolume"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(String.self, forKey: .currentVolume)
        currentVolume = Int(value) ?? 0
    }
}
