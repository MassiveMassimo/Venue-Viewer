import SwiftUI
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://qorqrdgtwxpnnywmvlro.supabase.co")!,
    supabaseKey: "sb_publishable_jKOk02cbbWj3BzSuINX4FQ_8nOhjQfR"
)

@main
struct VenueViewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
