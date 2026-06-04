import Foundation

#if canImport(RevenueCat)
import RevenueCat
#endif

enum SubscriptionAccessState: Equatable {
    case unknown
    case free
    case trial
    case active
    case expired
    case error(String)

    var isPremium: Bool {
        self == .trial || self == .active
    }

    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}

enum SubscriptionServiceError: LocalizedError, Equatable {
    case missingConfiguration
    case sdkMissing
    case noYearlyPackage
    case purchaseCancelled
    case purchaseFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "RevenueCat ainda precisa ser configurado."
        case .sdkMissing:
            return "Adicione o SDK RevenueCat para ativar compras reais."
        case .noYearlyPackage:
            return "Não encontrei o plano anual no RevenueCat."
        case .purchaseCancelled:
            return "Tudo bem. Você pode voltar quando quiser."
        case .purchaseFailed(let message):
            return message
        }
    }
}

@Observable
final class SubscriptionService {
    private let configuration: AppConfiguration
    private var isConfigured = false
    var state: SubscriptionAccessState = .unknown
    var isPremium: Bool { state.isPremium }
    var isLoading = false

    init(configuration: AppConfiguration) {
        self.configuration = configuration
    }

    func configure(appUserID: String) {
        guard configuration.hasRevenueCatCredentials, !isConfigured else {
            return
        }

        #if canImport(RevenueCat)
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: configuration.revenueCatAPIKey, appUserID: appUserID)
        isConfigured = true
        #endif
    }

    func refreshEntitlement() async throws {
        guard configuration.hasRevenueCatCredentials else {
            state = .error(SubscriptionServiceError.missingConfiguration.localizedDescription)
            throw SubscriptionServiceError.missingConfiguration
        }

        #if canImport(RevenueCat)
        do {
            let info = try await Purchases.shared.customerInfo()
            updateState(from: info)
        } catch {
            state = .error(error.localizedDescription)
            throw SubscriptionServiceError.purchaseFailed(error.localizedDescription)
        }
        #else
        state = .error(SubscriptionServiceError.sdkMissing.localizedDescription)
        throw SubscriptionServiceError.sdkMissing
        #endif
    }

    func purchaseYearly() async throws {
        guard configuration.hasRevenueCatCredentials else {
            state = .error(SubscriptionServiceError.missingConfiguration.localizedDescription)
            throw SubscriptionServiceError.missingConfiguration
        }

        isLoading = true
        defer { isLoading = false }

        #if canImport(RevenueCat)
        do {
            let offerings = try await Purchases.shared.offerings()
            let offering = offerings.offering(identifier: configuration.revenueCatOfferingID) ?? offerings.current
            let package = package(in: offering)

            guard let package else {
                throw SubscriptionServiceError.noYearlyPackage
            }

            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled {
                throw SubscriptionServiceError.purchaseCancelled
            }
            updateState(from: result.customerInfo)
        } catch let error as SubscriptionServiceError {
            if error != .purchaseCancelled {
                state = .error(error.localizedDescription)
            }
            throw error
        } catch {
            state = .error(error.localizedDescription)
            throw SubscriptionServiceError.purchaseFailed(error.localizedDescription)
        }
        #else
        state = .error(SubscriptionServiceError.sdkMissing.localizedDescription)
        throw SubscriptionServiceError.sdkMissing
        #endif
    }

    func restorePurchases() async throws {
        guard configuration.hasRevenueCatCredentials else {
            state = .error(SubscriptionServiceError.missingConfiguration.localizedDescription)
            throw SubscriptionServiceError.missingConfiguration
        }

        isLoading = true
        defer { isLoading = false }

        #if canImport(RevenueCat)
        do {
            let info = try await Purchases.shared.restorePurchases()
            updateState(from: info)
        } catch {
            state = .error(error.localizedDescription)
            throw SubscriptionServiceError.purchaseFailed(error.localizedDescription)
        }
        #else
        state = .error(SubscriptionServiceError.sdkMissing.localizedDescription)
        throw SubscriptionServiceError.sdkMissing
        #endif
    }

    #if canImport(RevenueCat)
    private func package(in offering: Offering?) -> Package? {
        if !configuration.revenueCatYearlyProductID.isEmpty {
            return offering?.availablePackages.first {
                $0.storeProduct.productIdentifier == configuration.revenueCatYearlyProductID
            }
        }
        return offering?.annual ?? offering?.availablePackages.first
    }

    private func updateState(from customerInfo: CustomerInfo) {
        guard let entitlement = customerInfo.entitlements[configuration.revenueCatEntitlementID] else {
            state = .free
            return
        }

        if entitlement.isActive {
            state = entitlement.periodType == .trial ? .trial : .active
        } else {
            state = entitlement.expirationDate == nil ? .free : .expired
        }
    }
    #endif
}
