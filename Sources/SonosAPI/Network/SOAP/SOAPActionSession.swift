//
//  SOAPActionSession.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-01-12.
//  Last modified on 2023-12-19.

import Combine
import Foundation

/// Sonos Service Action.
public final class SOAPActionSession {
    
    // MARK: - Enums Start
    
    public enum SOAPActionError: LocalizedError, Identifiable {
        public var id: String { localizedDescription }
        
        case dataDecoding(String)
        case urlRequest(Int)
        
        public var description: String {
            switch self {
                
            case .dataDecoding(let errorMessage):
                return errorMessage
                
            case .urlRequest(let statusCode):
                return "Cannot retrieve data from host. HTTP response code: \(statusCode)"
            }
        }
    }
    
    public enum Service {
        case avTransport(action: AVTransportAction, url: URL)
        case groupRenderingControl(action: GroupRenderingControlAction, url: URL, adjustment: Int)
        case renderingControl(action: RenderingControlAction, url: URL, adjustment: Int)
        case zoneGroupTopology(action: ZoneGroupTopologyAction, url: URL)
        
        public var action: String {
            switch self {
                
            case .avTransport(action: let action, _):
                return action.rawValue.capitalizingFirstLetter()
                
            case .zoneGroupTopology(let action, _):
                return action.rawValue.capitalizingFirstLetter()
                
            case .groupRenderingControl(let action, _, _):
                return action.rawValue.capitalizingFirstLetter()
                
            case .renderingControl(action: let action, _, _):
                return action.rawValue.capitalizingFirstLetter()
            }
        }
        
        var actionBody: String {
            switch self {
                
            case .avTransport(let action, _):
                switch action {
                    
                case .getPositionInfo:
                    return "<u:GetPositionInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'><InstanceID>0</InstanceID></u:GetPositionInfo>"
                case .next:
                    return "<u:Next xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'><InstanceID>0</InstanceID></u:Next>"
                case .pause:
                    return "<u:Pause xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'><InstanceID>0</InstanceID></u:Pause>"
                case .play:
                    return "<u:Play xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'><InstanceID>0</InstanceID><Speed>1</Speed></u:Play>"
                case .previous:
                    return "<u:Previous xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'><InstanceID>0</InstanceID></u:Previous>"
                case .getTransportInfo:
                    return "<u:GetTransportInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'><InstanceID>0</InstanceID></u:GetTransportInfo>"
                case .getCurrentTransportActions:
                    return "<u:GetCurrentTransportActions xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'><InstanceID>0</InstanceID></u:GetCurrentTransportActions>"
                }
                
            case .zoneGroupTopology(let action, _):
                switch action {
                    
                case .beginsoftwareUpdate:
                    return ""
                case .checkUpdate:
                    return ""
                case .getZoneGroupAttributes:
                    return ""
                case .getZoneGroupState:
                    return "<u:GetZoneGroupState xmlns:u='urn:schemas-upnp-org:service:ZoneGroupTopology:1'></u:GetZoneGroupState>"
                case .registerMobileDevice:
                    return ""
                case .reportAlarmStartedRunning:
                    return ""
                case .reportUnresponsiveDevice:
                    return ""
                case .submitDiagnostics:
                    return ""
                    
                }
            case .groupRenderingControl(let action, _, let adjustment):
                switch action {
                    
                case .getGroupVolume:
                    return "<u:GetGroupVolume xmlns:u='urn:schemas-upnp-org:service:GroupRenderingControl:1'><InstanceID>0</InstanceID></u:GetGroupVolume>"
                    
                case .setRelativeGroupVolume:
                    return "<u:SetRelativeGroupVolume xmlns:u='urn:schemas-upnp-org:service:GroupRenderingControl:1'><InstanceID>0</InstanceID><Adjustment>\(adjustment)</Adjustment></u:SetRelativeGroupVolume>"
                }
                    
            case .renderingControl(let action, _, let adjustment):
                
                switch action {
                   
                case .setRelativeVolume:
                    return "<u:SetRelativeVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'><InstanceID>0</InstanceID><Channel>Master</Channel><Adjustment>\(adjustment)</Adjustment></u:SetRelativeVolume>"
                }
               
            }
        }
        
        var controlURL: URL {
            switch self {
            
            case .avTransport(_, let url):
                return URL(string: "\(url.description)/MediaRenderer/AVTransport/Control")!
                
            case .zoneGroupTopology(_, let url):
                return URL(string: "\(url.description)/ZoneGroupTopology/Control")!
                
            case .groupRenderingControl(_, let url, _):
                return URL(string: "\(url.description)/MediaRenderer/GroupRenderingControl/Control")!
                
            case .renderingControl(_, url: let url, _):
                return URL(string: "\(url.description)/MediaRenderer/RenderingControl/Control")!
            }
        }
        
        var serviceType: String {
            switch self {
            case .avTransport:
                return "urn:schemas-upnp-org:service:AVTransport:1"
            case .zoneGroupTopology:
                return "urn:schemas-upnp-org:service:ZoneGroupTopology:1"
            case .groupRenderingControl:
                return "urn:schemas-upnp-org:service:GroupRenderingControl:1"
            case .renderingControl:
                return "urn:schemas-upnp-org:service:RenderingControl:1"

            }
        }
    }
    
    // MARK: - Enums End
    
    private var service: Service
    public let onDataReceived = PassthroughSubject<String, SOAPActionError>()
    
    public init(service: Service) {
        self.service = service
    }
    
    /// Execute the specified action.
    public func run() {
        
        let soapBody = "<?xml version='1.0' encoding='utf-8'?><s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'><s:Body>\(service.actionBody)</s:Body></s:Envelope>"
    
        let length = soapBody.count
        let soapAction = service.serviceType + "#" + service.action
        
        Task {
            var request = URLRequest(url: service.controlURL)
        
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue("\(length)", forHTTPHeaderField: "Content-Length")
            request.addValue(soapAction, forHTTPHeaderField: "SOAPAction")
            request.httpMethod = "POST"
            request.httpBody = soapBody.data(using: .utf8)
            
            let (data, response) = try! await URLSession.shared.data(for: request)
            
            let httpResponse = response as! HTTPURLResponse
           
            guard httpResponse.statusCode == 200 else {
                if let xml  = String(data: data, encoding: .utf8) {
                    print("XML  Source - HTTP Error : \(xml)")
                }
                onDataReceived.send(completion: .failure(.urlRequest(httpResponse.statusCode)))
                return
            }
            
            var sourceXML: String?
            
            switch service.action {
                
            // Following actions do not have an output value.
            case "Play", "Pause", "Next", "Previous":
                onDataReceived.send(completion: .finished)
                return
                
            case ZoneGroupTopologyAction.getZoneGroupState.rawValue.capitalizingFirstLetter():
                sourceXML = String(data: data, encoding: .utf8)?.html2String
             
            default:
                sourceXML = String(data: data, encoding: .utf8)
            }
         
            guard let sourceXML else {
                onDataReceived.send(completion: .failure(.dataDecoding("Cannot decode HTML to XML.")))
                return
            }
            
            let parser = ActionParser()
            let jsonStr = parser.process(action: service.action, xml: sourceXML)
            
            guard let jsonStr else {
         
                onDataReceived.send(completion: .failure(.dataDecoding("Cannot parse XML to JSON.")))
                return
            }
          
            onDataReceived.send(jsonStr)
            onDataReceived.send(completion: .finished)
        }
    }
}

// MARK: - Shared enums

public enum AVTransportAction: String {
    case getCurrentTransportActions
    case getPositionInfo
    case getTransportInfo
    case next
    case pause
    case play
    case previous
}

public enum GroupRenderingControlAction: String {
    case getGroupVolume
    case setRelativeGroupVolume
}

public enum RenderingControlAction: String {
    case setRelativeVolume
}

public enum ZoneGroupTopologyAction: String {
    case beginsoftwareUpdate
    case checkUpdate
    case getZoneGroupAttributes
    case getZoneGroupState
    case registerMobileDevice
    case reportAlarmStartedRunning
    case reportUnresponsiveDevice
    case submitDiagnostics
}


