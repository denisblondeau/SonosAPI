//
//  SOAPEventSession.swift
//  SonosAPIDemo
//
//  Created by Denis Blondeau on 2023-01-14.
//

import AppKit
import Combine
import Network

/// Sono Service Event.
public final class SOAPEventSession {
    
    // MARK: - Enums Start
    
    public enum SOAPEventError: LocalizedError, Identifiable {
        public var id: String { localizedDescription }
        
        case dataDecoding(String)
        case httpResponse(String, Int)
        case urlRequest(Error)
        case genericError(String)
        
        public var description: String {
            switch self {
                
            case .httpResponse(let errorType, let statusCode):
                return "\(errorType). HTTP response code: \(statusCode)"
                
            case .urlRequest(let error):
                return "Cannot subscribe/unsubscribe to/from host. Invalud URL request: \(error.localizedDescription)"
                
            case .dataDecoding(let error):
                return "Cannot parse json data to object - \(error)"
                
            case .genericError(let description):
                return ("Error occured: \(description)")
            }
        }
    }
    
    public enum SonosEvent {
        
        case subscription(service: SonosService)
        
        var service: SonosService {
            
            switch self {
                
            case .subscription(service: let service):
                return service
            }
        }
        
        var eventSubscriptionEndpoint: String {
            
            switch self {
                
            case .subscription(service: let service):
                
                var endpoint = ""
                
                switch service {
                    
                case .alarmClock:
                    break
                case .audioIn:
                    break
                case .avTransport:
                    endpoint = "/MediaRenderer/AVTransport/Event"
                case .connectionManager:
                    break
                case .contentDirectory:
                    break
                case .deviceProperties:
                    break
                case .groupManagement:
                    break
                case .groupRenderingControl:
                    endpoint = "/MediaRenderer/GroupRenderingControl/Event"
                case .htControl:
                    break
                case .musicServices:
                    break
                case .qPlay:
                    break
                case .queue:
                    break
                case .renderingControl:
                    break
                case .systemProperties:
                    break
                case .virtualLineIn:
                    break
                case .zoneGroupTopology:
                    endpoint = "/ZoneGroupTopology/Event"
                }
                return endpoint
            }
        }
    }
    
    // MARK: - Enums End
    
    private var serviceEvents = [SonosEvent]()
    private var listener: NWListener!
    private var subscriptionSID = [String]()
    private var subscriptionTimeout: Double  = 1 * 3600 // 3600 seconds = 1 hr.
    private var renewSubscriptionTimer: Timer?
    private var callbackURL: URL
    private var hostURL: URL?
    
    private let parameters: NWParameters = {
        let parameters: NWParameters = .tcp
        parameters.acceptLocalOnly = true
        return parameters
    }()
    
    /// Publisher for Sonos events and various messages (errors, etc.)
    public let onDataReceived = PassthroughSubject<JSONData, SOAPEventError>()
    
    public init(callbackURL: URL) {
        
        self.callbackURL = callbackURL
        setupListener()
        
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            
            self.renewSubscriptionTimer?.invalidate()
            
            Task {
                await self.unsubscribeFromEvents()
            }
            
            if self.listener.state != .cancelled {
                self.listener.cancel()
            }
        }
    }
    
    /// Initialise and start the event listener.
    private func setupListener() {
        
        guard let port = NWEndpoint.Port(String(callbackURL.port!)) else {
            
            fatalError("func \(#function): Cannot create port for event listener.")
        }
        do {
            listener = try NWListener(using: parameters, on: port)
        } catch {
            fatalError("func \(#function): Cannot create event listener: (\(error.localizedDescription)")
        }
        
        listener.stateUpdateHandler = { state in
            
            switch state {
                
            case .setup:
                break
                
            case .waiting(_):
                break
                
            case .ready:
                
                break
                
            case .failed(let error):
                fatalError("func \(#function): Event listener failed: (\(error.localizedDescription)")
                
            case .cancelled:
                break
                
            @unknown default:
                break
            }
        }
        
        listener.newConnectionHandler = { connection in
            
            // Need to ack Sonos coordinator - otherwise the subscription will terminate.
            let msg = "HTTP/1.1 200 OK\r\nContent-length: 0\r\nConnection: close\r\n\r\n"
            
            connection.send(content: Data(msg.utf8), completion: .idempotent)
            
            connection.receiveMessage { completeContent, contentContext, isComplete, error in
                
                connection.cancel()
                
                if let completeContent {
                    
                    let parser = EventParser()
                    
                    if let jsonData = parser.process(eventData: completeContent) {
                        self.onDataReceived.send(jsonData)
                    } else {
                        self.onDataReceived.send(completion: .failure(.dataDecoding("Cannot parse XML to JSON.")))
                    }
                }
            }
            
            connection.stateUpdateHandler = { state in
                switch state {
                    
                case .setup:
                    break
                    
                case .waiting(_):
                    break
                    
                case .preparing:
                    break
                    
                case .ready:
                    break
                    
                case .failed(_):
                    fatalError("Connection failed.")
                    
                case .cancelled:
                    break
                    
                @unknown default:
                    break
                }
            }
            connection.start(queue: .main)
        }
        listener.start(queue: .main)
    }
    
    /// Renew events subscriptions.
    private func renewSubscriptions() {
        
        guard (!subscriptionSID.isEmpty && !serviceEvents.isEmpty) else {
            return
        }
        
        guard (hostURL != nil) else {
            return
        }
        
        Task {
            
            let allRequestsErrors = await withTaskGroup(of: (SonosService?, SOAPEventError?).self, returning: [SonosService: SOAPEventError].self) { taskGroup in
                
                var childTaskErrors = [SonosService: SOAPEventError]()
                
                for (index, event) in serviceEvents.enumerated() {
                    
                    let serviceURL = URL(string: hostURL!.description + event.eventSubscriptionEndpoint)
                    guard let serviceURL else {
                        return [event.service: .genericError("\(#function) - Cannot create service URL.")]
                    }
                    
                    taskGroup.addTask {
                        var request: URLRequest
                        request = URLRequest(url: serviceURL)
                        request.httpMethod = "SUBSCRIBE"
                        request.addValue("\(self.subscriptionSID[index])", forHTTPHeaderField: "SID")
                        request.addValue("Second-\(self.subscriptionTimeout)", forHTTPHeaderField: "TIMEOUT")
                        
                        do {
                            
                            let (_, response) = try await URLSession.shared.data(for: request)
                            let httpResponse = response as! HTTPURLResponse
                            
                            guard httpResponse.statusCode == 200 else {
                                return (event.service, .httpResponse("Cannot renew subscriptions", httpResponse.statusCode))
                            }
                            
                            if let sid = httpResponse.value(forHTTPHeaderField: "SID") {
                                self.subscriptionSID[index] = sid
                            } else {
                                self.subscriptionSID[index] = ""
                            }
                            
                        } catch {
                            return (event.service, .urlRequest(error))
                        }
                        
                        // As there is no error...
                        return(nil, nil)
                    }
                }
                
                for await result in taskGroup {
                    
                    // Only include errors = and not dummy result for no error requests.
                    if let key = result.0, let value = result.1 {
                        childTaskErrors[key] = value
                    }
                }
                
                return childTaskErrors
            }
            
            // If any error, send the first one to subscriber.
            if let firstError = allRequestsErrors.first {
                onDataReceived.send(completion: .failure(firstError.value))
            }
        }
    }
    
    /// Subscribe to Sonos events. Subscribing to events remove/replace subscriptions already in place.
    /// - Parameter events: Sonos events to subscribe to.
    public func subscribeToEvents(events: [SonosEvent], hostURL: URL) async  {
        
        await unsubscribeFromEvents()
        self.hostURL = hostURL
        
        // Give time to the listener to be ready, if it just got started.
        if listener.state != .ready {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                guard self.listener.state == .ready  else {
                    self.onDataReceived.send(completion: .failure(.genericError("Event listerner is not ready -  Cannot subscribe to events.")))
                    return
                }
            }
        }
        
        let allRequestsErrors = await withTaskGroup(of: (SonosService?, SOAPEventError?).self, returning: [SonosService: SOAPEventError].self) { taskGroup in
            
            var childTaskErrors = [SonosService: SOAPEventError]()
            
            for event in events {
                
                // Check if subscription for that service already exists - i.e. only susbcribe new services.
                let isAlreadySubscribed = serviceEvents.contains { sonosEvent in
                    return sonosEvent.service == event.service
                }
                
                if isAlreadySubscribed {
                    continue
                } else {
                    serviceEvents.append(event)
                }
                
                let serviceURL = URL(string: hostURL.description + event.eventSubscriptionEndpoint)
                guard let serviceURL else {
                    return [event.service: .genericError("\(#function) - Cannot create service URL.")]
                }
                
                taskGroup.addTask {
                    
                    var request: URLRequest
                    request = URLRequest(url: serviceURL)
                    request.httpMethod = "SUBSCRIBE"
                    request.addValue("<\(self.callbackURL.description)>", forHTTPHeaderField: "CALLBACK")
                    request.addValue("upnp:event", forHTTPHeaderField: "NT")
                    request.addValue("Second-\(self.subscriptionTimeout)", forHTTPHeaderField: "TIMEOUT")
                    
                    do {
                        
                        let (_, response) = try await URLSession.shared.data(for: request)
                        
                        let httpResponse = response as! HTTPURLResponse
                        
                        guard httpResponse.statusCode == 200 else {
                            return (event.service, .httpResponse("Cannot subscribe to events", httpResponse.statusCode))
                        }
                        
                        if let sid = httpResponse.value(forHTTPHeaderField: "SID") {
                            self.subscriptionSID.append(sid)
                        } else {
                            return (event.service, .genericError("\(#function) - Cannot retrieve SID."))
                        }
                        
                    } catch {
                        return (event.service, .urlRequest(error))
                    }
                    
                    // As there is no error...
                    return(nil, nil)
                }
            }
            
            for await result in taskGroup {
                
                // Only include errors = and not dummy result for no error requests.
                if let key = result.0, let value = result.1 {
                    childTaskErrors[key] = value
                }
            }
            return childTaskErrors
        }
        
        // If any error, send the first one to subscriber.
        if let firstError = allRequestsErrors.first {
            onDataReceived.send(completion: .failure(firstError.value))
        }
        
        // Set up subscription renewal - Renew "secondsBeforeTimeout" before end of current subscription.
        if renewSubscriptionTimer == nil {
            let secondsBeforeTimeout = 60.0
            if subscriptionTimeout <= secondsBeforeTimeout {
                fatalError("\(#function) subscriptionTimeout is too low.")
            }
            DispatchQueue.main.async {
                self.renewSubscriptionTimer = Timer.scheduledTimer(withTimeInterval: self.subscriptionTimeout - secondsBeforeTimeout, repeats: true) { timer in
                    self.renewSubscriptions()
                }
            }
        }
    }
    
    /// Unsubscribe from all subscriibed events.
    public func unsubscribeFromEvents()  async {
        
        if renewSubscriptionTimer != nil {
            renewSubscriptionTimer?.invalidate()
            renewSubscriptionTimer = nil
        }
        
        guard (!subscriptionSID.isEmpty && !serviceEvents.isEmpty) else {
            return
        }
        
        guard (hostURL != nil) else {
            return
        }
        
        let allRequestsErrors = await withTaskGroup(of: (SonosService?, SOAPEventError?).self, returning: [SonosService: SOAPEventError].self) { taskGroup in
            
            var childTaskErrors = [SonosService: SOAPEventError]()
            
            for (index, event) in serviceEvents.enumerated() {
                
                let serviceURL = URL(string: hostURL!.description + event.eventSubscriptionEndpoint)
                guard let serviceURL else {
                    return [event.service: .genericError("\(#function) - Cannot create service URL.")]
                }
                
                taskGroup.addTask {
                    var request: URLRequest
                    request = URLRequest(url: serviceURL)
                    request.httpMethod = "UNSUBSCRIBE"
                    request.addValue("\(self.subscriptionSID[index])", forHTTPHeaderField: "SID")
                    do {
                        let (_, response) = try await URLSession.shared.data(for: request)
                        
                        let httpResponse = response as! HTTPURLResponse
                        
                        guard (httpResponse.statusCode == 200) || (httpResponse.statusCode == 412) else {
                            return (event.service, .httpResponse("Cannot unsubscribe from events", httpResponse.statusCode))
                        }
                    } catch {
                        return (event.service, .urlRequest(error))
                        
                    }
                    // As there is no error...
                    return(nil, nil)
                }
            }
            
            for await result in taskGroup {
                
                // Only include errors = and not dummy result for no error requests.
                if let key = result.0, let value = result.1 {
                    childTaskErrors[key] = value
                }
            }
            
            return childTaskErrors
        }
        
        // If any error, send the first one to subscriber.
        if let firstError = allRequestsErrors.first {
            onDataReceived.send(completion: .failure(firstError.value))
        }
        
        self.serviceEvents.removeAll()
        self.subscriptionSID.removeAll()
        
    }
}

// MARK: - Shared enum

public enum SonosService: String  {
    case alarmClock
    case audioIn
    case avTransport
    case connectionManager
    case contentDirectory
    case deviceProperties
    case groupManagement
    case groupRenderingControl
    case htControl
    case musicServices
    case qPlay
    case queue
    case renderingControl
    case systemProperties
    case virtualLineIn
    case zoneGroupTopology
}
