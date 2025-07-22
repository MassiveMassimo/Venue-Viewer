import Foundation
import CoreLocation
import Supabase

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var realtimeChannel: RealtimeChannelV2?
    
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isTrackingLocation = false
    var presenceUsers: [PresenceUser] = []
    var errorMessage: String?
    
    // User identification
    private let userId = UUID().uuidString
    
    // Indoor tracking configuration - 3 meters is good for room-to-room movement
    private let significantDistance: CLLocationDistance = 3.0
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = significantDistance
        
        // For indoor tracking, we want continuous updates
        locationManager.allowsBackgroundLocationUpdates = true
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startLocationTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            errorMessage = "Location permission not granted"
            return
        }
        
        locationManager.startUpdatingLocation()
        isTrackingLocation = true
        setupRealtimePresence()
    }
    
    func stopLocationTracking() {
        locationManager.stopUpdatingLocation()
        isTrackingLocation = false
        leavePresence()
    }
    
    func manualLocationUpdate() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            errorMessage = "Location permission not granted"
            return
        }
        
        // Request a one-time location update
        locationManager.requestLocation()
    }
    
    private func setupRealtimePresence() {
        Task {
            // Create a channel for the shared room using RealtimeV2
            let channel = supabase.realtimeV2.channel("venue-presence")
            realtimeChannel = channel
            
            // Subscribe to the channel first
            await channel.subscribe()
            
            // Listen for presence changes using broadcast (since presence streams may not be available)
            let broadcastStream = channel.broadcastStream(event: "presence-update")
            
            // Listen for presence changes
            Task {
                for await message in broadcastStream {
                    await MainActor.run {
                        self.handlePresenceUpdate(message)
                    }
                }
            }
        }
    }
    
    private func handlePresenceUpdate(_ message: [String: AnyJSON]) {
        // Parse the presence update message
        guard let payload = message["payload"],
              case let .object(payloadDict) = payload,
              let type = payloadDict["type"],
              case let .string(typeString) = type else { return }
        
        if typeString == "presence" {
            // Extract user data from the message
            guard let userData = payloadDict["user_data"],
                  case let .object(userDict) = userData,
                  let userId = userDict["user_id"],
                  case let .string(userIdString) = userId,
                  let latitude = userDict["latitude"],
                  case let .double(lat) = latitude,
                  let longitude = userDict["longitude"],
                  case let .double(lng) = longitude,
                  let timestamp = userDict["timestamp"],
                  case let .string(timestampString) = timestamp else { return }
            
            // Update or add user
            let user = PresenceUser(
                id: userIdString,
                latitude: lat,
                longitude: lng,
                timestamp: timestampString
            )
            
            // Update the users array
            if let index = presenceUsers.firstIndex(where: { $0.id == userIdString }) {
                presenceUsers[index] = user
            } else {
                presenceUsers.append(user)
            }
        }
    }
    
    private func sendPresenceUpdate(_ location: CLLocation) {
        guard let channel = realtimeChannel else { return }
        
        let presenceData: [String: AnyJSON] = [
            "type": .string("presence"),
            "user_data": .object([
                "latitude": .double(location.coordinate.latitude),
                "longitude": .double(location.coordinate.longitude),
                "accuracy": .double(location.horizontalAccuracy),
                "timestamp": .string(ISO8601DateFormatter().string(from: location.timestamp)),
                "user_id": .string(userId)
            ])
        ]
        
        Task {
            // The broadcast call is asynchronous, but it doesn't throw.
            // Simply 'await' the operation without 'try' or 'do-catch'.
            await channel.broadcast(event: "presence-update", message: presenceData)
        }
    }
    
    private func leavePresence() {
        guard let channel = realtimeChannel else { return }
        
        Task {
            // Send a leave message
            let leaveData: [String: AnyJSON] = [
                "type": .string("leave"),
                "user_data": .object([
                    "user_id": .string(userId)
                ])
            ]
            
            try? await channel.broadcast(event: "presence-update", message: leaveData)
            
            // Remove the channel
            await supabase.realtimeV2.removeChannel(channel)
            self.realtimeChannel = nil
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.currentLocation = location
        }
        
        // Send presence update to Supabase
        sendPresenceUpdate(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = "Location error: \(error.localizedDescription)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.authorizationStatus = status
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, can start tracking if needed
            break
        case .denied, .restricted:
            Task { @MainActor in
                errorMessage = "Location access denied"
            }
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Supporting Models

struct PresenceUser: Identifiable, Hashable {
    let id: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var formattedTimestamp: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeStyle = .medium
            return displayFormatter.string(from: date)
        }
        return timestamp
    }
}
