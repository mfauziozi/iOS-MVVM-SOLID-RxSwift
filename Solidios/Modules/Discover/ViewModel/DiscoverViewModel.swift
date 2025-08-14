//
//  DiscoverViewModel.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 10/07/25.
//

import RxSwift
import RxCocoa

final class DiscoverViewModel {
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<Void>
        let loadNextPage: Observable<Void>
        let itemSelected: Observable<IndexPath>  // Changed from movieSelected to itemSelected
    }

    // MARK: - Output
    struct Output {
        let movies: Driver<[Movie]>
        let navigationTitle: Driver<String>
        let showMovieDetail: Driver<(movieId: Int, movies: [Movie])>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }

    private let genreId: Int
    private let genreName: String?
    private let apiService: MovieAPIServiceProtocol
    private let disposeBag = DisposeBag()

    // Internal state
    private let currentPage = BehaviorRelay<Int>(value: 1)
    private let totalPages = BehaviorRelay<Int>(value: 1)
    private let moviesSubject = BehaviorRelay<[Movie]>(value: [])

    init(genreId: Int,
         genreName: String? = nil,
         apiService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.genreId = genreId
        self.genreName = genreName
        self.apiService = apiService
    }

    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()

        // Initial load
        let initialLoad = input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<DiscoverResponse> in
                guard let self = self else { return Observable.empty() }
                self.currentPage.accept(1)
                return self.apiService.fetchDiscoverMovies(genreId: self.genreId, page: 1)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .share()

        // Load next page
        let nextPageLoad = input.loadNextPage
            .withLatestFrom(currentPage)
            .filter { [weak self] currentPage in
                guard let self = self else { return false }
                return currentPage < self.totalPages.value
            }
            .flatMapLatest { [weak self] currentPage -> Observable<DiscoverResponse> in
                guard let self = self else { return Observable.empty() }
                let nextPage = currentPage + 1
                self.currentPage.accept(nextPage)
                return self.apiService.fetchDiscoverMovies(genreId: self.genreId, page: nextPage)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .share()

        // Process responses
        Observable.merge(initialLoad, nextPageLoad)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.totalPages.accept(response.totalPages)

                if response.page == 1 {
                    self.moviesSubject.accept(response.movies)
                } else {
                    let currentMovies = self.moviesSubject.value
                    self.moviesSubject.accept(currentMovies + response.movies)
                }
            })
            .disposed(by: disposeBag)

        // Handle movie selection - now using itemSelected
        let showMovieDetail = input.itemSelected
            .withLatestFrom(moviesSubject.asObservable()) { indexPath, movies in
                return (movieId: movies[indexPath.row].movieId, movies: movies)
            }
            .asDriver(onErrorDriveWith: .empty())

        return Output(
            movies: moviesSubject.asDriver(onErrorJustReturn: []),
            navigationTitle: Driver.just(genreName ?? "Movies"),
            showMovieDetail: showMovieDetail,
            isLoading: activityIndicator.asDriver(),
            error: errorTracker.asDriver()
        )
    }
}
