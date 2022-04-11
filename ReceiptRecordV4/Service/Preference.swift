//
//  Preference.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 9/3/22.
//

import Foundation


class Preference {
    static let shared = Preference()
    
    private let notionDict: [String: Any]
    
    private init() {
        notionDict = Bundle.main.infoDictionary?["NotionAPI"] as! [String: Any]
    }
}

///
/// Public API
///
extension Preference {
    
    func getNotionAPIUrl(infoType: InfoType) -> String {
        return notionDict[infoType.rawValue] as? String ?? ""
    }
}

///
/// enumeration declared
///
extension Preference {
    enum InfoType: String {
        case NOTION_API_URL = "NotionAPIURL"
        case NOTION_API_VERSION = "NotionAPIVersion"
        case NOTION_VERSION = "NotionVersion"
        case NOTION_SECRET_KEY = "NotionSecretKey"
    }
}
