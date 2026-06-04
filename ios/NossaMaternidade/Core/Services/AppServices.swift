import Foundation

@Observable
final class AppServices {
    let configuration: AppConfiguration
    let supabase: SupabaseService
    let nathIA: NathIAService
    let subscriptions: SubscriptionService

    init(configuration: AppConfiguration = .current) {
        self.configuration = configuration
        self.supabase = SupabaseService(configuration: configuration)
        self.nathIA = NathIAService(configuration: configuration)
        self.subscriptions = SubscriptionService(configuration: configuration)
    }
}
