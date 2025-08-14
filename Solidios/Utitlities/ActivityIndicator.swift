//
//  ActivityIndicator.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import RxSwift
import RxCocoa

public final class ActivityIndicator: SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay(value: false)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    public init() {
        _loading = _relay.asDriver()
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onSubscribe: {
                self.sendStartLoading()
            }, onDispose: {
                self.sendStopLoading()
            })
    }

    private func sendStartLoading() {
        _lock.lock()
        _relay.accept(true)
        _lock.unlock()
    }

    private func sendStopLoading() {
        _lock.lock()
        _relay.accept(false)
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}
