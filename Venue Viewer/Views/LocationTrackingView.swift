import SwiftUI
import CoreLocation

struct LocationTrackingView: View {
    @State private var locationManager = LocationManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .symbolEffect(.pulse, options: .repeating.speed(0.5), value: locationManager.isTrackingLocation)
                    
                    Text("Venue Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Indoor location sharing")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Location Status Card
                LocationStatusCard(locationManager: locationManager)
                    .cardStyle()
                
                // Control Buttons
                LocationControlButtons(locationManager: locationManager)
                
                // Error Message
                if let errorMessage = locationManager.errorMessage {
                    ErrorMessageView(message: errorMessage)
                }
                
                // Active Users
                ActiveUsersCard(users: locationManager.presenceUsers)
                    .cardStyle()
                
                // Configuration Info
                ConfigurationInfoCard()
                    .cardStyle()
                
                NavigationLink("Indoor Map"){ IndoorMap(locationManager: locationManager)}
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Location Tracking")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Subviews

struct LocationStatusCard: View {
    let locationManager: LocationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(locationManager.isTrackingLocation ? .green : .gray)
                Text("Location Status")
                    .font(.headline)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                StatusRow(label: "Authorization", value: authorizationStatusText)
                StatusRow(label: "Tracking", value: locationManager.isTrackingLocation ? "Active" : "Inactive")
                
                if let location = locationManager.currentLocation {
                    StatusRow(
                        label: "Coordinates",
                        value: String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
                    )
                    StatusRow(
                        label: "Accuracy",
                        value: String(format: "±%.1fm", location.horizontalAccuracy)
                    )
                    StatusRow(
                        label: "Last Update",
                        value: location.timestamp.formatted(.dateTime.hour().minute().second())
                    )
                } else {
                    Text("No location data")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
    
    private var authorizationStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always Authorized"
        case .authorizedWhenInUse: return "When In Use"
        @unknown default: return "Unknown"
        }
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct LocationControlButtons: View {
    let locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 12) {
            if locationManager.authorizationStatus == .notDetermined {
                Button(action: {
                    locationManager.requestLocationPermission()
                }) {
                    Label("Request Location Permission", systemImage: "location.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
                locationManager.authorizationStatus == .authorizedAlways {
                HStack(spacing: 12) {
                    Button(action: {
                        if locationManager.isTrackingLocation {
                            locationManager.stopLocationTracking()
                        } else {
                            locationManager.startLocationTracking()
                        }
                    }) {
                        Label(
                            locationManager.isTrackingLocation ? "Stop Tracking" : "Start Tracking",
                            systemImage: locationManager.isTrackingLocation ? "stop.circle" : "play.circle"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(locationManager.isTrackingLocation ? .red : .green)
                    
                    Button(action: {
                        locationManager.manualLocationUpdate()
                    }) {
                        Label("Update", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!locationManager.isTrackingLocation)
                }
            }
        }
    }
}

struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ActiveUsersCard: View {
    let users: [PresenceUser]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.circle.fill")
                    .foregroundColor(.blue)
                Text("Active Users (\(users.count))")
                    .font(.headline)
            }
            
            Divider()
            
            if users.isEmpty {
                Text("No other users in venue")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(users) { user in
                        UserPresenceRow(user: user)
                    }
                }
            }
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
                
                HStack(spacing: 8) {
                    Label(String(format: "%.6f", user.latitude), systemImage: "arrow.up")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Label(String(format: "%.6f", user.longitude), systemImage: "arrow.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
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
        .subtleBorder()
    }
}

struct ConfigurationInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Configuration", systemImage: "gearshape")
                .font(.headline)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                ConfigRow(icon: "ruler", text: "Tracking Distance: 3m (indoor optimized)")
                ConfigRow(icon: "location.north.line", text: "Update Mode: Significant changes")
                ConfigRow(icon: "person.2", text: "Shared Room: venue-presence")
                ConfigRow(icon: "target", text: "Accuracy: Best available")
            }
        }
    }
}

struct ConfigRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}


#Preview {
    NavigationStack {
        LocationTrackingView()
    }
}
