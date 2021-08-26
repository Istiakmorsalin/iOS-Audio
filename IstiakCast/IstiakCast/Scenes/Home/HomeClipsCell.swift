//
//  HomeClipsCell.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

protocol HomeClipsCellItemProtocol: AnyObject {
    func configure(image: String, title: String, detailString: String?, alreadyPlayed: Bool, isPremium: Bool)
    func setIsPlayingCurrent(_ bool: Bool)
}

class HomeClipsCell: UITableViewCell {
    
    private var detailLabelConstraint: NSLayoutConstraint!
    
    public let imgView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.backgroundColor = .white
        return i
    }()
    
    private let premiumImageView: UIImageView = {
        let i = UIImageView(image: UIImage(named: "premium_small_icon"))
        i.contentMode = .scaleAspectFill
        i.isHidden = true
        return i
    }()
    
    private let stackView: UIStackView = {
        let s = UIStackView(frame: .zero)
        s.axis = .vertical
        s.alignment = .top
        s.spacing = 3
        return s
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.clipsToBounds = true
        l.textColor = .black
        l.numberOfLines = 3
        return l
    }()
    
    private let detailLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.clipsToBounds = true
        
        l.adjustsFontSizeToFitWidth = true
        l.numberOfLines = 1
        return l
    }()
    
    private let languageImageView: UIImageView = {
        let i = UIImageView()
        i.isHidden = true
        return i
    }()
    
    private let detailLanguageView: UIView = {
        let v = UIView(frame: .zero)
        return v
    }()
    
    public let shareButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "icon_options"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()
    
        
    public var shareButtonAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(imgView)
        contentView.addSubview(premiumImageView)
        
        detailLanguageView.addSubview(languageImageView)
        detailLanguageView.addSubview(detailLabel)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLanguageView)
        contentView.addSubview(stackView)
        
        contentView.addSubview(shareButton)
        
        defineLayout()
        
        shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        
    }
    
    func defineLayout() {
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        imgView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -10).isActive = true
        stackView.centerYAnchor.constraint(equalTo: imgView.centerYAnchor).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        
        detailLanguageView.translatesAutoresizingMaskIntoConstraints = false
        detailLanguageView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        detailLanguageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 15).isActive = true
        
        languageImageView.translatesAutoresizingMaskIntoConstraints = false
        languageImageView.leadingAnchor.constraint(equalTo: detailLanguageView.leadingAnchor).isActive = true
        languageImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        languageImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        languageImageView.centerYAnchor.constraint(equalTo: detailLanguageView.centerYAnchor).isActive = true
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabelConstraint = detailLabel.leadingAnchor.constraint(equalTo: languageImageView.trailingAnchor, constant: -10)
        detailLabelConstraint.isActive = true
        detailLabel.trailingAnchor.constraint(equalTo: detailLanguageView.trailingAnchor, constant: 5).isActive = true
        detailLabel.heightAnchor.constraint(equalTo: detailLanguageView.heightAnchor).isActive = true
        detailLabel.centerYAnchor.constraint(equalTo: detailLanguageView.centerYAnchor).isActive = true
    
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        shareButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7.5).isActive = true
        shareButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true

        premiumImageView.translatesAutoresizingMaskIntoConstraints = false
        premiumImageView.topAnchor.constraint(equalTo: imgView.topAnchor, constant: 4).isActive = true
        premiumImageView.trailingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: -4).isActive = true
        premiumImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        premiumImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true

    }
    
    @objc private func shareAction() {
        shareButtonAction?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
        titleLabel.text = nil
        titleLabel.attributedText = nil
        languageImageView.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        
        imgView.layer.cornerRadius = 5
        
    }
}

extension HomeClipsCell: HomeClipsCellItemProtocol {

    func configure(image: String, title: String, detailString: String?, alreadyPlayed: Bool, isPremium: Bool) {
        
        titleLabel.text = title
        detailLabel.text = detailString
    
        detailLabelConstraint.constant = 5
        languageImageView.isHidden = false
        
    }
    
    func setIsPlayingCurrent(_ bool: Bool) {
       
        
    }
    
}
