//
//  HomeViewController.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//
import UIKit
import NVActivityIndicatorView

protocol HomeViewControllerDisplayLogic: AnyObject {
    func displayHomeClips(viewModel: HomeClipsListModels.HomeClips.ViewModel)
}

struct Podcast {
    var name: String
    var description: String
    var category: String
    var source: String
    var thumbnailImageUrl: String

    init(name: String, description: String, category: String, source: String, thumbnailImageUrl: String) {
        self.name = name
        self.description = description
        self.category = category
        self.source = source
        self.thumbnailImageUrl = thumbnailImageUrl
    }
}

class HomeViewController: UIViewController, HomeViewControllerDisplayLogic {

    var interactor: HomeClipsBusinessLogic?
    var router: (NSObjectProtocol & HomeClipsRouterRoutingLogic & HomeClipsDataPassing)?
    private var audioClips: [AudioClip] = []

    public let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.backgroundColor = .clear
        t.tableFooterView = UIView()
        t.separatorStyle = .singleLine
        t.separatorInset = .zero
        t.alwaysBounceVertical = true
        t.showsVerticalScrollIndicator = false
        t.sectionFooterHeight = 5
        t.contentOffset = .zero
        t.contentInsetAdjustmentBehavior = .never
        t.contentInset.top = -30
        t.contentInset.bottom = 30
        t.register(HomeClipsCell.self, forCellReuseIdentifier: "\(HomeClipsCell.self)")
        t.clipsToBounds = false
        return t
    }()
    
    var activityIndicator : NVActivityIndicatorView!
    
    private var drawerView: DrawerView!
    private let playerVC = PlayerViewController()

    // Pagination
    private var page: Int = 1
    private var per: Int = 20
    private var isLoaded: Bool = false
    private let emptyStateView = EmptyResultView(frame: .zero)

    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = HomeClipsInteractor()
        let presenter = HomeClipsPresenter()
        let router = HomeClipsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    private func setupProgressBar() {
        let xAxis = self.view.center.x
        let yAxis = self.view.center.y
        let frame = CGRect(x: (xAxis), y: (yAxis), width: 45, height: 45)
        activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.type = . ballScale // add your type
        activityIndicator.color = UIColor.brown // add your color
        self.view.addSubview(activityIndicator) // or use  webView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    public func showPlayer(withPosition position: DrawerPosition) {
        guard drawerView == nil else {
            drawerView.setPosition(position, animated: true)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            self?.setupDrawerView()
            self?.drawerView.setPosition(position, animated: true)
        }
    }

    private func buildMockData() {
        self.emptyStateView.isHidden = true
        
        let provider = Provider(id: 1, name: "AudioBoom  Phasellus vulputate massa sit amet sodales egestas ", logo: Logo(url: "https://avatars.githubusercontent.com/u/2936695?v=4"), isAdsAllowed: false)
        let provider1 = Provider(id: 2, name: "Dhoom 2", logo: Logo(url: "https://pbs.twimg.com/profile_images/1324334222950064130/KRpodGpz.jpg"), isAdsAllowed: false)
        let provider2 = Provider(id: 3, name: "Dhoom 3", logo: Logo(url: "https://www.indiewire.com/wp-content/uploads/2013/12/Dhoom-3.jpg"), isAdsAllowed: false)
        
        let podcast = AudioClip(id: 1, title: "Lorem Ipsum is simply dummy text",  uri: "https://audioboom.com/posts/7944518-this-weekend-with-gordon-deal-september-18-2021.mp3")
        podcast.provider = provider
        
        let podcast1 = AudioClip(id: 2, title: "Lorem Ipsum is simply dummy text",  uri: "https://audioboom.com/posts/7944518-this-weekend-with-gordon-deal-september-18-2021.mp3")
        podcast1.provider = provider1
        
        let podcast2 = AudioClip(id: 3, title: "Lorem Ipsum is simply dummy text",  uri: "https://audioboom.com/posts/7944518-this-weekend-with-gordon-deal-september-18-2021.mp3")
        podcast2.provider = provider2
        
    
        for _ in 1...5 {
            self.audioClips.append(podcast)
        }
        
        for _ in 1...5 {
            self.audioClips.append(podcast1)
        }
        
        for _ in 1...5 {
            self.audioClips.append(podcast2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.emptyStateView.isHidden = !self.audioClips.isEmpty
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.tableView.reloadData()
        })
    }


    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    func displayHomeClips(viewModel: HomeClipsListModels.HomeClips.ViewModel) {
//        self.emptyStateView.isHidden = true
//        DispatchQueue.main.async {
//            guard viewModel.errorDescription == nil else {
//                self.tableView.reloadData()
//                return
//            }
//            self.audioClips = viewModel.homeClips
//            self.isLoaded = true
//            self.tableView.reloadData()
//            self.emptyStateView.isHidden = !viewModel.homeClips.isEmpty
//        }
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressBar()

//        view.backgroundColor = UIColor(r: 246, g: 248, b: 250)
//        // Request the favorite audio clips
//        let requestHomeAudioClips = HomeClipsListModels.HomeClips.Request(page: page, per: per)
//        interactor?.fetchHomeClips(request: requestHomeAudioClips)
        

        // Setup views
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        emptyStateView.isHidden = true
        
        defineLayout()

        tableView.delegate = self
        tableView.dataSource = self

        updateCurrentPlayingUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.buildMockData()
        })
    }


    func defineLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant:20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
        
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    @objc private func updateCurrentPlayingUI() {
        DispatchQueue.main.async {
//            self.tableView.reloadData()
        }
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    // Scroll to end detector
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset

        guard distanceFromBottom < height else { return }
        guard isLoaded else { return }
        guard (page == 1 || (page) * per == audioClips.count) else { return }

        page += 1
        isLoaded = false

        // Request the audio clips in this category - with pagination
       
    }


}

extension HomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = audioClips.count
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(HomeClipsCell.self)", for: indexPath) as? HomeClipsCell else { fatalError() }
        let clip = audioClips[indexPath.row]
        cell.configure(image: clip.provider?.logo?.url ?? "" , title: clip.title, detailString: clip.infoString, alreadyPlayed: false, isPremium: false)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("selected indexpath ---->>> \(indexPath.row)")

    }
}

extension HomeViewController: DrawerViewDelegate {
    
    func drawer(_ drawerView: DrawerView, didTransitionTo position: DrawerPosition) {
        
    }
    
    func drawerDidMove(_ drawerView: DrawerView, drawerOffset: CGFloat) {
        
        let progress = (drawerOffset / drawerView.frame.size.height)
        guard progress > -1.5, progress < 1.5 else { return }
        
        playerVC.headerViewTop.constant = -(progress * 50)
        
        let alpha = 1.0 - (progress - 0.2)
        self.playerVC.minimisedView.alpha = alpha < 0.2 ? 0.0 : alpha
        self.playerVC.headerView.alpha = (progress - 0.2) < 0.8 ? (progress - 0.2) : 1.0
        self.playerVC.view.setNeedsLayout()
        self.playerVC.view.layoutIfNeeded()
        
        drawerView.cornerRadius = 10 * progress
        
    }
}

