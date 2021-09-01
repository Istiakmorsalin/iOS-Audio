//
//  HomeFeaturedCollectionViewCell.swift
//  Listen-to-News
//
//  Created by Jakob Mikkelsen on 10/06/2020.
//  Copyright © 2020 Listen to news. All rights reserved.
//

import UIKit

class HomeFeaturedCollectionViewCell: UICollectionViewCell, JMCarouselViewItemProtocol {
    
    // MARK: - ViewModel for this JMCarouselViewItem
    struct ViewModel: JMCarouselViewItemViewModel {
        let titleString: String
        let detailString: String?
        let imageURL: URL?
        let isPremium: Bool
        let isShowingBadge: Bool
    }
    
    private let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .black
        l.adjustsFontSizeToFitWidth = true
        l.font = l.font.withSize(20)
        l.text = "something"
        l.numberOfLines = 0
        return l
    }()
    
    private let detailLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .darkGray
        l.adjustsFontSizeToFitWidth = true
        l.font = l.font.withSize(18)
        l.text = "Ambassadør"
        l.numberOfLines = 0
        return l
    }()
    
    private let premiumImageView: UIImageView = {
        let i = UIImageView(image: UIImage(named: "premium_small_icon"))
        i.contentMode = .scaleAspectFill
        i.isHidden = true
        return i
    }()
    
    public let imageView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.backgroundColor = .clear
        return i
    }()
    
    private let bottomCardView: UIView = {
        let i = UIView(frame: .zero)
        i.layer.cornerRadius = 10
        i.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        return i
    }()
    
    // MARK: - View lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        // Setup skeleton
        
        addSubview(bottomCardView)
        bringSubviewToFront(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(premiumImageView)
        
        defineLayout()
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    
    func defineLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        bottomCardView.translatesAutoresizingMaskIntoConstraints = false
        bottomCardView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        bottomCardView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 15).isActive = true
        bottomCardView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -15).isActive = true
        bottomCardView.centerYAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 45).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 15).isActive  = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.40).isActive = true
        titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40).isActive = true
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
     
        premiumImageView.translatesAutoresizingMaskIntoConstraints = false
        premiumImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 4).isActive = true
        premiumImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -4).isActive = true
        premiumImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        premiumImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Draw drop shadow
        self.layer.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        
        if rect.width == 290 {
            titleLabel.font = titleLabel.font.withSize(20)
        }
        
    }
    
    
    func configure(image: String, title: String, detailString: String?, isPremium: Bool) {
        titleLabel.text = title
        // detailLabel.text = detailString
        
        // premiumImageView.isHidden = !isPremium
        
        guard let imageURL = URL(string: image) else { return }
        imageView.kf.setImage(with: imageURL)
    }
    
    func configure(withItemViewModel viewModel: JMCarouselViewItemViewModel) {
        guard let viewModel = viewModel as? ViewModel else {
            fatalError("The '\(self)' was configured with a wrong 'JMCarouselViewItemViewModel'")
        }
        
        titleLabel.text = viewModel.titleString
        // detailLabel.text = viewModel.detailString
        // premiumImageView.isHidden = !viewModel.isPremium
        
        if viewModel.titleString == "IstiakCast" {
            imageView.kf.setImage(with: viewModel.imageURL)
            titleLabel.text = nil
            detailLabel.text = nil
            bottomCardView.isHidden = true
            imageView.setNeedsLayout()
            imageView.layoutIfNeeded()
        } else {
            imageView.kf.setImage(with: viewModel.imageURL)
            bottomCardView.isHidden = false
        }
        
//        if viewModel.isShowingBadge {
//            titleLabel.addBadgeToText()
//        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
