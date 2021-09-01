import UIKit

class Overlay: UIView {

    private var _mask = CAShapeLayer()

    public var cornerRadius: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.clipsToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = CGMutablePath()

        _mask.frame = self.bounds

        var clipping = self.bounds
        clipping.origin.y = self.bounds.size.height - cornerRadius

        path.addRect(self.bounds)
        path.addRoundedRect(in: clipping, cornerWidth: cornerRadius, cornerHeight: cornerRadius)

        _mask.path = path
        _mask.fillRule = .evenOdd

        self.layer.mask = _mask
    }
}
