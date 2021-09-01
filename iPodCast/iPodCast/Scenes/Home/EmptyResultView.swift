//
//  EmptyResultView.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

protocol EmptyResultViewProtocol {
    func configure(title: String, description: String)
}

class EmptyResultView: UIView {
    
    private let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .black
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        return l
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .darkGray
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        defineLayout()
    }
    
    func defineLayout() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EmptyResultView: EmptyResultViewProtocol {
    func configure(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}

