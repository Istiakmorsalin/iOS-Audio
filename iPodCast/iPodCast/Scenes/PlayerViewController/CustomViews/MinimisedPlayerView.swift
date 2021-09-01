//
//  MinimisedPlayerView.swift
//  Listen-to-News
//
//  Created by Andrei Hogea on 23/11/2018.
//  Copyright © 2018 Andrei Hogea. All rights reserved.
//

import UIKit
import SnapKit
//import GoogleCast


protocol MinimisedPlayerViewConfigurable: AnyObject {
    func configure(progress: Float)
    func configure(title: String?, description: String?, imageURL: URL?)
    func configure(isBuffering: Bool)
    func configure(isPlaying: Bool)
    func configure(isProviderClip: Bool)
}

// MARK: Jakob
class MinimisedPlayerView: UIView {
    
    private var activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .white)
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()
    
    private var titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = l.font.withSize(13)
        l.textColor = .white
        l.numberOfLines = 1
        return l
    }()
    
    private var descriptionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = l.font.withSize(11)
        l.textColor = .lightGray
        return l
    }()
    
//    private let deviceButton: DeviceButton = {
//        let device = DeviceButton(frame:.zero)
//        device.isUserInteractionEnabled = true
//        device.translatesAutoresizingMaskIntoConstraints = false
//        device.setDeviceTint(color: .white)
//        return device
//    }()
    
//    private let secondaryDeviceButton: DeviceButton = {
//        let device = DeviceButton(frame:.zero)
//        device.isUserInteractionEnabled = false
//        device.setDeviceTint(color: .gray)
//        device.translatesAutoresizingMaskIntoConstraints = false
//        return device
//    }()
    
    private var playButton: SVGPlayButton = {
        let b = SVGPlayButton(frame: .zero)
        b.pauseColor = .white
        b.playColor = .white
        return b
    }()
    
    private let imageView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.backgroundColor = .white
        i.contentMode = .scaleAspectFill
        i.clipsToBounds = true
        return i
    }()
    
    private let stackSecondaryContainer: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.spacing = 3
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let stackTextContainer: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let stackParentContainer: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.spacing = 9
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let stackPlayDeviceButtonContainer: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.spacing = 9
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var secondaryText : String? {
        didSet{
            updateDescription()
        }
    }
    
    private var deviceDescription: String? {
        didSet{
            updateDescription()
        }
    }
    
    // MARK: - Properties
    var playPauseAction: (() -> Void)?
    
    // MARK: - View
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layer.cornerRadius = 10
        clipsToBounds = true
        
        prepareViewHierarchy()
        defineLayout()
        
        configure(isBuffering: true)
        
        playButton.willPlay = { [weak self] in
            self?.playPauseAction?()
        }
        playButton.willPause = { [weak self] in
            self?.playPauseAction?()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareViewHierarchy() {
       
//        stackSecondaryContainer.addArrangedSubview(secondaryDeviceButton)
        stackSecondaryContainer.addArrangedSubview(descriptionLabel)
        stackTextContainer.addArrangedSubview(titleLabel)
        stackTextContainer.addArrangedSubview(stackSecondaryContainer)
        stackParentContainer.addArrangedSubview(imageView)
        stackParentContainer.addArrangedSubview(stackTextContainer)
//        stackPlayDeviceButtonContainer.addArrangedSubview(deviceButton)
        stackPlayDeviceButtonContainer.addArrangedSubview(playButton)
       
        addSubview(stackParentContainer)
        addSubview(stackPlayDeviceButtonContainer)
        addSubview(activityIndicator)
    }
    
    func defineLayout() {
        
        stackParentContainer.snp.makeConstraints { maker in
            maker.leading.top.bottom.equalToSuperview()
            maker.trailing.equalTo(stackPlayDeviceButtonContainer.snp.leading).offset(-9.0)
        }
        
        imageView.snp.makeConstraints { maker  in
            maker.height.equalToSuperview()
            maker.width.equalTo(imageView.snp.height)
        }
        
        stackPlayDeviceButtonContainer.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.trailing.equalToSuperview().inset(6)
        }
        
//        deviceButton.snp.makeConstraints { maker in
//            maker.width.equalTo(20)
//            maker.height.equalTo(20)
//        }
//        
//        secondaryDeviceButton.snp.makeConstraints { maker in
//            maker.width.equalTo(12)
//            maker.height.equalTo(12)
//        }
        
        playButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(6.0)
            maker.bottom.equalToSuperview().inset(6.0)
            maker.width.equalTo(playButton.snp.height)
        }
        
        activityIndicator.snp.makeConstraints { maker in
            maker.leading.trailing.top.bottom.equalTo(playButton)
        }

    }
    
}

// MARK: - MinimisedPlayerViewConfigurable

extension MinimisedPlayerView: MinimisedPlayerViewConfigurable {
    
    func configure(progress: Float) {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 1.15) {
                if progress != 0 {
                    self?.playButton.progressStrokeEnd = CGFloat(progress)
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()
                } else {
                    self?.playButton.resetProgressLayer()
                }
            }
        }
    }
    
    func configure(title: String?, description: String?, imageURL: URL?) {
        self.titleLabel.text = title ?? "Personlig liste"
        secondaryText = description
        self.imageView.kf.setImage(with: imageURL)
    }
    
    func configure(isBuffering: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.playButton.alpha = isBuffering ? 0.0 : 1.0
            if isBuffering {
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    func configure(isPlaying: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.playButton.playing = isPlaying
        }
    }
    
    func configure(isProviderClip: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.playButton.alpha = isProviderClip ? 0.0 : 1.0
        }
    }
    
    private func updateDescription() {
        if deviceDescription == nil {
            self.descriptionLabel.text = secondaryText
        } else {
            self.descriptionLabel.text = deviceDescription
        }
    }
    
    func addSpeakerTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
//        deviceButton.addTarget(target, action: action, for: controlEvents)
    }
    
    func setDeviceInfo(deviceIcon: String, deviceName: String?, secondaryIcon: String?, enableCastButton: Bool) {
       
//        if enableCastButton {
//            deviceButton.switchToChromeCast()
//            secondaryDeviceButton.switchToChromeCast()
//        } else {
//            deviceButton.switchToLocal(icon: deviceIcon)
//            secondaryDeviceButton.switchToLocal(icon: secondaryIcon ?? "")
//        }
//
//        deviceDescription = deviceName
//
//        secondaryDeviceButton.isHidden = deviceDescription == nil
    
    }
    
}
