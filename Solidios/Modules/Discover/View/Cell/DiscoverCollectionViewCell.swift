//
//  DiscoverCollectionViewCell.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 15/07/25.
//

import Kingfisher
import SnapKit
import UIKit

class MovieCollectionCell: UICollectionViewCell {
    static let identifier = "MovieCollectionCell"
    
    let stackView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis  = .vertical
        stackview.alignment = .center
        stackview.distribution = .fillProportionally
        return stackview
    }()

    var image = UIImageView()

    var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()

    var title: UILabel = {
        var title = UILabel()
        title.textColor = .label
        title.textAlignment = .center
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 2
        title.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return title
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        addViews()
    }

    func addViews() {

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }

        stackView.addArrangedSubview(image)
//        image.backgroundColor = UIColor.red
        image.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.height.equalTo(contentView.frame.height - 50)
            make.width.equalTo(contentView.frame.width)
        }

        stackView.addArrangedSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(contentView.frame.width)
        }

        titleView.addSubview(title)
        title.snp.makeConstraints { make in
            make.width.equalTo(titleView)
            make.centerX.centerY.equalTo(titleView)
        }

    }

    func setData(imageURL: String) {
        self.image.kf.setImage(with: URL(string: imageURL))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
