import Foundation
struct Audio_clips : Codable {
    let id : Int?
    let title : String?
    let description : String?
    let formatted_description : String?
    let updated_at : String?
    let user : User?
    let link_style : String?
    let channel : Channel?
    let duration : Double?
    let mp3_filesize : Int?
    let uploaded_at : String?
    let recorded_at : String?
    let uploaded_at_ts : Int?
    let recorded_at_ts : Int?
    let can_comment : Bool?
    let can_embed : Bool?
    let category_id : Int?
    let counts : Counts?
    let urls : Urls?
    let image_attachment : Int?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case title = "title"
        case description = "description"
        case formatted_description = "formatted_description"
        case updated_at = "updated_at"
        case user = "user"
        case link_style = "link_style"
        case channel = "channel"
        case duration = "duration"
        case mp3_filesize = "mp3_filesize"
        case uploaded_at = "uploaded_at"
        case recorded_at = "recorded_at"
        case uploaded_at_ts = "uploaded_at_ts"
        case recorded_at_ts = "recorded_at_ts"
        case can_comment = "can_comment"
        case can_embed = "can_embed"
        case category_id = "category_id"
        case counts = "counts"
        case urls = "urls"
        case image_attachment = "image_attachment"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        formatted_description = try values.decodeIfPresent(String.self, forKey: .formatted_description)
        updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
        user = try values.decodeIfPresent(User.self, forKey: .user)
        link_style = try values.decodeIfPresent(String.self, forKey: .link_style)
        channel = try values.decodeIfPresent(Channel.self, forKey: .channel)
        duration = try values.decodeIfPresent(Double.self, forKey: .duration)
        mp3_filesize = try values.decodeIfPresent(Int.self, forKey: .mp3_filesize)
        uploaded_at = try values.decodeIfPresent(String.self, forKey: .uploaded_at)
        recorded_at = try values.decodeIfPresent(String.self, forKey: .recorded_at)
        uploaded_at_ts = try values.decodeIfPresent(Int.self, forKey: .uploaded_at_ts)
        recorded_at_ts = try values.decodeIfPresent(Int.self, forKey: .recorded_at_ts)
        can_comment = try values.decodeIfPresent(Bool.self, forKey: .can_comment)
        can_embed = try values.decodeIfPresent(Bool.self, forKey: .can_embed)
        category_id = try values.decodeIfPresent(Int.self, forKey: .category_id)
        counts = try values.decodeIfPresent(Counts.self, forKey: .counts)
        urls = try values.decodeIfPresent(Urls.self, forKey: .urls)
        image_attachment = try values.decodeIfPresent(Int.self, forKey: .image_attachment)
    }

}
