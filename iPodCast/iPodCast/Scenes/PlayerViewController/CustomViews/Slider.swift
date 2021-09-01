
import UIKit

class Slider: UISlider {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialise()
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 4
        return newBounds
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        return super.thumbRect(forBounds:
                                CGRect(x: bounds.minX, y: bounds.minY, width: 5, height: 5), trackRect: rect, value: value)
    }
    
    private func initialise() {
        minimumValue = 0.00
        maximumValue = 1.00
        
        tintColor = UIColor.white
        minimumTrackTintColor = UIColor.white
        maximumTrackTintColor = UIColor(white: 0.95, alpha: 1.0)
        
        setThumbImage(#imageLiteral(resourceName: "icon_slider_thumb").withRenderingMode(.alwaysTemplate), for: .normal)
        setThumbImage(#imageLiteral(resourceName: "icon_slider_thumb").withRenderingMode(.alwaysTemplate), for: .disabled)
        
        clipsToBounds = false
    }
}
