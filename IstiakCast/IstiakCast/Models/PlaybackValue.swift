
import Foundation

struct PlaybackValue: Identifiable {
  let value: Double
  let label: String

  var id: String {
    return "\(label)-\(value)"
  }
}
