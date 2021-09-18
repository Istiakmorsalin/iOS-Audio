
import UIKit


protocol PlayerDisplayLogic: AnyObject {
    func displaySomething(viewModel: Player.Something.ViewModel)
    func displayLinkedClip(viewModel: Player.LinkedClip.ViewModel)
}

class PlayerViewController: UIViewController, PlayerDisplayLogic {
    var interactor: PlayerBusinessLogic?
    var router: (NSObjectProtocol & PlayerRoutingLogic & PlayerDataPassing)?
//    private let deviceStateListener =  DeviceChangeListener()
    private var debounceTimer:Timer?
    
    public var drawerView: DrawerView! {
        didSet {
            // Update the view - drawer has been set
            view.backgroundColor = .white
        }
    }
    
    var hasTopNotch: Bool {
        guard let topPadding = UIApplication.shared.windows.first?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }
        
    // MARK: Player Minimised
    private(set) var minimisedView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = .clear
        
        // Draw drop shadow
        v.layer.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
        v.layer.shadowRadius = 5.0
        v.layer.shadowOpacity = 0.25
        v.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        
        return v
    }()
    
    private(set) var minimisedPlayer: MinimisedPlayerView = {
        let v = MinimisedPlayerView(frame: .zero)
        v.addSpeakerTarget(self, action: #selector(showDevices), for: .touchUpInside)
        v.backgroundColor = .black
        return v
    }()
    
    // MARK: Player Maximised
    public let headerView: NewPlayerHeaderBottomView = {
        let v = NewPlayerHeaderBottomView(frame: .zero)
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.leftButton.addTarget(self, action: #selector(collapse), for: .touchUpInside)
        v.rightButton.addTarget(self, action: #selector(showOptions), for: .touchUpInside)
        return v
    }()
    
    private let stackView: UIStackView = {
        let s = UIStackView(frame: .zero)
        s.alignment = UIStackView.Alignment.center
        s.distribution = UIStackView.Distribution.equalSpacing
        s.spacing = 20.0
        s.axis = .vertical
        return s
    }()
    
    private let carouselView: JMCarouselView = {
        let c = JMCarouselView(withType: .playerQueue)
        return c
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = l.font.withSize(13)
        return l
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.textColor = .lightGray
        l.textAlignment = .center
        l.font = l.font.withSize(13)
        return l
    }()
    
    private let listenMore: UILabel = {
        let l = UILabel(frame: .zero)
        l.textAlignment = .center
        l.font = l.font.withSize(13)
        l.textColor = UIColor.black
        l.text = "listen more"
        l.isHidden = true
        return l
    }()
    
    private let listenMoreIcon: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.contentMode = .scaleAspectFit
        i.image = UIImage(named: "icon_chevron")?.withRenderingMode(.alwaysTemplate)
        i.tintColor = UIColor.black
        i.isHidden = true
        return i
    }()
    
    private let playerProgressView: PlayerProgressView = {
        let v = PlayerProgressView(frame: .zero)
        v.backgroundColor = .white
        v.progressView.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return v
    }()
    
    private let playerControlView: PlayerControlView = {
        let v = PlayerControlView(frame: .zero)
        v.backgroundColor = .white
//        v.deviceButton.addTarget(self, action: #selector(showDevices), for: .touchUpInside)
        v.previousButton.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
        v.playButton.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        v.nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        v.queueButton.addTarget(self, action: #selector(presentQueueView), for: .touchUpInside)
        v.speedControlButton.addTarget(self, action: #selector(handlePlaybackSpeed), for: .touchUpInside)
        v.seekForwardButton.addTarget(self, action: #selector(seekForwardAction), for: .touchUpInside)
        v.seekBackwardsButton.addTarget(self, action: #selector(seekBackwardAction), for: .touchUpInside)
        return v
    }()
    
    private var isSlidingProgress: Bool = false
    private var lastScrollDate = Date()

    private(set) weak var minimisedViewTop: NSLayoutConstraint!
    private(set) weak var headerViewTop: NSLayoutConstraint!

    // MARK: - Show devices
   
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
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
        let interactor = PlayerInteractor()
        let presenter = PlayerPresenter()
        let router = PlayerRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
//        deviceStateListener.delegate = viewController
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
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Add Subviews
        addSubViews()

        // Define layout
        defineLayout()
        
        // Setup minimised player action blocks
        minimisedPlayer.playPauseAction = { [weak self] in
            self?.playPauseAction()
        }
        
        IstiakPlayerManager.shared.itemProgress = {  [weak self] seconds, duration in
            self?.adjustProgress(seconds, duration: duration)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        minimisedPlayer.addGestureRecognizer(tap)
        
        // Add observers for the LTNPlayer
        NotificationCenter.default.addObserver(self, selector: #selector(isBuffering), name: .isBuffering, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isPlaying), name: .isPlaying, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isPaused), name: .isPaused, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAddedToQueue), name: .addedToQueue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlaybackUI), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlaybackUI), name: .isFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeSpeedIcon), name: .changeSpeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        listenMore.isUserInteractionEnabled = true
        listenMore.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(listenMoreAction)))
        listenMoreIcon.isUserInteractionEnabled = true
        listenMoreIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(listenMoreAction)))
//        deviceListRefreshed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setPlayerSpeedIcon()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
    }
    
    func addSubViews() {
        
        // Minimised
        minimisedView.addSubview(minimisedPlayer)
        view.addSubview(minimisedView)
        
        // Maximised
        view.addSubview(headerView)
        view.addSubview(stackView)
        view.addSubview(playerProgressView)
        view.addSubview(playerControlView)
        view.addSubview(listenMoreIcon)
        
        stackView.addArrangedSubview(carouselView)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(listenMore)
        
    }
    
    //swiftlint:disable:next function_body_length
    func defineLayout() {
        
        // MARK: Minimised Player
        
        // MARK: Minimised Player
        
        minimisedView.translatesAutoresizingMaskIntoConstraints = false
        minimisedViewTop = minimisedView.topAnchor.constraint(equalTo: view.topAnchor)
        minimisedViewTop.isActive = true
        minimisedView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        minimisedView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        minimisedView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        minimisedPlayer.translatesAutoresizingMaskIntoConstraints = false
        minimisedPlayer.topAnchor.constraint(equalTo: minimisedView.topAnchor).isActive = true
        minimisedPlayer.bottomAnchor.constraint(equalTo: minimisedView.bottomAnchor, constant: -8).isActive = true
        minimisedPlayer.leadingAnchor.constraint(equalTo: minimisedView.leadingAnchor, constant: 8).isActive = true
        minimisedPlayer.trailingAnchor.constraint(equalTo: minimisedView.trailingAnchor, constant: -8).isActive = true
        
        // MARK: Maximised Player
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerViewTop = headerView.topAnchor.constraint(equalTo: minimisedView.bottomAnchor, constant: 25)
        headerViewTop.isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: playerControlView.topAnchor, constant: -1).isActive = true
        stackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        let small = view.bounds.height < 650
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        carouselView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: small ? 0.48 : 0.64).isActive = true
        carouselView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        carouselView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 30).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -30).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 55).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 30).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -30).isActive = true
        descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        listenMore.translatesAutoresizingMaskIntoConstraints = false
        listenMore.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        listenMore.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        listenMoreIcon.translatesAutoresizingMaskIntoConstraints = false
        listenMoreIcon.heightAnchor.constraint(equalTo: listenMore.heightAnchor, multiplier: 0.6).isActive = true
        listenMoreIcon.leadingAnchor.constraint(equalTo: listenMore.trailingAnchor, constant: 10).isActive = true
        listenMoreIcon.centerYAnchor.constraint(equalTo: listenMore.centerYAnchor, constant: 1).isActive = true
        
        playerProgressView.translatesAutoresizingMaskIntoConstraints = false
        playerProgressView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        playerProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerProgressView.bottomAnchor.constraint(equalTo: playerControlView.topAnchor, constant: -12).isActive = true
        playerProgressView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        playerProgressView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        playerControlView.translatesAutoresizingMaskIntoConstraints = false
        playerControlView.topAnchor.constraint(equalTo: playerProgressView.bottomAnchor, constant: 0).isActive = true
        playerControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerControlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: hasTopNotch ? -20 : -3).isActive = true
        playerControlView.heightAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        playerControlView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        playerControlView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    func setPlayerSpeedIcon() {
        let iconName = "icon_speed_\(IstiakPlayerManager.shared.getCurrentPlaybackSpeed())x"
        playerControlView.setPlayerSpeedIcon(icon: iconName)
    }
    
    func setFavoriteIcon(status: Bool) {
        playerControlView.setPlayerFavouriteIcon(status: status)
    }

    // MARK: - Targets
    
    @objc private func collapse() {
        drawerView.setPosition(.partiallyOpen, animated: true)
    }
    
    @objc private func handlePlaybackSpeed() {
        let playBackSpeed: Float = IstiakPlayerManager.shared.getCurrentPlaybackSpeed()
        if(playBackSpeed == 1.0) {
            IstiakPlayerManager.shared.changePlaybackSpeed(atRate: 1.25)
        } else if(playBackSpeed == 1.25) {
            IstiakPlayerManager.shared.changePlaybackSpeed(atRate: 1.5)
        } else if(playBackSpeed == 1.5) {
            IstiakPlayerManager.shared.changePlaybackSpeed(atRate: 1.75)
        } else if(playBackSpeed == 1.75) {
            IstiakPlayerManager.shared.changePlaybackSpeed(atRate: 2.0)
        } else if(playBackSpeed == 2.0) {
            IstiakPlayerManager.shared.changePlaybackSpeed(atRate: 0.5)
        } else if(playBackSpeed == 0.5) {
            IstiakPlayerManager.shared.changePlaybackSpeed(atRate: 0.75)
        } else if (playBackSpeed == 0.75) {
            IstiakPlayerManager.shared.changePlaybackSpeed(atRate: 1.0)
        }
    }
    
    @objc private func showOptions() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.white
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let share = UIAlertAction(title: "share", style: .default) { _ in
            guard let clip = IstiakPlayerManager.shared.currentItem else { return }
            
            let shareUrl = Constants.Share.baseUrl + Constants.Share.Types.clip.rawValue + "\(clip.id)"
            
            let activityController = UIActivityViewController(activityItems: [shareUrl], applicationActivities: [])
            // https://stackoverflow.com/questions/24224916/presenting-a-uialertcontroller-properly-on-an-ipad-using-ios-8
            if let popoverController = activityController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(origin: self.view.center, size: CGSize(width: 0, height: 0))
                popoverController.permittedArrowDirections = [.down]
            }
            self.present(activityController, animated: true)
        }
        
        alert.addAction(share)
        alert.addAction(cancel)
        
        // https://stackoverflow.com/questions/24224916/presenting-a-uialertcontroller-properly-on-an-ipad-using-ios-8
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = headerView
            popoverController.sourceRect = CGRect(origin: view.center, size: CGSize(width: 0, height: 0))
            popoverController.permittedArrowDirections = [.down]
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func showDevices() {
//        router?.navigateToAvailableDevices()
    }
    
    @objc private func listenMoreAction() {
        guard let clip = IstiakPlayerManager.shared.currentItem as? AudioClip else { return }
        guard let linkedId = clip.linkedAudioClipID else { return }
        
        let request = Player.LinkedClip.Request(linkedAudioClipId: linkedId)
        interactor?.playLinkedClip(request: request)
    }
    
    private func adjustListenMore(withState state: Bool) {
        listenMore.isHidden = state
        listenMoreIcon.isHidden = state
    }
    
    // MARK: - Play, Pause, Previous, Next

    @objc private func playPauseAction() {
        IstiakPlayerManager.shared.playPauseAction()
    }
    
    @objc private func previousAction() {
        IstiakPlayerManager.shared.playPrevious()
    }
    
    @objc private func nextAction() {
        IstiakPlayerManager.shared.playNext()
        self.reloadPlaybackUI()
    }
    
    @objc private func seekForwardAction() {
        IstiakPlayerManager.shared.seekForward()
    }
    
    @objc private func seekBackwardAction() {
        IstiakPlayerManager.shared.seekBackward()
    }
    
    
    @objc private func presentQueueView() {
//        let destination = QueueTableViewController(style: .grouped)
//        self.present(destination, animated: true, completion: nil)
    }
    
    @objc private func showAllClipsForProvider() {
//        guard let audioClip = IstiakPlayerManager.shared.currentItem as? AudioClip, let providerId = audioClip.provider?.id else {
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//            appDelegate.showBannerView(withType: .error(title: tr.search.noResults), viewController: nil)
//            return
//        }
//        router?.navigateToShowAllClips(withProvider: providerId, providerName: audioClip.provider?.name ?? "")
    }
    
  
    private func showAlert(status: Bool) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        if(status) {
//            appDelegate.showBannerView(withType: .info(title: tr.personalization.favouriteSuccess), viewController: nil)
//        } else {
//            appDelegate.showBannerView(withType: .info(title: tr.personalization.unfavouriteSuccess), viewController: nil)
//        }
    }
    
    // MARK: - Tap Gesture on minimised player
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        self.drawerView.setPosition(.open, animated: true)
        IstiakPlayerManager.shared.changePlaybackSpeed(atRate: IstiakPlayerManager.shared.getCurrentPlaybackSpeed())
    }
    
    // MARK: - Player Observers Helpers
    
    @objc private func isBuffering() {
        minimisedPlayer.configure(isBuffering: true)
        playerControlView.configure(isPlaying: true)
    }
    
    @objc private func isPaused() {
        minimisedPlayer.configure(isPlaying: false)
        playerControlView.configure(isPlaying: false)
    }
    
    @objc private func changeSpeedIcon() {
        let iconName = "icon_speed_\(IstiakPlayerManager.shared.getCurrentPlaybackSpeed())x"
        playerControlView.setPlayerSpeedIcon(icon: iconName)
    }
    
    @objc private func isPlaying() {
        minimisedPlayer.configure(isBuffering: false)
        minimisedPlayer.configure(isPlaying: true)
        playerControlView.configure(isPlaying: true)
        reloadPlaybackUI()
        
        DispatchQueue.main.async { [weak self] in
            guard let clip = IstiakPlayerManager.shared.currentItem as? AudioClip else {
                guard let adClip = IstiakPlayerManager.shared.currentItem as? AdClip else {
                    guard let providerClip = IstiakPlayerManager.shared.currentItem as? ProviderClip else { return }
                    
                    // Provider Clip
                    self?.titleLabel.text = providerClip.title
                    self?.descriptionLabel.text = providerClip.title
                    
                    self?.minimisedPlayer.configure(title: providerClip.title, description: providerClip.title, imageURL: URL(string: providerClip.logo ?? ""))
                    self?.playerProgressView.configure(duration: "")
                    
                    return
                }
                
                // AdClip
                self?.titleLabel.text = adClip.title
                self?.descriptionLabel.text = adClip.providerName

                self?.minimisedPlayer.configure(title: adClip.providerName, description: adClip.title, imageURL: URL(string: adClip.providerLogo ?? ""))
                self?.playerProgressView.configure(duration: adClip.duration?.formatted ?? "")
                
                return
            }
            
            // Audio Clip
            self?.titleLabel.text = clip.title
            self?.descriptionLabel.text = clip.infoString
            
            // Configure the header view
            self?.headerView.configure(withViewModel: .init(rightButtonImage: UIImage(named: "icon_options"),
                                                      leftButtonImage: UIImage(named: "icon_down"),
                                                      titleText: clip.category?.name,
                                                      titleColor: UIColor.black))
            
            self?.minimisedPlayer.configure(title: clip.title, description: clip.provider?.name, imageURL: URL(string: clip.provider?.logo?.url ?? ""))
            self?.playerProgressView.configure(duration: clip.durationString)
            
            // Listen More
            let state = clip.linkedAudioClipID != nil
            self?.adjustListenMore(withState: !state)
        }
    }
    
    @objc private func reloadPlaybackUI() {
        DispatchQueue.main.async {
            self.minimisedPlayer.configure(isPlaying: IstiakPlayerManager.shared.isPlaying)
            
            if IstiakPlayerManager.shared.currentItem is JingleClip { return }
            self.setFavoriteIcon(status: false)
            
            var viewModels = [JMCarouselViewItemViewModel]()
            
            if let currentItem = IstiakPlayerManager.shared.currentItem as? AudioClip {
                viewModels.append(JMCarousselViewPlayerQueueItem.ViewModel(image: nil, imageURL: URL(string: currentItem.provider?.logo?.url ?? "")))
            } else if let currentItem = IstiakPlayerManager.shared.currentItem as? AdClip {
                viewModels.append(JMCarousselViewPlayerQueueItem.ViewModel(image: nil, imageURL: URL(string: currentItem.providerLogo ?? "")))
            } else if let currentItem = IstiakPlayerManager.shared.currentItem as? ProviderClip {
                viewModels.append(JMCarousselViewPlayerQueueItem.ViewModel(image: nil, imageURL: URL(string: currentItem.logo ?? "")))
            }
            
            let imageURLs = IstiakPlayerManager.shared.queue.compactMap { $0.provider?.logo?.url }
            for url in imageURLs {
                viewModels.append(JMCarousselViewPlayerQueueItem.ViewModel(image: nil, imageURL: URL(string: url)))
            }
                
            self.carouselView.configure(withViewModel: viewModels)
            self.carouselView.delegate = self
            
        }
    }
    
    @objc func didBecomeActive() {
        print("did become active")
    }

    @objc func willEnterForeground() {
        print("will enter foreground")
        DispatchQueue.main.async { [weak self] in
            guard let audioClip = IstiakPlayerManager.shared.currentItem as? AudioClip else { return }
//            guard let isFavorite = audioClip.isFavorite else { return }
//            self?.setFavoriteIcon(status: isFavorite)
        }
    }
    
    // MARK: - Slider
    
    @objc private func sliderValueChanged(_ sender: UISlider, _ event: UIEvent) {
        isSlidingProgress = event.allTouches?.first?.phase != .ended ? true : false
        IstiakPlayerManager.shared.seek(toPercentage: Double(sender.value))
    }
    
    // MARK: - Show/Hide Added to queue Animation
    
    @objc private func showAddedToQueue() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        appDelegate.showBannerView(withType: .info(title: "Added to queue"), viewController: nil)
    }
    
    private func adjustProgress(_ seconds: Float, duration: Float?) {
        guard let duration = duration, !duration.isNaN && !duration.isInfinite else { return }

        hmsFrom(seconds: Int(seconds)) { hours, minutes, seconds in
            let hoursString = self.getStringFrom(seconds: hours)
            let minutesString = self.getStringFrom(seconds: minutes)
            let secondsString = self.getStringFrom(seconds: seconds)
            if hours > 0 {
                self.playerProgressView.configure(progressInMinutesSeconds: "\(hoursString):\(minutesString):\(secondsString)")
            } else {
                self.playerProgressView.configure(progressInMinutesSeconds: "\(minutesString):\(secondsString)")
            }
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                let progress = seconds / duration
                self.minimisedPlayer.configure(progress: progress)
                if !self.isSlidingProgress {
                    self.playerProgressView.configure(progress: progress)
                }
            })
        }
        
    }
    
    private func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int) -> Void) {
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func getStringFrom(seconds: Int) -> String {
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    
    // MARK: Do something
    
    func displaySomething(viewModel: Player.Something.ViewModel) {
        //nameTextField.text = viewModel.name
    }
    
    func displayLinkedClip(viewModel: Player.LinkedClip.ViewModel) {
        // Hide "Listen More" button if something went wrong
        guard viewModel.error != nil else { return }
        adjustListenMore(withState: true)
    }
}

extension PlayerViewController: JMCarouselViewDelegate {
    
    func didSelect(_ type: JMCarouselViewType, indexPath: IndexPath) {
        showAllClipsForProvider()
    }
    
    func didScrollToPage(_ page: Int) {
        debugPrint("didScrollToPage:", page)
        
        if page == 1 {
            nextAction()
        } else if page > 1 {
            let queueClipsAfter = IstiakPlayerManager.shared.queue.suffix(from: page-1)
            if queueClipsAfter.count > 0 {
                IstiakPlayerManager.shared.play(withClips: Array(queueClipsAfter), startClip: nil, endClip: nil, isTimeSlot: false, overwrite: true)
            }
        }
    }
    
    func didScrollToEnd(_ type: JMCarouselViewType) { }
    
}


//extension PlayerViewController: DeviceChangeListenerDelegate {
//    func deviceListRefreshed() {
////        let isPlayingOnGoogleCast = IstiakPlayerManager.shared.outputType == .chromeCast
////        if isPlayingOnGoogleCast {
////            playerControlView.switchToChromeCast()
////            minimisedPlayer.setDeviceInfo(
////                deviceIcon: "",
////                deviceName: GoogleCastManager.shared.connectedDevice?.friendlyName,
////                secondaryIcon: nil,
////                enableCastButton: true
////            )
////
////        } else {
////            changeUIForIphone()
////        }
//    }
//
//    func deviceState(_ state: DeviceConnectionState, for deviceType: DeviceType) {
////        switch deviceType {
////        case .googleCast:
////            switch state {
////            case .notconnected:
////                changeUIForIphone()
////            case .connected:
////                playerControlView.switchToChromeCast()
////                minimisedPlayer.setDeviceInfo(
////                    deviceIcon: "",
////                    deviceName: GoogleCastManager.shared.connectedDevice?.friendlyName,
////                    secondaryIcon: nil,
////                    enableCastButton: true
////                )
////            case .connecting:
////                playerControlView.switchToChromeCast()
////                minimisedPlayer.setDeviceInfo(
////                    deviceIcon: "",
////                    deviceName: "device",
////                    secondaryIcon: nil,
////                    enableCastButton: true
////                )
////
////            }
////        case .iphone:
////            changeUIForIphone()
////        }
//    }
//    
//    private func changeUIForIphone() {
////        let current = deviceStateListener.getCurrentLocalDeviceSource()
////        switch current {
////        case .airplay(let name):
////            playerControlView.switchToLocal(icon: "device_airplay")
////            minimisedPlayer.setDeviceInfo(
////                deviceIcon: "airplay_white",
////                deviceName: name,
////                secondaryIcon: "airplay_gray",
////                enableCastButton: false
////            )
////
////        case .bluetooth(let name):
////            playerControlView.switchToLocal(icon: "device_bluetooth")
////            minimisedPlayer.setDeviceInfo(
////                deviceIcon: "bluetooth_white",
////                deviceName: name,
////                secondaryIcon: "bluetooth_gray",
////                enableCastButton: false
////            )
////
////        case .iphone(_):
////            playerControlView.switchToLocal(icon: "device_idle")
////            minimisedPlayer.setDeviceInfo(
////                deviceIcon: "idle_while",
////                deviceName: nil,
////                secondaryIcon: nil,
////                enableCastButton: false
////            )
////
////        }
//    }
//}
