//
//  AddedToQueueView.swift
//  Listen-to-News
//
//  Created by Andrei Hogea on 23/11/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit

class AddedToQueueView: UIView {
    
    private let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.text = "Title"
        l.font = l.font.withSize(12)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        
        defineLayout()
    }
    
    private func defineLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
