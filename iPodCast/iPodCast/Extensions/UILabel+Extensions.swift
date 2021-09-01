

import UIKit

extension UILabel {
    
    func setLetterSpacing(_ spacing: CGFloat) {
        guard let text = self.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
    
    func setLineHeight(_ lineHeight: CGFloat = 1.0) {
        guard let text = self.text else { return }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        style.maximumLineHeight = lineHeight
        style.minimumLineHeight = lineHeight
        self.attributedText = NSAttributedString(string: text,
                                                 attributes: [NSAttributedString.Key.paragraphStyle: style])
    }
}

class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
