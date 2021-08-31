class Clip: Codable {
    
    var id: Int
    var title: String
    var publishTime: String? = ""
    var uri: String = "fasdf"
    var type: String? = ""
    var duration: ClipsMeta.Total.Duration?
 
    init(id: Int, title: String, uri: String) {
        self.id = id
        self.title = title
        self.uri = uri
    }
    
    
    // MARK: Helper variables
    var durationTimeSeconds: Int {
        guard let time = duration?.millisecond else { return 0 }
        return time / 1000
    }
    
}

class JingleClip: Clip {
    
}

protocol LogoProvider {
    var logoUrlString : String? { get }
}
