//
//  MovieDetailVC.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 15/07/25.
//

import RxSwift
import RxCocoa
import UIKit
import SnapKit
import Kingfisher

class MovieDetailsVC: UIViewController {
    private let viewModel: MovieDetailViewModel
    private let disposeBag = DisposeBag()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()

    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    private let poster: UIImageView = {
        let p = UIImageView()
        p.backgroundColor = UIColor.clear
        p.contentMode = .scaleAspectFill
        p.layer.cornerRadius = 10.0
        p.clipsToBounds = true
        return p
    }()

    private let movieTitle = UILabel()
    private let movieOverview = UILabel()
    private let movieRating = UILabel()
    private let movieGenres = UILabel()
    private let starImage = UIImageView()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(movieId: Int, viewModel: MovieDetailViewModel = MovieDetailViewModel(movieId: 0)) {
        self.viewModel = MovieDetailViewModel(movieId: movieId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground

        setupViews()
        setupConstraints()
        bindViewModel()
    }

    private func bindViewModel() {
        let input = MovieDetailViewModel.Input(
            viewDidLoad: Observable.just(())
        )

        let output = viewModel.transform(input: input)

        output.movieDetail
            .drive(onNext: { [weak self] details in
                self?.updateUI(with: details)
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        output.error
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }

    private func updateUI(with movieDetails: MovieDetailsResponse) {
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(movieDetails.movieImageUrl)")

        movieTitle.text = movieDetails.movieTitle
        movieOverview.text = movieDetails.movieOverview
        poster.kf.setImage(with: url)
        movieRating.text = String(format: "%.1f", movieDetails.voteAverage)
        movieGenres.text = movieDetails.genres.map { $0.name }.joined(separator: ", ")
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)

        // Add loading indicator
        view.addSubview(loadingIndicator)

        // Configure labels
        movieTitle.font = .boldSystemFont(ofSize: 24)
        movieRating.font = .boldSystemFont(ofSize: 20)
        movieRating.textColor = .white
        movieGenres.font = .systemFont(ofSize: 20)
        movieGenres.textColor = .gray
        movieOverview.font = .systemFont(ofSize: 14)
        movieOverview.numberOfLines = 0

        starImage.image = UIImage(named: "ic_star")

        // Add arranged subviews
        scrollStackViewContainer.addArrangedSubview(poster)
        scrollStackViewContainer.addArrangedSubview(movieTitle)
        scrollStackViewContainer.addArrangedSubview(movieGenres)
        scrollStackViewContainer.addArrangedSubview(movieOverview)

        // Add subviews that need custom constraints
        scrollStackViewContainer.addSubview(movieRating)
        scrollStackViewContainer.addSubview(starImage)

        // Add empty spacer view at the bottom
        let spacerView = UIView()
        spacerView.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        scrollStackViewContainer.addArrangedSubview(spacerView)
    }

    private func setupConstraints() {
        let margins = view.layoutMarginsGuide

        // Scroll View Constraints
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalTo(margins.snp.top)
            make.bottom.equalTo(margins.snp.bottom)
        }

        // Scroll Stack View Container Constraints
        scrollStackViewContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width) // This prevents horizontal scrolling
        }

        // Loading Indicator Constraints
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // Poster Constraints
        poster.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().inset(14)
            make.height.equalTo(500)
        }

        // Movie Title Constraints
        movieTitle.snp.makeConstraints { make in
            make.top.equalTo(poster.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(14)
        }

        // Star Image and Rating Container
        let ratingContainer = UIView()
        scrollStackViewContainer.addSubview(ratingContainer)
        ratingContainer.snp.makeConstraints { make in
            make.top.equalTo(poster.snp.bottom).offset(-28)
            make.trailing.equalToSuperview().inset(14)
        }

        // Star Image Constraints
        ratingContainer.addSubview(starImage)
        starImage.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(22)
        }

        // Movie Rating Constraints
        ratingContainer.addSubview(movieRating)
        movieRating.snp.makeConstraints { make in
            make.leading.equalTo(starImage.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(starImage.snp.centerY)
        }

        // Movie Genres Constraints
        movieGenres.snp.makeConstraints { make in
            make.top.equalTo(movieTitle.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(14)
        }

        // Movie Overview Constraints
        movieOverview.snp.makeConstraints { make in
            make.top.equalTo(movieGenres.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(14)
        }

        // This ensures content doesn't exceed screen width
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
    }
}
