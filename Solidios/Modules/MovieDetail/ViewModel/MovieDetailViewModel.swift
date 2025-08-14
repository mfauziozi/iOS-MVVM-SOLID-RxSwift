//
//  MovieDetailViewModel.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 15/07/25.
//

import RxSwift
import RxCocoa

final class MovieDetailViewModel {
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<Void>
    }

    // MARK: - Output
    struct Output {
        let movieDetail: Driver<MovieDetailsResponse>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }

    private let movieId: Int
    private let apiService: MovieAPIServiceProtocol
    private let disposeBag = DisposeBag()

    init(movieId: Int, apiService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.movieId = movieId
        self.apiService = apiService
    }

    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()

        let movieDetail = input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<MovieDetailsResponse> in
                guard let self = self else { return Observable.empty() }
                return self.apiService.fetchMovieDetails(movieId: self.movieId)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .asDriver(onErrorDriveWith: .empty())

        let isLoading = activityIndicator.asDriver()
        let error = errorTracker.asDriver()

        return Output(
            movieDetail: movieDetail,
            isLoading: isLoading,
            error: error
        )
    }
}
