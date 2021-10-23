import Foundation


// MARK: - Protocol for the items inside the carousel
protocol JMCarouselViewItemViewModel { }
protocol JMCarouselViewItemProtocol {
    func configure(withItemViewModel viewModel: JMCarouselViewItemViewModel)
}

// MARK: - Protocol of JMCarouselView
protocol JMCarouselViewProtocol {
    var currentIndex: Int { get }
    func configure(withViewModel viewModel: [JMCarouselViewItemViewModel]?)
    func scrollToCell(withIndex index: Int)
}

// MARK: - Delegate of the JMCarouselView
protocol JMCarouselViewDelegate: AnyObject {
    func didSelect(_ type: JMCarouselViewType, indexPath: IndexPath)
    func didScrollToPage(_ page: Int)
    func didScrollToEnd(_ type: JMCarouselViewType)
}

// MARK: - Types of the JMCarouselView
enum JMCarouselViewType {
    case imageCarousel
    case cards
    case discoverAmbassadors
    case playerQueue
}
