//
//  JMCarouselView.swift
//  Listen-to-News
//
//  Created by Jakob Mikkelsen on 20/01/2020.
//  Copyright © 2020 Listen To News. All rights reserved.
//

import UIKit

class JMCarouselView: UIView, JMCarouselViewProtocol {
    
    weak var delegate: JMCarouselViewDelegate?
    public var currentIndex: Int = 0
    
    private var collectionViewLayout: SlipperyFlowLayout!
    private let collectionView: UICollectionView
    private let type: JMCarouselViewType
    
    private var viewModel: [JMCarouselViewItemViewModel]?
    
    // MARK: View lifecycle
    
    init(withType type: JMCarouselViewType) {
        self.type = type

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        switch type {
        case .imageCarousel:
            collectionView.clipsToBounds = true
            collectionView.isPagingEnabled = true
        case .cards:
            collectionView.clipsToBounds = false
            collectionView.isPagingEnabled = false
        case .playerQueue: break
        case .discoverAmbassadors:
            collectionView.clipsToBounds = false
            collectionView.isPagingEnabled = true
        }
        

        super.init(frame: .zero)
        
        // Setup UI
        self.backgroundColor = .clear
        self.addSubview(collectionView)
        
        // Define layout
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Setup collectionview
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.isDirectionalLockEnabled = true
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        // Register cells for collectionView
        self.collectionView.register(JMCarouselViewCardItem.self, forCellWithReuseIdentifier: "\(JMCarouselViewCardItem.self)")
        self.collectionView.register(JMCarouselViewImageItem.self, forCellWithReuseIdentifier: "\(JMCarouselViewImageItem.self)")
        self.collectionView.register(JMCarousselViewPlayerQueueItem.self, forCellWithReuseIdentifier: "\(JMCarousselViewPlayerQueueItem.self)")
        self.collectionView.register(HomeFeaturedCollectionViewCell.self, forCellWithReuseIdentifier: "\(HomeFeaturedCollectionViewCell.self)")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - JMCarouselViewProtocol
    
    func configure(withViewModel viewModel: [JMCarouselViewItemViewModel]?) {
        self.viewModel = viewModel
        self.collectionView.reloadData()
        
        if type == .playerQueue {
            self.collectionViewLayout = SlipperyFlowLayout.configureLayout(collectionView: collectionView, itemSize: CGSize(width: collectionView.bounds.size.height * 0.9, height: collectionView.bounds.size.height * 0.9), minimumLineSpacing: 15.0, highlightOption: .center(.normal))
            self.collectionViewLayout.invalidateLayout()
            self.collectionView.layoutIfNeeded()
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard type != .discoverAmbassadors else { return }
        
        // Draw drop shadow
        layer.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4.0)
        
    }
    
    func scrollToCell(withIndex index: Int) {
        self.currentIndex = index
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension JMCarouselView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch type {
        case .cards:
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        case .playerQueue:
            return .zero
        case .imageCarousel:
            return .zero
        case .discoverAmbassadors:
            return UIEdgeInsets(top: 0, left: 7.5, bottom: 0, right: 7.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch type {
        case .playerQueue:
            return 15.0
        case .cards:
            return 15
        case .imageCarousel:
            return 0.0
        case .discoverAmbassadors:
            return 15.0
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension JMCarouselView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cellViewModel = viewModel?[indexPath.item] else { return UICollectionViewCell() }
        
        switch type {
        case .cards:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(JMCarouselViewCardItem.self)", for: indexPath) as? JMCarouselViewCardItem else {
                fatalError()
            }
            cell.configure(withItemViewModel: cellViewModel)
            return cell
        case .imageCarousel:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(JMCarouselViewImageItem.self)", for: indexPath) as? JMCarouselViewImageItem else {
                fatalError()
            }
            cell.configure(withItemViewModel: cellViewModel)
            return cell
            
        case .playerQueue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(JMCarousselViewPlayerQueueItem.self)", for: indexPath) as? JMCarousselViewPlayerQueueItem else {
                fatalError()
            }
            cell.configure(withItemViewModel: cellViewModel)
            return cell
        case .discoverAmbassadors:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HomeFeaturedCollectionViewCell.self)", for: indexPath) as? HomeFeaturedCollectionViewCell else {
                fatalError()
            }
            cell.configure(withItemViewModel: cellViewModel)
            return cell
        }
    }
    
}


// MARK: - UICollectionViewDelegate

extension JMCarouselView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(type, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let count = viewModel?.count, indexPath.item == count - 2 else { return }
        delegate?.didScrollToEnd(type)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch type {
        case .imageCarousel:
            return collectionView.bounds.size
        case .cards:
            return CGSize(width: 125, height: 85)
        case .playerQueue:
            return CGSize(width: collectionView.bounds.size.height * 0.9, height: collectionView.bounds.size.height * 0.9)
        case .discoverAmbassadors:
            let frameSize = collectionView.frame.size
            return CGSize(width: frameSize.width - 15, height: frameSize.height)
        }
    }
}


// MARK: - UIScrollViewDelegate

extension JMCarouselView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard type == .playerQueue else {
            let currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
            currentIndex = currentPage
            delegate?.didScrollToPage(currentPage)
            return
        }

        guard collectionViewLayout != nil else { return }
        let itemPage = collectionViewLayout.itemSize.width + collectionViewLayout.minimumLineSpacing
        let initialOffset = collectionViewLayout.initialOffset
        let currentPage = Int((scrollView.contentOffset.x + scrollView.contentInset.left + ((itemPage) / 2 ) + initialOffset) / (itemPage))
        currentIndex = currentPage
        delegate?.didScrollToPage(currentPage)
        
    }
}

