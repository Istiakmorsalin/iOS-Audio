//
//  LocalizationsRepositoryMock.swift
//  NStackSDK
//
//  Created by Dominik Hádl on 05/12/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

@testable import LocalizationManager

class LocalizationsRepositoryMock<L: LanguageModel>: LocalizationRepository {

    var localizationsResponse: LocalizationResponse<DefaultLanguage>?
    var availableLocalizations: [DefaultLocalizationDescriptor]?
    var availableLanguages: [L]?
    var currentLanguage: DefaultLanguage?
    var currentLocalization: DefaultLocalizationDescriptor?
    var preferredLanguages = ["en"]
    var customBundles: [Bundle]?

    func getLocalizationDescriptors<D>(
        acceptLanguage: String,
        lastUpdated: Date?,
        completion: @escaping (Result<[D]>) -> Void
        ) where D: LocalizationDescriptor {
        let error = NSError(domain: "", code: 100, userInfo: nil) as Error
        let result: Result = availableLocalizations != nil ? .success(availableLocalizations!) : .failure(error)
        completion(result as! Result<[D]>)
    }

    func getLocalization<L, D>(
        descriptor: D,
        acceptLanguage: String,
        completion: @escaping (Result<LocalizationResponse<L>>) -> Void
        ) where L: LanguageModel, D: LocalizationDescriptor {
        let error = NSError(domain: "", code: 0, userInfo: nil) as Error
        let result: Result = localizationsResponse != nil ? .success(localizationsResponse!) : .failure(error)
        completion(result as! Result<LocalizationResponse<L>>)
    }

    func getAvailableLanguages<L: LanguageModel>(completion:  @escaping (Result<[L]>) -> Void) {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let result: Result = availableLanguages != nil ? .success(availableLanguages!) : .failure(error)
        completion(result as! (Result<[L]>))
    }
}

extension LocalizationsRepositoryMock: LocalizationContextRepository {

    func fetchPreferredLanguages() -> [String] {
        return preferredLanguages
    }

    func getLocalizationBundles() -> [Bundle] {
        return customBundles ?? Bundle.allBundles
    }

    func fetchCurrentPhoneLanguage() -> String? {
        return preferredLanguages.first
    }
}
