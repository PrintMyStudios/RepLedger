import Foundation
import StoreKit
import SwiftUI

// MARK: - Product Identifiers

/// Product identifiers for RepLedger subscriptions
enum ProductID: String, CaseIterable {
    case proMonthly = "repledger_pro_monthly"
    case proAnnual = "repledger_pro_annual"
    case coachMonthly = "repledger_coach_monthly"
    case coachAnnual = "repledger_coach_annual"

    var isPro: Bool {
        self == .proMonthly || self == .proAnnual
    }

    var isCoach: Bool {
        self == .coachMonthly || self == .coachAnnual
    }

    var isAnnual: Bool {
        self == .proAnnual || self == .coachAnnual
    }
}

// MARK: - Purchase State

/// Current state of the purchase manager
enum PurchaseState: Equatable {
    case idle
    case loading
    case purchasing(String) // Product ID being purchased
    case restoring
    case error(String)
    case pending // For Ask to Buy scenarios

    static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.restoring, .restoring), (.pending, .pending):
            return true
        case let (.purchasing(lhsId), .purchasing(rhsId)):
            return lhsId == rhsId
        case let (.error(lhsMsg), .error(rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

// MARK: - Purchase Result

/// Result of a purchase attempt
enum PurchaseResult {
    case success
    case cancelled
    case pending
    case failed(String)
}

// MARK: - Purchase Manager

/// Manages StoreKit 2 purchases, subscriptions, and entitlements.
/// Single source of truth for isPro/isCoach status.
@Observable
@MainActor
final class PurchaseManager {
    // MARK: - Constants

    private static let cachedEntitlementsKey = "cachedPurchasedProductIDs"

    // MARK: - Properties

    /// Available products loaded from App Store
    private(set) var products: [Product] = []

    /// Set of purchased product IDs from current entitlements
    private(set) var purchasedProductIDs: Set<String> = []

    /// Current purchase state
    private(set) var state: PurchaseState = .idle

    /// Transaction listener task
    private var updateListenerTask: Task<Void, Error>?

    // MARK: - Testing Overrides

    #if DEBUG
    /// Override for testing Pro entitlement without purchase
    var overrideIsPro: Bool? = nil

    /// Override for testing Coach entitlement without purchase
    var overrideIsCoach: Bool? = nil
    #endif

    // MARK: - Computed Properties

    /// Products filtered to Pro tier
    var proProducts: [Product] {
        products.filter { ProductID(rawValue: $0.id)?.isPro == true }
            .sorted { $0.price < $1.price }
    }

    /// Products filtered to Coach tier
    var coachProducts: [Product] {
        products.filter { ProductID(rawValue: $0.id)?.isCoach == true }
            .sorted { $0.price < $1.price }
    }

    /// Whether user has Coach entitlement
    var isCoach: Bool {
        #if DEBUG
        if let override = overrideIsCoach { return override }
        #endif
        return purchasedProductIDs.contains { ProductID(rawValue: $0)?.isCoach == true }
    }

    /// Whether user has Pro entitlement (Coach includes Pro)
    var isPro: Bool {
        #if DEBUG
        if let override = overrideIsPro { return override }
        #endif
        // Coach includes Pro features automatically
        return isCoach || purchasedProductIDs.contains { ProductID(rawValue: $0)?.isPro == true }
    }

    /// Check if user can create another template
    func canCreateTemplate(currentCount: Int) -> Bool {
        isPro || currentCount < 3
    }

    /// Free template limit
    var freeTemplateLimit: Int { 3 }

    // MARK: - Initialization

    nonisolated init() {}

    // MARK: - Lifecycle

    /// Start the purchase manager: load products, refresh entitlements, start listener
    func start() async {
        // Load cached entitlements first for immediate offline support
        loadCachedEntitlements()

        updateListenerTask = listenForTransactions()
        await loadProducts()
        await refreshEntitlements()
    }

    /// Load cached entitlements from UserDefaults (for offline support)
    private func loadCachedEntitlements() {
        if let cached = UserDefaults.standard.array(forKey: Self.cachedEntitlementsKey) as? [String] {
            purchasedProductIDs = Set(cached)
        }
    }

    // MARK: - Product Loading

    /// Load available products from App Store
    func loadProducts() async {
        // Allow retry if idle or in error state
        guard state == .idle || state != .loading else { return }
        if case .error = state {
            // Clear error before retrying
        }
        state = .loading

        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            state = .idle
        } catch {
            state = .error("Failed to load products")
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Entitlements

    /// Refresh entitlements from Transaction.currentEntitlements
    func refreshEntitlements() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                // Only include active subscriptions
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            }
        }

        purchasedProductIDs = purchased

        // Cache entitlements for offline support
        UserDefaults.standard.set(Array(purchased), forKey: Self.cachedEntitlementsKey)
    }

    // MARK: - Purchase

    /// Purchase a product
    /// - Parameter product: The product to purchase
    /// - Returns: Result of the purchase attempt
    func purchase(_ product: Product) async -> PurchaseResult {
        state = .purchasing(product.id)

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshEntitlements()
                await transaction.finish()
                state = .idle
                return .success

            case .pending:
                state = .pending
                return .pending

            case .userCancelled:
                state = .idle
                return .cancelled

            @unknown default:
                state = .idle
                return .cancelled
            }
        } catch StoreKitError.userCancelled {
            state = .idle
            return .cancelled
        } catch {
            let message = "Purchase failed: \(error.localizedDescription)"
            state = .error(message)
            return .failed(message)
        }
    }

    /// Clear error state
    func clearError() {
        if case .error = state {
            state = .idle
        }
    }

    // MARK: - Restore

    /// Restore previous purchases
    func restorePurchases() async {
        state = .restoring

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            state = .idle
        } catch {
            state = .error("Restore failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Transaction Handling

    /// Listen for transaction updates for the lifetime of the app
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { break }
                await self.handleTransaction(result)
            }
        }
    }

    /// Handle a transaction update
    private func handleTransaction(_ result: VerificationResult<StoreKit.Transaction>) async {
        guard let transaction = try? checkVerified(result) else { return }
        await refreshEntitlements()
        await transaction.finish()
    }

    /// Verify transaction signature
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified(_, let error):
            throw error
        }
    }
}

// MARK: - Environment Key

private struct PurchaseManagerKey: EnvironmentKey {
    static let defaultValue = PurchaseManager()
}

extension EnvironmentValues {
    var purchaseManager: PurchaseManager {
        get { self[PurchaseManagerKey.self] }
        set { self[PurchaseManagerKey.self] = newValue }
    }
}
