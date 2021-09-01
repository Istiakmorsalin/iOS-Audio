//
//  JMCarouselViewCardItem.swift
//  Listen-to-News
//
//  Created by Jakob Mikkelsen on 20/01/2020.
//  Copyright © 2020 Listen To News. All rights reserved.
//

import UIKit

class JMCarouselViewCardItem: UICollectionViewCell {

    // MARK: - ViewModel for this JMCarouselViewItem
    struct ViewModel: JMCarouselViewItemViewModel {
        let title: String
        let titleBackgroundColor: UIColor
        let imageURL: URL
        let alpha: CGFloat
    }
    
    private var imageView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.backgroundColor = UIColor(red: 217 / 255.0, green: 217 / 255.0, blue: 217 / 255.0, alpha: 1.0)
        i.contentMode = .scaleAspectFill
        i.clipsToBounds = true
        return i
    }()
    
    private var titleView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = UIColor.black
        return v
    }()
    
    private var titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = l.font.withSize(16)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = .clear
        return l
    }()
    
    private var position: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .white
        
        // Add subviews
        contentView.addSubview(imageView)
        contentView.addSubview(titleView)
        titleView.addSubview(titleLabel)
        
        // Define layout
        defineLayout()
        
    }
    
    private func defineLayout() {
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        titleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleView.widthAnchor.constraint(greaterThanOrEqualTo: titleLabel.widthAnchor, constant: 15).isActive = true
    
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -10).isActive = true
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Draw drop shadow
        contentView.layer.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
        contentView.layer.shadowRadius = 8.0
        contentView.layer.shadowOpacity = 0.45
        contentView.layer.shadowOffset = CGSize(width: 0, height: 8.0)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        titleView.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - RadioStationCellItemProtocol

extension JMCarouselViewCardItem: JMCarouselViewItemProtocol {
    
    func configure(withItemViewModel viewModel: JMCarouselViewItemViewModel) {
        guard let viewModel = viewModel as? ViewModel else {
            fatalError("The '\(self)' was configured with a wrong 'JMCarouselViewItemViewModel'")
        }
        
        titleLabel.text = viewModel.title
        titleView.backgroundColor = viewModel.titleBackgroundColor
        imageView.loadImage(fromURL: viewModel.imageURL)
        alpha = viewModel.alpha
        
        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
}

extension UIImageView {
    func loadImage(fromURL url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
