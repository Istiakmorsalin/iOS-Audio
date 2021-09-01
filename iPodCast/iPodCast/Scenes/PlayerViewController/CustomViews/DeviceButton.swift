//import UIKit
//import GoogleCast
//import SnapKit
//
//class DeviceButton: UIButton {
//
//    private let castButton: GCKUICastButton = {
//        let castButton = GCKUICastButton(frame: .zero)
//        castButton.translatesAutoresizingMaskIntoConstraints = false
//        castButton.tintColor = UIColor.black
//        castButton.isUserInteractionEnabled = false
//        return castButton
//    }()
//
//    private let speakerButton: UIButton = {
//        let b = UIButton(frame: .zero)
//        b.contentMode = .scaleAspectFit
//        b.isUserInteractionEnabled = false
//        return b
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        prepareViewHierarchy()
//        defineLayout()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func prepareViewHierarchy() {
//        addSubview(castButton)
//        addSubview(speakerButton)
//    }
//
//    func defineLayout() {
//
////        castButton.snp.makeConstraints { maker in
////            maker.top.bottom.leading.trailing.equalToSuperview()
////        }
////
////        speakerButton.snp.makeConstraints { maker in
////            maker.top.bottom.leading.trailing.equalToSuperview()
////        }
//
//    }
//
//    func setDeviceTint(color: UIColor) {
//        castButton.tintColor = color
//    }
//
//    func switchToChromeCast() {
//        speakerButton.alpha = 0.0
//        sendSubviewToBack(speakerButton)
//        castButton.alpha = 1.0
//        speakerButton.setImage(nil, for: .normal)
//    }
//
//    func switchToLocal(icon: String) {
//        castButton.alpha = 0
//        sendSubviewToBack(castButton)
//        speakerButton.alpha = 1.0
//
//        speakerButton.setImage(
//            UIImage(named: icon),
//            for: .normal
//        )
//
//    }
//
//}
