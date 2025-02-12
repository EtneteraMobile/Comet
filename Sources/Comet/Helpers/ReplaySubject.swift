//
//  ReplaySubject.swift
//  Comet
//
//  Created by Tuan Tu Do on 12.06.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

// This implementation is from [CombineExt](https://github.com/CombineCommunity/CombineExt)
final class ReplaySubject<Output, Failure: Error>: Subject {
    typealias Output = Output
    typealias Failure = Failure

    private let bufferSize: Int
    private var buffer = [Output]()

    private(set) var subscriptions = [Subscription<AnySubscriber<Output, Failure>>]()

    private var completion: Subscribers.Completion<Failure>?
    private var isActive: Bool { completion == nil }

    private let lock = NSRecursiveLock()

    init(bufferSize: Int) {
        self.bufferSize = bufferSize
    }

    func send(_ value: Output) {
        let subscriptions: [Subscription<AnySubscriber<Output, Failure>>]

        do {
          lock.lock()
          defer { lock.unlock() }

          guard isActive else { return }

          buffer.append(value)
          if buffer.count > bufferSize {
            buffer.removeFirst()
          }

          subscriptions = self.subscriptions
        }

        subscriptions.forEach { $0.forwardValueToBuffer(value) }
    }

    func send(completion: Subscribers.Completion<Failure>) {
        let subscriptions: [Subscription<AnySubscriber<Output, Failure>>]

        do {
            lock.lock()
            defer { lock.unlock() }

            guard isActive else { return }

            self.completion = completion

            subscriptions = self.subscriptions
        }

        subscriptions.forEach { $0.forwardCompletionToBuffer(completion) }
    }

    func send(subscription: Combine.Subscription) {
        subscription.request(.unlimited)
    }

    func receive<Subscriber: Combine.Subscriber>(subscriber: Subscriber) where Failure == Subscriber.Failure, Output == Subscriber.Input {
        let subscriberIdentifier = subscriber.combineIdentifier

        let subscription = Subscription(downstream: AnySubscriber(subscriber)) { [weak self] in
            self?.completeSubscriber(withIdentifier: subscriberIdentifier)
        }

        let buffer: [Output]
        let completion: Subscribers.Completion<Failure>?

        do {
            lock.lock()
            defer { lock.unlock() }

            subscriptions.append(subscription)

            buffer = self.buffer
            completion = self.completion
        }

        subscriber.receive(subscription: subscription)
        subscription.replay(buffer, completion: completion)
    }

    private func completeSubscriber(withIdentifier subscriberIdentifier: CombineIdentifier) {
        lock.lock()
        defer { self.lock.unlock() }

        self.subscriptions.removeAll { $0.innerSubscriberIdentifier == subscriberIdentifier }
    }
}

extension ReplaySubject {
    final class Subscription<Downstream: Subscriber>: Combine.Subscription where Output == Downstream.Input, Failure == Downstream.Failure {
        private var demandBuffer: DemandBuffer<Downstream>?
        private var cancellationHandler: (() -> Void)?

        fileprivate let innerSubscriberIdentifier: CombineIdentifier

        init(downstream: Downstream, cancellationHandler: (() -> Void)?) {
            self.demandBuffer = DemandBuffer(subscriber: downstream)
            self.innerSubscriberIdentifier = downstream.combineIdentifier
            self.cancellationHandler = cancellationHandler
        }

        func replay(_ buffer: [Output], completion: Subscribers.Completion<Failure>?) {
            buffer.forEach(forwardValueToBuffer)

            if let completion = completion {
                forwardCompletionToBuffer(completion)
            }
        }

        func forwardValueToBuffer(_ value: Output) {
            _ = demandBuffer?.buffer(value: value)
        }

        func forwardCompletionToBuffer(_ completion: Subscribers.Completion<Failure>) {
            demandBuffer?.complete(completion: completion)
            cancel()
        }

        func request(_ demand: Subscribers.Demand) {
            _ = demandBuffer?.demand(demand)
        }

        func cancel() {
            cancellationHandler?()
            cancellationHandler = nil

            demandBuffer = nil
        }
    }
}
