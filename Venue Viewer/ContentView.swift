import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Venue Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Indoor location sharing with Supabase")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Location Status Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(locationManager.isTrackingLocation ? .green : .gray)
                            Text("Location Status")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Authorization: \(authorizationStatusText)")
                            Text("Tracking: \(locationManager.isTrackingLocation ? "Active" : "Inactive")")
                            
                            if let location = locationManager.currentLocation {
                                Text("Coordinates: \(location.coordinate.latitude, specifier: "%.6f"), \(location.coordinate.longitude, specifier: "%.6f")")
                                Text("Accuracy: ±\(location.horizontalAccuracy, specifier: "%.1f")m")
                                Text("Last Update: \(location.timestamp.formatted(.dateTime.hour().minute().second()))")
                            } else {
                                Text("No location data")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Control Buttons
                    VStack(spacing: 12) {
                        if locationManager.authorizationStatus == .notDetermined {
                            Button("Request Location Permission") {
                                locationManager.requestLocationPermission()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        if locationManager.authorizationStatus == .authorizedWhenInUse ||
                            locationManager.authorizationStatus == .authorizedAlways {
                            HStack(spacing: 12) {
                                Button(locationManager.isTrackingLocation ? "Stop Tracking" : "Start Tracking") {
                                    if locationManager.isTrackingLocation {
                                        locationManager.stopLocationTracking()
                                    } else {
                                        locationManager.startLocationTracking()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(locationManager.isTrackingLocation ? .red : .green)
                                
                                Button("Update Now") {
                                    locationManager.manualLocationUpdate()
                                }
                                .buttonStyle(.bordered)
                                .disabled(!locationManager.isTrackingLocation)
                            }
                        }
                    }
                    
                    // Error Message
                    if let errorMessage = locationManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Active Users in Venue
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.2.circle.fill")
                                .foregroundColor(.blue)
                            Text("Active Users (\(locationManager.presenceUsers.count))")
                                .font(.headline)
                        }
                        
                        if locationManager.presenceUsers.isEmpty {
                            Text("No other users in venue")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(locationManager.presenceUsers) { user in
                                    UserPresenceRow(user: user)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Configuration Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Configuration")
                            .font(.headline)
                        
                        Text("• Tracking Distance: 3m (optimal for indoor)")
                        Text("• Update Mode: Significant location changes")
                        Text("• Shared Room: venue-presence")
                        Text("• Accuracy: Best available")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var authorizationStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Always Authorized"
        case .authorizedWhenInUse:
            return "When In Use"
        @unknown default:
            return "Unknown"
        }
    }
}

struct UserPresenceRow: View {
    let user: PresenceUser
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("User: \(String(user.id.prefix(8)))...")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Lat: \(user.latitude, specifier: "%.6f")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Lng: \(user.longitude, specifier: "%.6f")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(user.formattedTimestamp)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
