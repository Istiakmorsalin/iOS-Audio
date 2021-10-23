import UIKit

class PlayerProgressView: UIView {

    let progressView: Slider = {
        let p = Slider(frame: .zero)
        return p
    }()
    
    let leftProgressLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .lightGray
        l.font = l.font.withSize(13)
        l.textAlignment = .left
        l.text = "00:00"
        return l
    }()
    
    let rightProgressLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .lightGray
        l.font = l.font.withSize(13)
        l.textAlignment = .right
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(progressView)
        addSubview(leftProgressLabel)
        addSubview(rightProgressLabel)
        
        defineLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func defineLayout() {
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        leftProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        leftProgressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 0).isActive = true
        leftProgressLabel.leadingAnchor.constraint(equalTo: progressView.leadingAnchor).isActive = true
        leftProgressLabel.trailingAnchor.constraint(equalTo: rightProgressLabel.leadingAnchor).isActive = true
        leftProgressLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        leftProgressLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        rightProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        rightProgressLabel.topAnchor.constraint(equalTo: leftProgressLabel.topAnchor).isActive = true
        rightProgressLabel.leadingAnchor.constraint(equalTo: leftProgressLabel.trailingAnchor).isActive = true
        rightProgressLabel.trailingAnchor.constraint(equalTo: progressView.trailingAnchor).isActive = true
        rightProgressLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        rightProgressLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightProgressLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
    }

    func configure(progress: Float) {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 1.0) {
                if progress > 0.0 {
                    self?.progressView.setValue(progress, animated: true)
                } else {
                    self?.progressView.setValue(0, animated: false)
                }
            }
        }
    }
    
    public func configure(progressInMinutesSeconds: String) {
        DispatchQueue.main.async { [weak self] in
            self?.leftProgressLabel.text = progressInMinutesSeconds
        }
    }
    
    public func configure(duration: String) {
        DispatchQueue.main.async { [weak self] in
            self?.rightProgressLabel.text = duration
        }
    }
    
}
