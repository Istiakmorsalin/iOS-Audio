// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
@testable import LocalizationManager
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

// swiftlint:disable all














class LocalizationContextRepositoryMock: LocalizationContextRepository {



    //MARK: - fetchPreferredLanguages

    var fetchPreferredLanguagesCallsCount = 0
    var fetchPreferredLanguagesCalled: Bool {
        return fetchPreferredLanguagesCallsCount > 0
    }
    var fetchPreferredLanguagesReturnValue: [String]!
    var fetchPreferredLanguagesClosure: (() -> [String])?

    func fetchPreferredLanguages() -> [String] {
        fetchPreferredLanguagesCallsCount += 1
        return fetchPreferredLanguagesClosure.map({ $0() }) ?? fetchPreferredLanguagesReturnValue
    }

    //MARK: - getLocalizationBundles

    var getLocalizationBundlesCallsCount = 0
    var getLocalizationBundlesCalled: Bool {
        return getLocalizationBundlesCallsCount > 0
    }
    var getLocalizationBundlesReturnValue: [Bundle]!
    var getLocalizationBundlesClosure: (() -> [Bundle])?

    func getLocalizationBundles() -> [Bundle] {
        getLocalizationBundlesCallsCount += 1
        return getLocalizationBundlesClosure.map({ $0() }) ?? getLocalizationBundlesReturnValue
    }

    //MARK: - fetchCurrentPhoneLanguage

    var fetchCurrentPhoneLanguageCallsCount = 0
    var fetchCurrentPhoneLanguageCalled: Bool {
        return fetchCurrentPhoneLanguageCallsCount > 0
    }
    var fetchCurrentPhoneLanguageReturnValue: String?
    var fetchCurrentPhoneLanguageClosure: (() -> String?)?

    func fetchCurrentPhoneLanguage() -> String? {
        fetchCurrentPhoneLanguageCallsCount += 1
        return fetchCurrentPhoneLanguageClosure.map({ $0() }) ?? fetchCurrentPhoneLanguageReturnValue
    }

}
