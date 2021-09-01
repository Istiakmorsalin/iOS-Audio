//
//  Localization.swift
//  LocalizationManagerTests
//
//  Created by Dominik Hádl on 21/06/2019.
//  Copyright © 2019 Nodes. All rights reserved.
//

import Foundation
@testable import LocalizationManager

public final class Localization: LocalizableModel {
    public var otherSection = OtherSection()
    public var defaultSection = DefaultSection()

    enum CodingKeys: String, CodingKey {
        case otherSection = "other"
        case defaultSection = "default"
    }
    public override init() {
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        otherSection = try container.decodeIfPresent(OtherSection.self, forKey: .otherSection) ?? otherSection
        defaultSection = try container.decodeIfPresent(DefaultSection.self, forKey: .defaultSection) ?? defaultSection
    }
    public override subscript(key: String) -> LocalizableSection? {
        switch key {
        case CodingKeys.otherSection.stringValue: return otherSection
        case CodingKeys.defaultSection.stringValue: return defaultSection
        default: return nil
        }
    }

    public final class OtherSection: LocalizableSection {
        public var otherKey = ""
        public override init() { super.init() }
        enum CodingKeys: String, CodingKey {
            case otherKey
        }
        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            otherKey = try container.decodeIfPresent(String.self, forKey: .otherKey) ?? "__otherKey"
        }
        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.otherKey.stringValue: return otherKey
            default: return nil
            }
        }
    }

    public final class DefaultSection: LocalizableSection {
        public var keyys = ""
        public var successKey = ""
        public var testURL = ""
        public override init() { super.init() }
        enum CodingKeys: String, CodingKey {
            case keyys
            case successKey
            case testURL
        }
        public required init(from decoder: Decoder) throws {
            super.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            keyys = try container.decodeIfPresent(String.self, forKey: .keyys) ?? "__keyys"
            successKey = try container.decodeIfPresent(String.self, forKey: .successKey) ?? "__successKey"
            testURL = try container.decodeIfPresent(String.self, forKey: .testURL) ?? "__testURL"
        }
        public override subscript(key: String) -> String? {
            switch key {
            case CodingKeys.keyys.stringValue: return keyys
            case CodingKeys.successKey.stringValue: return successKey
                case CodingKeys.testURL.stringValue: return testURL
            default: return nil
            }
        }
    }
}
