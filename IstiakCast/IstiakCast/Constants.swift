import Foundation
import UIKit

struct Constants {
    struct Notification {}
    struct Share {}
    struct AnimationDuration {}
    struct ClipCache {}
    struct TextDropShadow {}
    struct Timers {}
}

// MARK: - Notification

extension Constants.Notification {
    public static let logOut = "NotificationLogOut"
    public static let hasRegistered = "HasRegistered"
}

// MARK: - Share

extension Constants.Share {
    //fixme: add base url here
    public static let baseUrl = " "

    enum Types: String {
        case tag = "tag/"
        case clip = "audio_clips/"
        case collection = "collection/"
        case ambassador = "ambassador/"
        case slot = "slot/"
        case timeslots = "time_slots/"
        case categories = "categories/"
        case provider = "provider/"
        case settings = "settings"
        case latestNews = "latest"
    }
}

// MARK: - AnimationDuration

extension Constants.AnimationDuration {
    public static let drawer: TimeInterval = 0.5
    public static let playButton: TimeInterval = 0.3
}

// MARK: - ClipCache

extension Constants.ClipCache {
    public static let path: String = "ClipCache/"
    public static let fileExtension: String = ".mp3"
}

// MARK: - TextDropShadow

extension Constants.TextDropShadow {
    public static let shadowRadius: CGFloat = 2
    public static let shadowOpacity: Float = 1
    public static let shadowOffset: CGSize = CGSize(width: 0, height: 0)
}


enum AnalyticsEvent {
    static let carplay = "carplay"
    static let siri = "siri"
    static let facebookUser = "facebook_user"
    static let googleUser = "google_user"
    static let appleUser = "apple_user"
    static let signUpEmail = "signup_email"
    static let loginEmail = "login_email"
    static let continueWithoutUser = "continue_without_user"
   
    static let playAutomatic = "play_automatic"
    static let play = "play"
    static let playTimeslotHome = "play_timeslot_home"
    static let playTimeslotDetailview = "play_timeslot_detailview"
    static let playCollectionDetailview = "play_collection_detailview"
    static let playCategoryDetailview = "play_category_detailview"
    static let playAmbassadorDetailview = "play_ambassador_detailview"
    static let skip = "skip"
    static let queue = "queue"
    static let devices = "devices"
    static let playCategoryTimeslot = "play_category_timeslot"
    static let playAd = "play_ad"
    static let listenThrough = "listen_through"

    static let enableAmbassador = "enable_ambassador"
    static let disableAmbassador = "disable_ambassador"
    static let archiveDetailview = "archive_detailview"
    static let archiveProvider = "archive_provider"
    static let systemMessage = "system_message"
    //
    static let home = "home"
    static let discover = "discover"
    static let discoverCategory = "discover_category"
    static let search = "search"
    static let detailCollection = "detail_collection"
    static let detailTimeslot = "detail_timeslot"
    static let profile = "profile"
    static let settings = "settings"
    
    static let categoryDetailClips = "category_detail_clips"
    static let categoryDetailPodcast = "category_detail_podcast"
    //
    
    //
    static let premiumTime = "premium_time"
    static let premiumPref = "premium_pref"
    static let premiumContent = "premium_content"
    static let carplayPremiumContent = "carplay_premium_content"
    static let purchaseSubscription = "purchase_subscription"
    static let enablePreferences = "enable_preferences"
    static let disablePreferences = "disable_preferences"
    static let enableLanguage = "enable_language"
    static let disableLanguage = "disable_language"
    static let changeTime = "change_time"
    static let changeTimeDetailview = "change_time_detailview"
    static let appOpenedFromNotification = "app_opened_from_notification"
    static let appOpenedFromShare = "app_opened_from_share"
    static let shareTimeslot = "share_timeslot"
    static let shareCollection = "share_collection"
    static let shareClip = "share_clip"
    static let enableNotifications = "enable_notifications"
    static let disableNotifications  = "disable_notifications"
    
    //
    static let onboardingTimeslot = "onboarding_timeslot"
    static let onboardingTimeslotPlay = "onboarding_timeslot_play"
    static let onboardingPreference = "onboarding_preference"
    static let onboardingPreferenceSubscribed = "onboarding_preference_subscribed"
}

enum AnalyticsProperty {
    static let timeslotDuration = "timeslot_duration" //Int
    static let title = "title" //String
    static let id = "id" //String
    static let collectionId = "collection_id" //String
    static let type = "type" //String
    static let duration = "duration" //Int
    static let providerName = "provider_name" //String
    static let language = "language" //String
    static let categoryTitle = "category_title" //String
    static let premiumContent = "premium_content" //Bool
    static let email = "email" //String
    static let isPremium = "is_premium" //Bool
    static let query = "query" //String
    static let ids = "ids" //Array integer
}

enum AnalyticsUserProperty {
    static let name = "name"
    static let gender = "gender"
    static let dateOfBirth = "date_of_birth"
    static let country = "country"
    static let state = "state"
    static let city = "city"
    static let isPremium = "is_premium"
    static let customOptIn = "custom_opt_in"
}


enum OnboardingABTestKey {
    static let timeslot = "onboarding_activation"
    static let preference = "onboarding_preference"
}
