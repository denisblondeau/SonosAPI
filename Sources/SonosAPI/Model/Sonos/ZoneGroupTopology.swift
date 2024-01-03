//
//  ZoneGroupTopology.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-01-24.
//

import Foundation

// MARK: - GroupData
public struct ZoneGroupTopology: Codable {
    public let zoneGroupState: ZoneGroupState
    
    enum CodingKeys: String, CodingKey {
        case zoneGroupState = "ZoneGroupState"
    }
}

// MARK: - ZoneGroupState
public struct ZoneGroupState: Codable {
    public let vanishedDevices: JSONNull?
    public let zoneGroups: ZoneGroups
    
    enum CodingKeys: String, CodingKey {
        case vanishedDevices = "VanishedDevices"
        case zoneGroups = "ZoneGroups"
    }
}

// MARK: - ZoneGroups
public struct ZoneGroups: Codable {
    /// A list of groups in the household (e.g. zone). Each element is a group object.
    public let zoneGroup: [ZoneGroup]
    
    enum CodingKeys: String, CodingKey {
        case zoneGroup = "ZoneGroup"
    }
}

// MARK: - ZoneGroup
public struct ZoneGroup: Codable {
    /// The ID of the player acting as the group coordinator for the group. This is a playerId value.
    public let coordinator: String
    /// The ID of the group.
    public let id: String
    public let zoneGroupMember: [ZoneGroupMember]
    
    enum CodingKeys: String, CodingKey {
        case coordinator = "@Coordinator"
        case id = "@ID"
        case zoneGroupMember = "ZoneGroupMember"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        coordinator = try container.decode(String.self, forKey: .coordinator)
        id = try container.decode(String.self, forKey: .id)
        if let x = try? container.decode([ZoneGroupMember].self, forKey: .zoneGroupMember) {
            zoneGroupMember = x
        } else
        if let x = try? container.decode(ZoneGroupMember.self, forKey: .zoneGroupMember) {
            var arrayZ = Array<ZoneGroupMember>()
            arrayZ.append(x)
            zoneGroupMember = arrayZ
        } else {
            throw DecodingError.typeMismatch(ZoneGroupMember.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ZoneGroupMember"))
        }
    }
}

// MARK: - ZoneGroupMember
public struct ZoneGroupMember: Codable {
    public let uuid: String
    public let location: String
    /// The display name for the room of the device, such as “Living Room” .
    public let zoneName: String
    public let icon: String
    public let configuration: Int
    /// The version of the software running on the device.
    public let softwareVersion: String
    public let swGen: Int
    public let minCompatibleVersion, legacyCompatibleVersion: String
    public let bootSeq, tvConfigurationError, hdmiCecAvailable, wirelessMode: Int
    public let wirelessLeafOnly, channelFreq, behindWifiExtender, wifiEnabled: Int
    public let ethLink, orientation, roomCalibrationState, secureRegState: Int
    public let voiceConfigState, micEnabled, airPlayEnabled, idleState: Int
    public let moreInfo: String
    public let sslPort, hhsslPort: Int
    public let htSatChanMapSet: String?
    public let satellite: [ZoneGroupMember]?
    public let invisible: Int?
    public var hostURL: URL? {
        if let locationURL = URL(string: location) {
            if let baseURL = getBaseURL(from: locationURL) {
                return baseURL
            }
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid = "@UUID"
        case location = "@Location"
        case zoneName = "@ZoneName"
        case icon = "@Icon"
        case configuration = "@Configuration"
        case softwareVersion = "@SoftwareVersion"
        case swGen = "@SWGen"
        case minCompatibleVersion = "@MinCompatibleVersion"
        case legacyCompatibleVersion = "@LegacyCompatibleVersion"
        case bootSeq = "@BootSeq"
        case tvConfigurationError = "@TVConfigurationError"
        case hdmiCecAvailable = "@HdmiCecAvailable"
        case wirelessMode = "@WirelessMode"
        case wirelessLeafOnly = "@WirelessLeafOnly"
        case channelFreq = "@ChannelFreq"
        case behindWifiExtender = "@BehindWifiExtender"
        case wifiEnabled = "@WifiEnabled"
        case ethLink = "@EthLink"
        case orientation = "@Orientation"
        case roomCalibrationState = "@RoomCalibrationState"
        case secureRegState = "@SecureRegState"
        case voiceConfigState = "@VoiceConfigState"
        case micEnabled = "@MicEnabled"
        case airPlayEnabled = "@AirPlayEnabled"
        case idleState = "@IdleState"
        case moreInfo = "@MoreInfo"
        case sslPort = "@SSLPort"
        case hhsslPort = "@HHSSLPort"
        case htSatChanMapSet = "@HTSatChanMapSet"
        case satellite = "Satellite"
        case invisible = "@Invisible"
    }
}

