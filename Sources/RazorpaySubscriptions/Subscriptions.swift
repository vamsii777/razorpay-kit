import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Plans: create, fetch, list. See https://razorpay.com/docs/api/payments/subscriptions/#create-a-plan.
    public var plans: Plans { Plans(handler: handler) }

    /// Subscriptions: create, fetch, list, update, pause, resume, cancel.
    /// See https://razorpay.com/docs/api/payments/subscriptions/.
    public var subscriptions: Subscriptions { Subscriptions(handler: handler) }

    /// Plans: create, fetch, list. See https://razorpay.com/docs/api/payments/subscriptions/#create-a-plan.
    public struct Plans: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }

    /// Subscriptions: create, fetch, list, update, pause, resume, cancel.
    /// See https://razorpay.com/docs/api/payments/subscriptions/.
    public struct Subscriptions: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}

private struct CancelBody: Encodable, Sendable {
    let cancelAtCycleEnd: Int
    enum CodingKeys: String, CodingKey { case cancelAtCycleEnd = "cancel_at_cycle_end" }
}

private struct PauseBody: Encodable, Sendable {
    let pauseAt = "now"
    enum CodingKeys: String, CodingKey { case pauseAt = "pause_at" }
}

private struct ResumeBody: Encodable, Sendable {
    let resumeAt = "now"
    enum CodingKeys: String, CodingKey { case resumeAt = "resume_at" }
}
#if compiler(>=6.0)
extension RazorpayClient.Plans {
        /// Creates a plan.
        public func create(_ plan: Plan.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Plan {
            try await handler.perform(.POST, "/v1/plans", body: plan, options: options)
        }

        /// Fetches a plan.
        public func fetch(_ id: Plan.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Plan {
            try await handler.perform(.GET, "/v1/plans/\(id.pathComponent().get())", options: options)
        }

        /// Lists plans, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Plan> {
            RazorpayList(handler: handler, path: "/v1/plans", options: list, request: options)
        }
}

extension RazorpayClient.Subscriptions {
        /// Creates a subscription.
        public func create(_ subscription: Subscription.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions", body: subscription, options: options)
        }

        /// Fetches a subscription.
        public func fetch(_ id: Subscription.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.GET, "/v1/subscriptions/\(id.pathComponent().get())", options: options)
        }

        /// Lists subscriptions, fetching pages lazily. Filter with `["plan_id": "plan_…"]`.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Subscription> {
            RazorpayList(handler: handler, path: "/v1/subscriptions", options: list, request: options)
        }

        /// Changes the plan, quantity, offer or remaining count, now or at the end of the cycle.
        public func update(_ id: Subscription.ID, _ changes: Subscription.Update, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.PATCH, "/v1/subscriptions/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Cancels a subscription immediately, or at the end of the current cycle.
        public func cancel(_ id: Subscription.ID, at timing: Subscription.Timing = .now, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions/\(id.pathComponent().get())/cancel",
                                      body: CancelBody(cancelAtCycleEnd: timing == .cycleEnd ? 1 : 0), options: options)
        }

        /// Pauses an active subscription now.
        public func pause(_ id: Subscription.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions/\(id.pathComponent().get())/pause", body: PauseBody(), options: options)
        }

        /// Resumes a paused subscription now.
        public func resume(_ id: Subscription.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions/\(id.pathComponent().get())/resume", body: ResumeBody(), options: options)
        }

        /// Returns the subscription as it will look after its scheduled changes apply.
        public func scheduledChanges(_ id: Subscription.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.GET, "/v1/subscriptions/\(id.pathComponent().get())/retrieve_scheduled_changes", options: options)
        }

        /// Drops changes scheduled for the end of the cycle.
        public func cancelScheduledChanges(_ id: Subscription.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions/\(id.pathComponent().get())/cancel_scheduled_changes", options: options)
        }

        /// Removes an offer from a subscription.
        public func deleteOffer(_ offer: OfferID, from id: Subscription.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Subscription {
            try await handler.perform(.DELETE, "/v1/subscriptions/\(id.pathComponent().get())/\(offer.pathComponent().get())", options: options)
        }
}
#else
extension RazorpayClient.Plans {
        /// Creates a plan.
        public func create(_ plan: Plan.Create, options: RequestOptions = .init()) async throws -> Plan {
            try await handler.perform(.POST, "/v1/plans", body: plan, options: options)
        }

        /// Fetches a plan.
        public func fetch(_ id: Plan.ID, options: RequestOptions = .init()) async throws -> Plan {
            try await handler.perform(.GET, "/v1/plans/\(id.pathComponent().get())", options: options)
        }

        /// Lists plans, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Plan> {
            RazorpayList(handler: handler, path: "/v1/plans", options: list, request: options)
        }
}

extension RazorpayClient.Subscriptions {
        /// Creates a subscription.
        public func create(_ subscription: Subscription.Create, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions", body: subscription, options: options)
        }

        /// Fetches a subscription.
        public func fetch(_ id: Subscription.ID, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.GET, "/v1/subscriptions/\(id.pathComponent().get())", options: options)
        }

        /// Lists subscriptions, fetching pages lazily. Filter with `["plan_id": "plan_…"]`.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Subscription> {
            RazorpayList(handler: handler, path: "/v1/subscriptions", options: list, request: options)
        }

        /// Changes the plan, quantity, offer or remaining count, now or at the end of the cycle.
        public func update(_ id: Subscription.ID, _ changes: Subscription.Update, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.PATCH, "/v1/subscriptions/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Cancels a subscription immediately, or at the end of the current cycle.
        public func cancel(_ id: Subscription.ID, at timing: Subscription.Timing = .now, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions/\(id.pathComponent().get())/cancel",
                                      body: CancelBody(cancelAtCycleEnd: timing == .cycleEnd ? 1 : 0), options: options)
        }

        /// Pauses an active subscription now.
        public func pause(_ id: Subscription.ID, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions/\(id.pathComponent().get())/pause", body: PauseBody(), options: options)
        }

        /// Resumes a paused subscription now.
        public func resume(_ id: Subscription.ID, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions/\(id.pathComponent().get())/resume", body: ResumeBody(), options: options)
        }

        /// Returns the subscription as it will look after its scheduled changes apply.
        public func scheduledChanges(_ id: Subscription.ID, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.GET, "/v1/subscriptions/\(id.pathComponent().get())/retrieve_scheduled_changes", options: options)
        }

        /// Drops changes scheduled for the end of the cycle.
        public func cancelScheduledChanges(_ id: Subscription.ID, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.POST, "/v1/subscriptions/\(id.pathComponent().get())/cancel_scheduled_changes", options: options)
        }

        /// Removes an offer from a subscription.
        public func deleteOffer(_ offer: OfferID, from id: Subscription.ID, options: RequestOptions = .init()) async throws -> Subscription {
            try await handler.perform(.DELETE, "/v1/subscriptions/\(id.pathComponent().get())/\(offer.pathComponent().get())", options: options)
        }
}
#endif
