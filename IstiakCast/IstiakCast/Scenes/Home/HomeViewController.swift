//
//  HomeViewController.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

protocol HomeViewControllerDisplayLogic: AnyObject {
    func displayHomeClips(viewModel: HomeClipsListModels.HomeClips.ViewModel)
}

class HomeViewController: UIViewController, HomeViewControllerDisplayLogic {
    
    var interactor: HomeClipsBusinessLogic?
    var router: (NSObjectProtocol & HomeClipsRouterRoutingLogic & HomeClipsDataPassing)?
    private var audioClips: [Clip] = []
    
    public let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.backgroundColor = .clear
        t.tableFooterView = UIView()
        t.separatorStyle = .none
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
    
    // Pagination
    private var page: Int = 1
    private var per: Int = 20
    private var isLoaded: Bool = false

    
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
        DispatchQueue.main.async {
            self.audioClips = viewModel.homeClips
            self.isLoaded = true
            self.tableView.reloadData()
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = UIColor(r: 246, g: 248, b: 250)

        // Request the favorite audio clips
        let requestHomeAudioClips = HomeClipsListModels.HomeClips.Request(page: page, per: per)
        interactor?.fetchHomeClips(request: requestHomeAudioClips)
        
        // Setup views
        view.addSubview(tableView)
    
        
        defineLayout()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        updateCurrentPlayingUI()
    }

    
    func defineLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant:20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @objc private func updateCurrentPlayingUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        
        cell.configure(image: "", title: clip.title, detailString: clip.body, alreadyPlayed: false, isPremium: false)
        
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
