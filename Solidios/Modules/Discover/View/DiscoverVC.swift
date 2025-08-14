//
//  DiscoverVC.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 10/07/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DiscoverVC: UIViewController {
    private let viewModel: DiscoverViewModel
    private let disposeBag = DisposeBag()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let itemWidth = (UIScreen.main.bounds.width - 48) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MovieCollectionCell.self, forCellWithReuseIdentifier: MovieCollectionCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let moviesRelay = BehaviorRelay<[Movie]>(value: [])

    init(genreId: Int, genreName: String?) {
        self.viewModel = DiscoverViewModel(genreId: genreId, genreName: genreName)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupBindings() {
        // Create the load next page signal
        let reachedBottom = collectionView.rx.contentOffset
            .map { [weak self] offset in
                guard let self = self else { return false }
                let visibleHeight = self.collectionView.frame.height
                let contentHeight = self.collectionView.contentSize.height
                let offsetY = offset.y
                return offsetY > contentHeight - visibleHeight * 2
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in () }

        // Create input
        let input = DiscoverViewModel.Input(
            viewDidLoad: Observable.just(()),
            loadNextPage: reachedBottom,
            itemSelected: collectionView.rx.itemSelected.asObservable()
        )

        // Transform to get outputs
        let output = viewModel.transform(input: input)

        // Bind movies to collection view
        output.movies
            .drive(collectionView.rx.items(
                cellIdentifier: MovieCollectionCell.identifier,
                cellType: MovieCollectionCell.self
            )) { row, movie, cell in
                cell.title.text = movie.movieTitle
                cell.setData(imageURL: "https://image.tmdb.org/t/p/w500\(movie.movieImageUrl)")
            }
            .disposed(by: disposeBag)

        // Update moviesRelay when new movies arrive
        output.movies
            .drive(onNext: { [weak self] movies in
                self?.moviesRelay.accept(movies)
            })
            .disposed(by: disposeBag)

        // Other bindings remain the same...
        output.navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)

        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        output.showMovieDetail
            .drive(onNext: { [weak self] movieId, _ in
                let vc = MovieDetailsVC(movieId: movieId)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        output.error
            .drive(onNext: { [weak self] error in
                let alert = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
