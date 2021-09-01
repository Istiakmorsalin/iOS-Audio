//
//  HomeClipsHeaderView.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

class HomeClipsHeaderView: UIView {

    private let horizontalStackView: UIStackView = {
        let s = UIStackView(frame: .zero)
        s.axis = .horizontal
        s.spacing = 5
        s.distribution = .fill
        s.alignment = .center
        return s
    }()
    
    private let imageView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.clipsToBounds = true
        return i
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        return l
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add subviews
        addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(imageView)
        horizontalStackView.addArrangedSubview(titleLabel)
        
        // Define layout
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        horizontalStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        horizontalStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        horizontalStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withTitle title: String, image: UIImage?) {
        titleLabel.text = title
        imageView.image = image
    }
    
}
