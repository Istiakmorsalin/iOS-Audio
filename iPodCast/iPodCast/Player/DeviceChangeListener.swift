//
//import Foundation
//import GoogleCast
//import AVKit
//
//typealias DeviceInfo = (isConnected: Bool, portName: String?)
//
//enum LocalDevicePort {
//    case airplay(name: String?)
//    case bluetooth(name: String?)
//    case iphone(name: String?)
//}
//
//enum DeviceType {
//    case iphone
//    case googleCast
//}
//
//enum DeviceConnectionState {
//    case notconnected
//    case connecting
//    case connected
//}
//
//protocol DeviceChangeListenerDelegate: AnyObject {
//    func deviceListRefreshed()
//    func deviceState(_ state: DeviceConnectionState, for deviceType: DeviceType)
//}
//
//
//class DeviceChangeListener: NSObject {
//    
//    weak var delegate: DeviceChangeListenerDelegate?
//    
//    deinit {
//        GCKCastContext.sharedInstance().discoveryManager.remove(self)
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    override init() {
//        super.init()
//        GCKCastContext.sharedInstance().discoveryManager.add(self)
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(castDeviceDidChange),
//            name: NSNotification.Name.gckCastStateDidChange,
//            object: GCKCastContext.sharedInstance()
//        )
//    
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(avplayerPortChanged),
//            name: AVAudioSession.routeChangeNotification,
//            object: AVAudioSession.sharedInstance()
//        )
//    }
//    
//    //google cast device change
//    @objc func castDeviceDidChange(_: Notification) {
//        let castState =  GCKCastContext.sharedInstance().castState
//        
//        switch castState {
//        case .notConnected, .noDevicesAvailable:
//            delegate?.deviceState(.notconnected, for: .googleCast)
//        case .connecting:
//            delegate?.deviceState(.connecting, for: .googleCast)
//        case .connected:
//            delegate?.deviceState(.connected, for: .googleCast)
//        @unknown default:
//            delegate?.deviceState(.notconnected, for: .googleCast)
//        }
//
//    }
//   
//    
//    @objc func avplayerPortChanged(notification : Notification) {
//    
//        delegate?.deviceListRefreshed()
//    }
//    
//    func getCurrentLocalDeviceSource() -> LocalDevicePort {
//        let session = AVAudioSession.sharedInstance()
//        let bluetooth = hasBlueTooth(in: session.currentRoute)
//        let airplay: DeviceInfo = hasAirplay(in: session.currentRoute)
//        if airplay.isConnected {
//            return LocalDevicePort.airplay(name: airplay.portName)
//        } else if bluetooth.isConnected {
//            return LocalDevicePort.bluetooth(name: bluetooth.portName)
//        } else {
//            return LocalDevicePort.iphone(name: nil)
//        }
//        
//    }
//    
//    private func hasBlueTooth(in routeDescription: AVAudioSessionRouteDescription) -> DeviceInfo {
//        // Filter the outputs to only those with a port type of headphones.
//        guard let item = routeDescription.outputs.first(where: { $0.portType == .bluetoothA2DP || $0.portType == .bluetoothLE || $0.portType == .bluetoothHFP }) else { return (false, nil) }
//        
//        return (true, item.portName)
//    }
//    
//    private func hasAirplay(in routeDescription: AVAudioSessionRouteDescription) -> (Bool, String?) {
//        guard let item = routeDescription.outputs.first(where: { $0.portType == .airPlay}) else { return (false, nil) }
//        
//        return (true, item.portName)
//    }
//}
//
////google cast device search
//extension DeviceChangeListener: GCKDiscoveryManagerListener {
//    func didUpdateDeviceList() {
//        delegate?.deviceListRefreshed()
//    }
//}
