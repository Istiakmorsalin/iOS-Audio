import Foundation
struct AudioBoom : Codable {
    let id : Int?
    let title : String?
    let description : String?
    let formattedDescription : String?
    let updated_at : String?
    let user : User?
    let linkStyle : String?
    let channel : Channel?
    let duration : Double?
    let mp3Filesize : Int?
    let uploadedAt : String?
    let recordedAt : String?
    let uploadedAtTs : Int?
    let categoryId : Int?
    let counts : Counts?
    let urls : Urls?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case title = "title"
        case description = "description"
        case formattedDescription = "formatted_description"
        case updated_at = "updated_at"
        case user = "user"
        case linkStyle = "link_style"
        case channel = "channel"
        case duration = "duration"
        case mp3Filesize = "mp3Filesize"
        case uploadedAt = "uploaded_at"
        case recordedAt = "recorded_at"
        case uploadedAtTs = "uploaded_at_ts"
        case categoryId = "category_id"
        case counts = "counts"
        case urls = "urls"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        formattedDescription = try values.decodeIfPresent(String.self, forKey: .formattedDescription)
        updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
        user = try values.decodeIfPresent(User.self, forKey: .user)
        linkStyle = try values.decodeIfPresent(String.self, forKey: .linkStyle)
        channel = try values.decodeIfPresent(Channel.self, forKey: .channel)
        duration = try values.decodeIfPresent(Double.self, forKey: .duration)
        mp3Filesize = try values.decodeIfPresent(Int.self, forKey: .mp3Filesize)
        uploadedAt = try values.decodeIfPresent(String.self, forKey: .uploadedAt)
        recordedAt = try values.decodeIfPresent(String.self, forKey: .recordedAt)
        uploadedAtTs = try values.decodeIfPresent(Int.self, forKey: .uploadedAtTs)
        categoryId = try values.decodeIfPresent(Int.self, forKey: .categoryId)
        counts = try values.decodeIfPresent(Counts.self, forKey: .counts)
        urls = try values.decodeIfPresent(Urls.self, forKey: .urls)
    }

}
