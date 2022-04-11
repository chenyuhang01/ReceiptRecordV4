//
//  NotionService.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 3/3/22.
//

import Foundation
import UIKit

struct NotionErrorStruct: Codable {
    var object: String
    var status: Int
    var code: String
    var message: String
}

/// Notion Service provides essential API for clients to perform various Notion Secure Request
/// Notion Service does not provide the conversion of json data into respective data structure
/// Return NotionErrorStruct if request failed
class NotionService {
    private var databaseId: String?
    private var notionAPIVersion: String?
    private let NOTION_API_VERSION: String  = Preference.shared.getNotionAPIUrl(infoType: .NOTION_API_VERSION)
    private let NOTION_API_URL: String  = Preference.shared.getNotionAPIUrl(infoType: .NOTION_API_URL)
    private let urlSession: URLSession?
    
    // Database object
    
    init(databaseId: String?) {
        self.databaseId = databaseId
        self.urlSession = URLSession(configuration: .default)
    }
}

extension NotionService {
    
    func getDatabaseInfo(completion: @escaping (Bool, Any?, NotionErrorStruct?) -> Void) {
        Logging.shared.logMsgEvent(loggingType: .INFO, message: "Initiated", funcName: #function, moduleName: #file)
        
        guard let databaseId = self.databaseId else { return }
        
        let requestedUrl: String = "\(NOTION_API_URL)/\(NOTION_API_VERSION)/databases/\(databaseId)"
        guard let urlRequest = NotionServiceSecureRequestFactory.shared.generateSecureRequest(url: URL(string: requestedUrl)!, data: nil, notionMethod: .GET) else { return }

        self.startNotionSecureSession(urlRequest: urlRequest, completion: completion)
    }
    
    func getReceiptRecords(completion: @escaping (Bool, Any?, NotionErrorStruct?) -> Void) {
        Logging.shared.logMsgEvent(loggingType: .INFO, message: "Initiated", funcName: #function, moduleName: #file)
        
        guard let databaseId = self.databaseId else { return }
        
//        let filterData = "{\"property\":\"Price\", \"number\":-1}".data(using: .utf8)!
//        var inputData: Data?
//        do {
//            let filter = try JSONDecoder().decode(NumberFilter.self, from: filterData)
//            inputData = try JSONEncoder().encode(filter)
//        } catch {
//            inputData = nil
//        }
        
        let requestedUrl: String = "\(NOTION_API_URL)/\(NOTION_API_VERSION)/databases/\(databaseId)/query"
        guard let urlRequest = NotionServiceSecureRequestFactory.shared.generateSecureRequest(url: URL(string: requestedUrl)!, data: nil, notionMethod: .POST) else { return }

        self.startNotionSecureSession(urlRequest: urlRequest, completion: completion)
    }
    
    func insertNewReceiptRecords(newItem: ReceiptRecord, completion: @escaping (Bool, Any?, NotionErrorStruct?) -> Void) {
        Logging.shared.logMsgEvent(loggingType: .INFO, message: "Initiated", funcName: #function, moduleName: #file)

        guard let databaseId = self.databaseId else { return }
        let requestedUrl: String = "\(NOTION_API_URL)/\(NOTION_API_VERSION)/pages"
        
        newItem.setEncodeWithDatabaseId(databaseId: databaseId)

        do {
            let data = try JSONEncoder().encode(newItem)
            guard let urlRequest = NotionServiceSecureRequestFactory.shared.generateSecureRequest(url: URL(string: requestedUrl)!, data: data, notionMethod: .POST) else { return }

            self.startNotionSecureSession(urlRequest: urlRequest, completion: completion)
        } catch {
            let notionErrorStruct = NotionErrorStruct(object: "", status: 0, code: "", message: "New Item Json not parsable")
            completion(false, nil, notionErrorStruct)
            return
        }
    }
    
    func updateNewReceiptRecords(existingItem: ReceiptRecord, completion: @escaping (Bool, Any?, NotionErrorStruct?) -> Void) {
        Logging.shared.logMsgEvent(loggingType: .INFO, message: "Initiated", funcName: #function, moduleName: #file)

        guard existingItem.id != "" else {
            Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Object ID cannot be empty", funcName: #function, moduleName: #file)
            return
        }
        
        let requestedUrl: String = "\(NOTION_API_URL)/\(NOTION_API_VERSION)/pages/\(existingItem.id)"

        do {
            let data = try JSONEncoder().encode(existingItem)
            guard let urlRequest = NotionServiceSecureRequestFactory.shared.generateSecureRequest(url: URL(string: requestedUrl)!, data: data, notionMethod: .PATCH) else { return }

            self.startNotionSecureSession(urlRequest: urlRequest, completion: completion)
        } catch {
            let notionErrorStruct = NotionErrorStruct(object: "", status: 0, code: "", message: "New Item Json not parsable")
            completion(false, nil, notionErrorStruct)
            return
        }
    }
    
    private func startNotionSecureSession(urlRequest: URLRequest, completion: @escaping (Bool, Any?, NotionErrorStruct?) -> Void) {
        guard let urlSession = self.urlSession else { return }
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            let result = self.parseResponse(data: data, response: response, error: error)
            let statusCode = result.3
            
            if statusCode == 200 {
                Logging.shared.logMsgEvent(loggingType: .INFO, message: "Success", funcName: #function, moduleName: #file)
                completion(true, data, nil)
            } else {
                if let errorType = result.2 {
                    var notionErrorStruct = NotionErrorStruct(object: "", status: 0, code: "", message: errorType.localizedDescription)
                    
                    if statusCode != 0 {
                        if let data = result.1 {
                            do {
                                notionErrorStruct = try JSONDecoder().decode(NotionErrorStruct.self, from: data)
                            } catch {
                                notionErrorStruct.code = "Parse notion error structure failed"
                            }
                        }
                    }
                    let errorMsg = "FAIL,StatusCode:\(notionErrorStruct.status),ErrorMsg:\(notionErrorStruct.message),URL:\(urlRequest.url?.absoluteString ?? "")"
                    Logging.shared.logMsgEvent(loggingType: .INFO, message: errorMsg, funcName: #function, moduleName: #file)
                    completion(false, nil, notionErrorStruct)
                } else {
                    fatalError("Unexpected invalid error type")
                }
            }
        }
        
        task.resume()
    }
    
    // parse the response
    private func parseResponse(data: Data?, response: URLResponse?, error: Error?) -> (Bool, Data?, NotionServiceError?, statusCode: Int) {
        
        guard error == nil else {
            return (false, nil, .NotionServiceNetworkError, 0)
        }
        
        guard let response = response as? HTTPURLResponse else {
            return (false, nil, .NotionServiceInvalidResponse, 0)
        }
        
        if response.statusCode == 200 {
            return (true, data, nil, response.statusCode)
        } else {
            return (false, data, .NotionServiceRequestFailed, response.statusCode)
        }
    }
}

extension NotionService {
    enum NotionServiceError: Swift.Error {
        case NotionServiceNetworkError
        case NotionServiceInvalidResponse
        case NotionServiceRequestFailed
        case NotionServicePostNewDataInvalidNewItem
        case unknown
    }
}
