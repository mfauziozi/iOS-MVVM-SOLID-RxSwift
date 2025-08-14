//
//  ErrorTracker.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import RxSwift
import RxCocoa

public final class ErrorTracker: SharedSequenceConvertibleType {
    public typealias Element = Error
    public typealias SharingStrategy = DriverSharingStrategy

    private let _subject = PublishSubject<Error>()

    public init() {}

    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable()
            .catch { [weak self] error in
                self?._subject.onNext(error)
                return Observable.empty()
            }
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _subject.asDriver(onErrorDriveWith: .never())
    }
}

extension ObservableConvertibleType {
    public func trackError(_ errorTracker: ErrorTracker) -> Observable<Element> {
        return errorTracker.trackError(from: self)
    }
}
