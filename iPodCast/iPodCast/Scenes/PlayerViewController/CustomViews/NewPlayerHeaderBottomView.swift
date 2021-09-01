//
//  NewPlayerHeaderBottomView.swift
//  Listen-to-News
//
//  Created by Jakob Mikkelsen on 19/06/2019.
//  Copyright © 2019 Listen To News. All rights reserved.
//

import UIKit

class NewPlayerHeaderBottomView: UIView {
    
    struct ViewModel {
        let rightButtonImage: UIImage?
        let leftButtonImage: UIImage?
        let titleText: String?
        let titleColor: UIColor?
    }
    
    let leftButton: UIButton = {
        let b = UIButton(frame: .zero)
        return b
    }()
    
    /* TODO:
    let leftCastButton: GCKUICastButton = {
        let b = GCKUICastButton(frame: .zero)
        b.tintColor = UIColor.lightGray
        return b
    }()*/
    
    private let titleLabel: EdgeInsetLabel = {
        let l = EdgeInsetLabel(frame: .zero)
        l.font = l.font.withSize(20)
        l.textAlignment = .center
        l.textInsets = .init(top: 2, left: 15, bottom: 2, right: 15)
        l.layer.cornerRadius = 13.0
        l.layer.borderWidth = 1.0
        l.layer.borderColor = UIColor.clear.cgColor
        return l
    }()
    
    let rightButton: UIButton = {
        let b = UIButton(frame: .zero)
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        // Add subviews
        addSubview(leftButton)
//        addSubview(leftCastButton)
        addSubview(titleLabel)
        addSubview(rightButton)
        
        // leftCastButton.alpha = 0.0
        
        // Define layout
        defineLayout()
        
        // Make touch surface greater
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        leftButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
    }
    
    func defineLayout() {
        
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        leftButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        leftButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
//        leftCastButton.translatesAutoresizingMaskIntoConstraints = false
//        leftCastButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 0).isActive = true
//        leftCastButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
//        leftCastButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
//        leftCastButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        rightButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    public func configure(withViewModel viewModel: ViewModel) {
        titleLabel.text = viewModel.titleText
        titleLabel.textColor = viewModel.titleColor
        titleLabel.layer.borderColor = viewModel.titleColor?.cgColor
        
        leftButton.setImage(viewModel.leftButtonImage, for: .normal)
        rightButton.setImage(viewModel.rightButtonImage, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
