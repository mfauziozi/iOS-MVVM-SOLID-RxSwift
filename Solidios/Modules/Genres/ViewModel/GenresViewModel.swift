//
//  GenresViewModel.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import RxSwift
import RxCocoa
import RxDataSources

final class GenresViewModel {
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<Void>
        let genreSelected: Observable<Genre>
        let loadNextPage: Observable<Void> // Changed to Void since we're not using page numbers
    }

    // MARK: - Output
    struct Output {
        let sections: Driver<[GenreSection]> // Sectioned data
        let navigationTitle: Driver<String>
        let showDiscoveries: Driver<Genre> // Simplified to just pass Genre
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }

    private let apiService: MovieAPIServiceProtocol
    private let disposeBag = DisposeBag()

    // Section type alias
    typealias GenreSection = SectionModel<String, Genre>

    init(apiService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.apiService = apiService
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()

        // Fetch and transform genres into sections
        let sections = input.viewDidLoad
            .flatMapLatest { [unowned self] _ in
                return self.apiService.fetchGenres()
                    .map { $0 } // Extract [Genre] from GenresResponse
                    .map { genres -> [GenreSection] in
                        // Group genres by first letter (customize as needed)
                        let grouped = Dictionary(grouping: genres, by: { String($0.name.prefix(1).uppercased()) })
                        return grouped.map { key, values in
                            GenreSection(model: key, items: values.sorted(by: { $0.name < $1.name }))
                        }
                        .sorted(by: { $0.model < $1.model }) // Sort sections alphabetically
                    }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: [])

        let navigationTitle = Driver.just("Genres")

        let showDiscoveries = input.genreSelected
            .asDriver(onErrorDriveWith: .never())

        return Output(
            sections: sections,
            navigationTitle: navigationTitle,
            showDiscoveries: showDiscoveries,
            isLoading: activityIndicator.asDriver(),
            error: errorTracker.asDriver()
        )
    }
}
