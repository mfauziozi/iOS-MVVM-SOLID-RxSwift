//
//  GenresVC.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class GenresVC: UIViewController {
    private let viewModel: GenresViewModel
    private let disposeBag = DisposeBag()

    // Define the data source type
    private var dataSource: RxTableViewSectionedReloadDataSource<GenresViewModel.GenreSection>!

    private lazy var genreTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(GenresTableViewCell.self, forCellReuseIdentifier: GenresTableViewCell.reuseIdentifier)
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()

    init(viewModel: GenresViewModel = GenresViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupUI()
        setupBindings()
    }

    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<GenresViewModel.GenreSection>(
            configureCell: { _, tableView, indexPath, genre in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: GenresTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as! GenresTableViewCell
                cell.configure(with: genre)
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
            }
        )

        // Make sure to set the delegate
        genreTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        genreTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        view.addSubview(genreTableView)
        genreTableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }

    private func setupBindings() {
        // Create input
        let input = GenresViewModel.Input(
            viewDidLoad: Observable.just(()),
            genreSelected: genreTableView.rx.modelSelected(Genre.self).asObservable(),
            loadNextPage: Observable.never() // Not implemented yet
        )

        // Transform input to output
        let output = viewModel.transform(input: input)

        // Bind sections to table view
        output.sections
            .drive(genreTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)

        output.showDiscoveries
            .drive(onNext: { [weak self] genre in
                let discoveriesVC = DiscoverVC(genreId: genre.id, genreName: genre.name)
                self?.navigationController?.pushViewController(discoveriesVC, animated: true)
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { isLoading in
                // Handle loading state if needed
                UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
            })
            .disposed(by: disposeBag)

        output.error
            .drive(onNext: { error in
                // Handle errors
                print("Error occurred: \(error.localizedDescription)")
                // You could show an alert here
            })
            .disposed(by: disposeBag)
    }
}

extension GenresVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 14
    }
}
