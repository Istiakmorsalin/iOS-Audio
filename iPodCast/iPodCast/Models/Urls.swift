

import Foundation
struct Urls : Codable {
	let detail : String?
	let high_mp3 : String?
	let wave_img : String?

	enum CodingKeys: String, CodingKey {

		case detail = "detail"
		case high_mp3 = "high_mp3"
		case wave_img = "wave_img"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		detail = try values.decodeIfPresent(String.self, forKey: .detail)
		high_mp3 = try values.decodeIfPresent(String.self, forKey: .high_mp3)
		wave_img = try values.decodeIfPresent(String.self, forKey: .wave_img)
	}

}
