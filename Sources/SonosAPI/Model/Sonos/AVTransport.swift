//
//  AVTransport.swift
//  SnosAPIDemo
//
//  Created by Denis Blondeau on 2023-02-01.
//

import Foundation

// MARK: - AVTransport
public struct AVTransport: Codable {
    
    public let avTransportURI, currentPlayMode, currentRecordQualityMode, currentTransportActions, currentValidPlayModes, directControlAccountID, directControlClientID, directControlIsSuspended, enqueuedTransportURI, nextAVTransportURI,nextAVTransportURIMetaData, playbackStorageMedium, possiblePlaybackStorageMedia, possibleRecordQualityModes, possibleRecordStorageMedia, recordMediumWriteStatus, recordStorageMedium, sleepTimerGeneration, transportPlaySpeed, transportStatus: String
    
    public let currentTrackMetaData: CurrentTrackMetaData?
    public let nextTrackMetaData: NextTrackMetaData?
    public let avTransportURIMetaData: TransportURIMetaData?
    public let enqueuedTransportURIMetaData: EnqueuedTransportURIMetaData?
    // Set to false to prevent audio crossfade from involving this track regardless of the prevailing playback policy. Default is true.
    public let currentCrossfadeMode: Bool
    public let alarmRunning, snoozeRunning, restartPending: Bool
    public let numberOfTracks: Int
    // The number of the track on the album.
    public let currentTrack: Int
    public let currentSection: Int
    // The duration of the track. Duration is formated in H:m:ss
    public let currentTrackDuration, currentMediaDuration: Date?
    //  A URL to an image for the track, for example, an album cover. Typically a JPG or PNG. Maximum length of 1024 characters. Where possible, this URL should be absolute Internet-based (as opposed to local LAN) and not require authorization to retrieve.
    public let currentTrackURI: String?
    //  A URL to an image for the track, for example, an album cover. Typically a JPG or PNG. Maximum length of 1024 characters. Where possible, this URL should be absolute Internet-based (as opposed to local LAN) and not require authorization to retrieve.
    public let nextTrackURI: String?
    public let transportState: TransportState
    
    enum CodingKeys: String, CodingKey {
        case transportState = "TransportState"
        case currentPlayMode = "CurrentPlayMode"
        case currentCrossfadeMode = "CurrentCrossfadeMode"
        case numberOfTracks = "NumberOfTracks"
        case currentTrack = "CurrentTrack"
        case currentSection = "CurrentSection"
        case currentTrackURI = "CurrentTrackURI"
        case currentTrackDuration = "CurrentTrackDuration"
        case currentTrackMetaData = "CurrentTrackMetaData"
        case nextTrackURI = "r:NextTrackURI"
        case nextTrackMetaData = "r:NextTrackMetaData"
        case enqueuedTransportURI = "r:EnqueuedTransportURI"
        case enqueuedTransportURIMetaData = "r:EnqueuedTransportURIMetaData"
        case playbackStorageMedium = "PlaybackStorageMedium"
        case avTransportURI = "AVTransportURI"
        case avTransportURIMetaData = "AVTransportURIMetaData"
        case nextAVTransportURI = "NextAVTransportURI"
        case nextAVTransportURIMetaData = "NextAVTransportURIMetaData"
        case currentTransportActions = "CurrentTransportActions"
        case currentValidPlayModes = "r:CurrentValidPlayModes"
        case directControlClientID = "r:DirectControlClientID"
        case directControlIsSuspended = "r:DirectControlIsSuspended"
        case directControlAccountID = "r:DirectControlAccountID"
        case transportStatus = "TransportStatus"
        case sleepTimerGeneration = "r:SleepTimerGeneration"
        case alarmRunning = "r:AlarmRunning"
        case snoozeRunning = "r:SnoozeRunning"
        case restartPending = "r:RestartPending"
        case transportPlaySpeed = "TransportPlaySpeed"
        case currentMediaDuration = "CurrentMediaDuration"
        case recordStorageMedium = "RecordStorageMedium"
        case possiblePlaybackStorageMedia = "PossiblePlaybackStorageMedia"
        case possibleRecordStorageMedia = "PossibleRecordStorageMedia"
        case recordMediumWriteStatus = "RecordMediumWriteStatus"
        case currentRecordQualityMode = "CurrentRecordQualityMode"
        case possibleRecordQualityModes = "PossibleRecordQualityModes"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let enumValue = try container.decodeIfPresent(TransportState.self, forKey: .transportState)
        transportState = enumValue ?? TransportState.stopped
        var value = try container.decodeIfPresent(String.self, forKey: .currentPlayMode)
        currentPlayMode = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentCrossfadeMode)
        currentCrossfadeMode = (Int(value ?? "0") == 1)
        value = try container.decodeIfPresent(String.self, forKey: .numberOfTracks)
        numberOfTracks = Int(value ?? "") ?? 0
        value = try container.decodeIfPresent(String.self, forKey: .currentTrack)
        currentTrack = Int(value ?? "") ?? 0
        value = try container.decodeIfPresent(String.self, forKey: .currentSection)
        currentSection = Int(value ?? "") ?? 0
        value = try container.decodeIfPresent(String.self, forKey: .currentTrackURI)
        currentTrackURI = value ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:m:ss"
        value = try container.decodeIfPresent(String.self, forKey: .currentTrackDuration)
        if let value {
            currentTrackDuration = dateFormatter.date(from: value)
        } else {
            currentTrackDuration = nil
        }
        currentTrackMetaData = try? container.decode(CurrentTrackMetaData.self, forKey: .currentTrackMetaData)
        value = try container.decodeIfPresent(String.self, forKey: .nextTrackURI)
        if let value {
            nextTrackURI = value
        } else {
            nextTrackURI = nil
        }
        nextTrackMetaData = try? container.decodeIfPresent(NextTrackMetaData.self, forKey: .nextTrackMetaData)
        enqueuedTransportURI = try container.decode(String.self, forKey: .enqueuedTransportURI)
        enqueuedTransportURIMetaData = try? container.decodeIfPresent(EnqueuedTransportURIMetaData.self, forKey: .enqueuedTransportURIMetaData)
        value = try? container.decodeIfPresent(String.self, forKey: .playbackStorageMedium)
        playbackStorageMedium = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .avTransportURI)
        avTransportURI = value ?? ""
        avTransportURIMetaData = try? container.decodeIfPresent(TransportURIMetaData.self, forKey: .avTransportURIMetaData)
        value = try container.decodeIfPresent(String.self, forKey: .nextAVTransportURI)
        nextAVTransportURI = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .nextAVTransportURIMetaData)
        nextAVTransportURIMetaData = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentTransportActions)
        currentTransportActions = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentValidPlayModes)
        currentValidPlayModes = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .directControlClientID)
        directControlClientID = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .directControlIsSuspended)
        directControlIsSuspended = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .directControlAccountID)
        directControlAccountID = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .transportStatus)
        transportStatus = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .sleepTimerGeneration)
        sleepTimerGeneration = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .alarmRunning)
        alarmRunning = (Int(value ?? "0") == 1)
        value = try container.decodeIfPresent(String.self, forKey: .snoozeRunning)
        snoozeRunning = (Int(value ?? "0") == 1)
        value = try container.decodeIfPresent(String.self, forKey: .restartPending)
        restartPending = (Int(value ?? "0") == 1)
        value =  try container.decodeIfPresent(String.self, forKey: .transportPlaySpeed)
        transportPlaySpeed = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentMediaDuration)
        if let value {
            currentMediaDuration = dateFormatter.date(from: value)
        } else {
            currentMediaDuration = nil
        }
        value =  try container.decodeIfPresent(String.self, forKey: .recordStorageMedium)
        recordStorageMedium = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .possiblePlaybackStorageMedia)
        possiblePlaybackStorageMedia = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .possibleRecordStorageMedia)
        possibleRecordStorageMedia = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .recordMediumWriteStatus)
        recordMediumWriteStatus = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .currentRecordQualityMode)
        currentRecordQualityMode = value ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .possibleRecordQualityModes)
        possibleRecordQualityModes = value ?? ""
    }
}

// MARK: - CurrentTrackMetaData
public struct CurrentTrackMetaData: Codable {
    public let res, streamContent, radioShowMd, streamInfo: String?
    // A URL to an image of the album, typically a JPG or PNG.
    public let albumArtURI: String?
    // The name of the track.
    public let title: String?
    public let class_: String?
    // The name of the artist. Maximum length of 76 characters.
    public let creator: String?
    // The name of the album. Maximum length of 76 characters.
    public let album: String?
    
    enum CodingKeys: String, CodingKey {
        case res
        case streamContent = "r:streamContent"
        case radioShowMd = "r:radioShowMd"
        case streamInfo = "r:streamInfo"
        case albumArtURI = "upnp:albumArtURI"
        case title = "dc:title"
        case class_ = "upnp:class"
        case creator = "dc:creator"
        case album = "upnp:album"
    }
}

// MARK: - EnqueuedTransportURIMetaData

public struct EnqueuedTransportURIMetaData: Codable {
    public let title, class_, desc: String?
    // A URL to an image of the album, typically a JPG or PNG.
    public let albumArtURI: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "dc:title"
        case class_ = "upnp:class"
        case desc
        case albumArtURI = "upnp:albumArtURI"
    }
}

// MARK: - NextTrackMetaData
public struct NextTrackMetaData: Codable {
    public let res, class_: String?
    // The name of the track.
    public let title: String?
    // A URL to an image of the album, typically a JPG or PNG.
    public let albumArtURI: String?
    // The name of the artist. Maximum length of 76 characters.
    public let creator: String?
    // The name of the album. Maximum length of 76 characters.
    public let album: String?
    
    enum CodingKeys: String, CodingKey {
        case res
        case albumArtURI = "upnp:albumArtURI"
        case title = "dc:title"
        case class_ = "upnp:class"
        case creator = "dc:creator"
        case album = "upnp:album"
    }
}

// MARK: - TransportURIMetaData
public struct TransportURIMetaData: Codable {
    public let title, class_: String?
    // A URL to an image of the album, typically a JPG or PNG.
    public let albumArtURI: String?
    public let desc: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "dc:title"
        case class_ = "upnp:class"
        case albumArtURI = "upnp:albumArtURI"
        case desc
    }
}

// MARK: - TransportState
public enum TransportState: String, Codable {
    case stopped = "STOPPED"
    case playing = "PLAYING"
    case pausedPlayback = "PAUSED_PLAYBACK"
    case transitioning = "TRANSITIONING"
}
