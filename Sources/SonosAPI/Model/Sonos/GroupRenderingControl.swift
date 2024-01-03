//
//  GroupRenderingControl.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-02-01.
//

// MARK: - GroupRenderingControl
public struct GroupRenderingControl: Codable {
    public let groupVolume: Int
    public let groupMute, groupVolumeChangeable: Bool
    
    enum CodingKeys: String, CodingKey {
        case groupVolume = "GroupVolume"
        case groupMute = "GroupMute"
        case groupVolumeChangeable = "GroupVolumeChangeable"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var value = try container.decode(String.self, forKey: .groupVolume)
        groupVolume = Int(value) ?? 0
        value = try container.decode(String.self, forKey: .groupMute)
        groupMute = Int(value) == 1
        value = try container.decode(String.self, forKey: .groupVolumeChangeable)
        groupVolumeChangeable = Int(value) == 1
    }
}
