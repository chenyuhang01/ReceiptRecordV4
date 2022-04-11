//
//  NotionService.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 3/3/22.
//

import Foundation


fileprivate class SecureRequest {
    private let CONTENT_TYPE_FIELD: String = "Content-Type"
    private let AUTHORIZATION_FIELD: String = "Authorization"
    
    
    func generateSecureUrl(url: URL?, data: Data?) -> URLRequest?{
        guard let url = url else { return nil }
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.addValue(getContentType(), forHTTPHeaderField: CONTENT_TYPE_FIELD)
        urlRequest.addValue(getAuthorization(), forHTTPHeaderField: AUTHORIZATION_FIELD)
        urlRequest.httpMethod = getHttpMethod()
        if let data = data {
            urlRequest.httpBody = data
        }
        urlRequest = setCustomProperty(urlRequest: urlRequest)
        
        return urlRequest
    }
    
    func getContentType() -> String {
        fatalError("Subclasses need to implement the `getContentType()` method.")
    }
    
    func getAuthorization() -> String {
        fatalError("Subclasses need to implement the `setAuthorization()` method.")
    }
    
    func getHttpMethod() -> String {
        fatalError("Subclasses need to implement the `getHttpMethod()` method.")
    }
    
    func setData(data: Data?) -> Data? {
        fatalError("Subclasses need to implement the `getHttpMethod()` method.")
    }
    
    func setCustomProperty(urlRequest: URLRequest) -> URLRequest{
        fatalError("Subclasses need to implement the `setCustomProperty()` method.")
    }
}

fileprivate class NotionSecureRequest: SecureRequest {
    private let NOTION_VERSION: String = Preference.shared.getNotionAPIUrl(infoType: .NOTION_VERSION)
    private let NOTION_SECRET_KEY: String  = Preference.shared.getNotionAPIUrl(infoType: .NOTION_SECRET_KEY)
    private let NOTION_VERSION_FIELD: String = "Notion-Version"

    override func getContentType() -> String {
        return "application/json"
    }
    
    override func getAuthorization() -> String {
        return "Bearer \(self.NOTION_SECRET_KEY)"
    }
    
    override func setCustomProperty(urlRequest: URLRequest) -> URLRequest {
        var urlRequest: URLRequest = urlRequest
        urlRequest.addValue(self.NOTION_VERSION, forHTTPHeaderField: self.NOTION_VERSION_FIELD)
        return urlRequest
    }
}


fileprivate class NotionGetSecureRequest: NotionSecureRequest {
    override func getHttpMethod() -> String {
        return "GET"
    }
}

fileprivate class NotionPostSecureRequest: NotionSecureRequest {
    override func getHttpMethod() -> String {
        return "POST"
    }
}

fileprivate class NotionPatchSecureRequest: NotionSecureRequest {
    override func getHttpMethod() -> String {
        return "PATCH"
    }
}

class NotionServiceSecureRequestFactory {
    
    static let shared = NotionServiceSecureRequestFactory()
    
    enum NotionMethod {
        case GET
        case POST
        case PATCH
    }
    
    private init() {
        
    }
}

extension NotionServiceSecureRequestFactory {
    
    func generateSecureRequest(url: URL?, data: Data?, notionMethod: NotionMethod) -> URLRequest? {
        switch(notionMethod) {
            case .GET:
                return NotionGetSecureRequest().generateSecureUrl(url: url, data: data)
            case .POST:
                return NotionPostSecureRequest().generateSecureUrl(url: url, data: data)
            case .PATCH:
                return NotionPatchSecureRequest().generateSecureUrl(url: url, data: data)
        }
    }
}
