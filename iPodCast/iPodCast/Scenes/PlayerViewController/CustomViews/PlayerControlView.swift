
import UIKit


class PlayerControlView: UIView {

    private let contentView: UIView = UIView()
    
    private let verticalStackView: UIStackView = {
        let s = UIStackView(frame: .zero)
        s.alignment = UIStackView.Alignment.center
        s.distribution = UIStackView.Distribution.equalCentering
        s.axis = .vertical
        s.backgroundColor = .white
        s.spacing = 10
        return s
    }()
    
    private let firstHorizontalStackView: UIStackView = {
        let s = UIStackView(frame: .zero)
//      s.alignment = UIStackView.Alignment.center
        s.distribution = UIStackView.Distribution.equalSpacing
        s.axis = .horizontal
        s.backgroundColor = .white
        return s
    }()
    
    private let lastHorizontalstackView: UIStackView = {
        let s = UIStackView(frame: .zero)
        s.alignment = UIStackView.Alignment.center
        s.distribution = UIStackView.Distribution.equalSpacing
        s.axis = .horizontal
        s.backgroundColor = .white
        return s
    }()
    
    let previousButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "icon_previous"), for: .normal)
        return b
    }()
    
    let seekBackwardsButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "icon_rewind"), for: .normal)
        return b
    }()
    
    let playButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "play"), for: .normal)
        return b
    }()
    
    let seekForwardButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "icon_forward"), for: .normal)
        return b
    }()
    
    let nextButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "icon_next"), for: .normal)
        return b
    }()
    
    
    let speedControlButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "icon_speed_1.0x"), for: .normal)
        return b
    }()
    
//    let deviceButton: DeviceButton = {
//        let device = DeviceButton(frame:.zero)
//        device.setDeviceTint(color: .black)
//        device.translatesAutoresizingMaskIntoConstraints = false
//        return device
//    }()

    
    let addtoFavouriteButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "icon_unfavourite"), for: .normal)
        return b
    }()
    
    let queueButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.setImage(UIImage(named: "icon_show_queue"), for: .normal)
        return b
    }()
    
    public var isShowingFromQueue: Bool = false
    private var shadowLayer: CAShapeLayer!
    
    private var cornerRadius: CGFloat = 10.0
    private var fillColor: UIColor = .white // the color applied to the shadowLayer, rather than the view's backgroundColor
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard isShowingFromQueue else { return }
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.25
            shadowLayer.shadowRadius = 10
            layer.insertSublayer(shadowLayer, at: 0)
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareViewHierarchy()
        defineLayout()
        
    }
    
    func prepareViewHierarchy() {

        firstHorizontalStackView.addArrangedSubview(previousButton)
        firstHorizontalStackView.addArrangedSubview(seekBackwardsButton)
        firstHorizontalStackView.addArrangedSubview(playButton)
        firstHorizontalStackView.addArrangedSubview(seekForwardButton)
        firstHorizontalStackView.addArrangedSubview(nextButton)
        
        lastHorizontalstackView.addArrangedSubview(speedControlButton)
//        lastHorizontalstackView.addArrangedSubview(deviceButton)
        lastHorizontalstackView.addArrangedSubview(addtoFavouriteButton)
        lastHorizontalstackView.addArrangedSubview(queueButton)
        
        verticalStackView.addArrangedSubview(firstHorizontalStackView)
        verticalStackView.addArrangedSubview(lastHorizontalstackView)
        
        addSubview(verticalStackView)
    }
    
    func defineLayout() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        firstHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        lastHorizontalstackView.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        seekBackwardsButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        seekForwardButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        speedControlButton.translatesAutoresizingMaskIntoConstraints = false
//        deviceButton.translatesAutoresizingMaskIntoConstraints = false
        addtoFavouriteButton.translatesAutoresizingMaskIntoConstraints = false
        queueButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
            
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            verticalStackView.heightAnchor.constraint(equalToConstant: 150),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            firstHorizontalStackView.topAnchor.constraint(equalTo: verticalStackView.topAnchor,constant: 10),
            firstHorizontalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 21),
            firstHorizontalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -21),
            firstHorizontalStackView.heightAnchor.constraint(equalToConstant: 75),
            
            lastHorizontalstackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 55),
            lastHorizontalstackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -55),
            lastHorizontalstackView.heightAnchor.constraint(equalToConstant: 55),

//            previousButton.widthAnchor.constraint(equalToConstant: 45),
            previousButton.heightAnchor.constraint(equalToConstant: 45),
        
//            seekBackwardsButton.widthAnchor.constraint(equalToConstant: 45),
            seekBackwardsButton.heightAnchor.constraint(equalToConstant: 45),
            
            playButton.widthAnchor.constraint(equalToConstant: 75),
            playButton.heightAnchor.constraint(equalToConstant: 75),
            
//            seekForwardButton.widthAnchor.constraint(equalToConstant: 45),
            seekForwardButton.heightAnchor.constraint(equalToConstant: 45),
            
//            nextButton.widthAnchor.constraint(equalToConstant: 45),
            nextButton.heightAnchor.constraint(equalToConstant: 45),
            
            speedControlButton.widthAnchor.constraint(equalToConstant: 55),
     
//            deviceButton.widthAnchor.constraint(equalToConstant: 45),
//
            addtoFavouriteButton.widthAnchor.constraint(equalToConstant: 45),

            queueButton.widthAnchor.constraint(equalToConstant: 45),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        playButton.layer.cornerRadius = playButton.frame.size.width / 2
    }
    
    public func configure(isPlaying: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isPlaying {
                self?.playButton.setImage(UIImage(named: "pause"), for: .normal)
            } else {
                self?.playButton.setImage(UIImage(named: "play"), for: .normal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PlayerControlView {
    func switchToChromeCast() {
//        deviceButton.switchToChromeCast()
    }
    
    func switchToLocal(icon: String) {
//        deviceButton.switchToLocal(icon: icon)
    }
    
    func setPlayerSpeedIcon(icon: String) {
        DispatchQueue.main.async { [weak self] in
            self?.speedControlButton.setImage(UIImage(named: icon), for: .normal)
        }
    }
    
    func setPlayerFavouriteIcon(status: Bool) {
        DispatchQueue.main.async { [weak self] in
            if(status) {
                self?.addtoFavouriteButton.setImage(UIImage(named: "icon_favourite"), for: .normal)
            } else {
                self?.addtoFavouriteButton.setImage(UIImage(named: "icon_unfavourite"), for: .normal)
            }
        }
    }
}
