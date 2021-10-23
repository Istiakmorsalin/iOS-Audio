import UIKit

class JMCarouselViewImageItem: UICollectionViewCell {

    // MARK: - ViewModel for this JMCarouselViewItem
    struct ViewModel: JMCarouselViewItemViewModel {
        let title: String
        let image: UIImage?
        let imageURL: URL?
    }

    private let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        return l
    }()
    
    private var imageView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        // Add subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        
        // Define layout
        defineLayout()
        
    }
    
    private func defineLayout() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        
        if UIScreen.main.bounds.width != 320 {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - JMCarouselViewItemProtocol

extension JMCarouselViewImageItem: JMCarouselViewItemProtocol {
    
    func configure(withItemViewModel viewModel: JMCarouselViewItemViewModel) {
        guard let viewModel = viewModel as? ViewModel else {
            fatalError("The '\(self)' was configured with a wrong 'JMCarouselViewItemViewModel'")
        }
        
        // Setup the cell with the parsed viewModel
        self.titleLabel.text = viewModel.title
        
        if let image = viewModel.image {
            self.imageView.image = image
        } else if let imageURL = viewModel.imageURL {
            self.imageView.kf.setImage(with: imageURL)
        }
        
    }
    
}
