//
//  ReceiptRecordManager.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 7/3/22.
//

import Foundation


class ReceiptRecordManager {
    
    // Apply singleton pattern
    static let shared: ReceiptRecordManager = ReceiptRecordManager()
    
    // Notion Service end point
    private let notionService = NotionService(databaseId: "23aa9937e0554091a7cc0bc1f8710264")
    
    private var databaseObj: Database?
    private var receiptRecords: ReceiptRecords?
    
    // Use to prevent race condition on accessing the receipt records
    private let lock = NSLock()
    
    private init() {

    }
}

///
/// Setting up observer pattern
/// Observer can add into the observer list to observe the updates in the receipt records
///
extension Notification.Name {
    static let initDatabaseUpdatesPostMessage = Notification.Name("InitDatebaseUpdates")
    static let initReceiptRecordUpdatesPostMessage = Notification.Name("InitReceiptRecord")
    
    static let databaseUpdatesPostMessage = Notification.Name("DatebaseUpdates")
    static let receiptRecordUpdatesPostMessage = Notification.Name("ReceiptRecord")
}

extension ReceiptRecordManager {
    func postMessage(msg: NSNotification.Name) {
        let centre = NotificationCenter.default
        switch (msg) {
        case .databaseUpdatesPostMessage:
            centre.post(name: msg, object: DatabaseVM(with: self.databaseObj!))
            break
        case .receiptRecordUpdatesPostMessage:
            centre.post(name: msg, object: ReceiptRecordArrayVM(with: self.receiptRecords!))
            break
        case .initDatabaseUpdatesPostMessage:
            centre.post(name: msg, object: nil)
            break
        case .initReceiptRecordUpdatesPostMessage:
            centre.post(name: msg, object: nil)
            break
        default:
            break
        }
    }
}

///
/// Receipt Manager manager public API
///
extension ReceiptRecordManager {
    
    // Gets a new receipt record instance
    func spawnNewReceiptRecord() -> ReceiptRecordVM? {
        return ReceiptRecordVM(with: ReceiptRecord.generateReceiptRecord()!)
    }
    
    func getDatabase() -> DatabaseVM? {
        return DatabaseVM(with: databaseObj!)
    }
    
    func removeReceiptRecord(recordVM: ReceiptRecordVM) {
        self.receiptRecords?.removeExistingRecord(receiptRecord: recordVM.receiptRecord)
        self.postMessage(msg: .receiptRecordUpdatesPostMessage)
    }
    
    // Get the particular record, if not nil
    func getReceiptRecord(index: Int) -> ReceiptRecordVM? {
        
        if let receiptRecords = self.receiptRecords {
            if index < receiptRecords.getCount() {
                return ReceiptRecordVM(with: receiptRecords[index])
            }
        }
        return nil
    }
    
    func checkIfRecordExist(index: Int) -> Bool {
        if let receiptRecords = self.receiptRecords {
            if index < receiptRecords.getCount() {
                return true
            }
        }
        return false
    }
    
    func refreshDatabase() {
        self.postMessage(msg: .initDatabaseUpdatesPostMessage)
        self.getDatabaseInfo { isSuccess in
            if isSuccess {
                self.postMessage(msg: .databaseUpdatesPostMessage)
            } else {
                self.databaseObj = nil
            }
        }
    }
    
    func refreshReceiptRecord() {
        self.postMessage(msg: .initReceiptRecordUpdatesPostMessage)
        self.getAllReceiptRecords{ isSuccess in
            if isSuccess {
                self.postMessage(msg: .receiptRecordUpdatesPostMessage)
            } else {
                self.receiptRecords = nil
            }
        }
    }
    
    func getCount() -> Int {
        if let receiptRecords = self.receiptRecords {
            return receiptRecords.getCount()
        } else {
            return 0
        }
    }
}


///
/// Receipt Manager manager core  Create, update, query  public API
///
extension ReceiptRecordManager {

    func insertNewReceiptRecord(receiptRecord: ReceiptRecord?, completion: @escaping (Bool) -> Void) {
        guard receiptRecord != nil else { return }
        notionService.insertNewReceiptRecords(newItem: receiptRecord!) { isSuccess, object, errorStruct in
            if isSuccess {
                if let jsonData = object as? Data {
                    do {
                        let insertedNewRecord = try JSONDecoder().decode(ReceiptRecords.ReceiptRecord.self, from: jsonData)
                        self.lock.lock()
                        self.receiptRecords?.insertNewReceiptRecord(receiptRecord: insertedNewRecord)
                        self.lock.unlock()
                        Logging.shared.logMsgEvent(loggingType: .INFO, message: "Success", funcName: #function, moduleName: #file)
                        completion(true)
                        return
                    } catch {
                        Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Newly inserted record received from server cannot be parsed", funcName: #function, moduleName: #file)
                    }
                } else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid jsonData", funcName: #function, moduleName: #file)
                }
            } else {
                if let errorStruct = errorStruct {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "\(errorStruct.status):\(errorStruct.message)", funcName: #function, moduleName: #file)
                } else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid errorStruct", funcName: #function, moduleName: #file)
                }
            }
            
            completion(false)
        }
    }
    
    // Default behaviour is remove the receipt record after updating it
    func updateNewReceiptRecord(receiptRecord: ReceiptRecord?, completion: @escaping (Bool)->Void) {
        guard receiptRecord != nil else { return }
        notionService.updateNewReceiptRecords(existingItem: receiptRecord!) { isSuccess, object, errorStruct in
            if isSuccess {
                Logging.shared.logMsgEvent(loggingType: .INFO, message: "Success", funcName: #function, moduleName: #file)
                // Updating new record must get the options of the store or cartegory of the database obj
                self.refreshDatabase()
                // Posting of updating of receipt records
                // so that main vc will update the table
                self.postMessage(msg: .receiptRecordUpdatesPostMessage)
                completion(true)
                return
            } else {
                if let errorStruct = errorStruct {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "\(errorStruct.status):\(errorStruct.message)", funcName: #function, moduleName: #file)
                } else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid errorStruct", funcName: #function, moduleName: #file)
                }
            }
            completion(false)
        }
    }
    
    private func getDatabaseInfo(completion: @escaping (Bool) -> Void) {
        notionService.getDatabaseInfo { isSuccess, object, errorStruct in
            if isSuccess {
                if let jsonData = object as? Data {
                    do {
                        self.databaseObj = try JSONDecoder().decode(Database.self, from: jsonData)
                        // Getting Receipt records
                        completion(true)
                        return
                    } catch {
                        Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Json Data not parsable", funcName: #function, moduleName: #file)
                    }
                } else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid JSON Object", funcName: #function, moduleName: #file)
                }
            } else {
                if let errorStruct = errorStruct {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "\(errorStruct.status):\(errorStruct.message)", funcName: #function, moduleName: #file)
                } else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid errorStruct", funcName: #function, moduleName: #file)
                }
            }
            
            completion(false)
        }
    }
    
    private func getAllReceiptRecords(completion: @escaping (Bool) -> Void) {
        notionService.getReceiptRecords { isSuccess, object, errorStruct in
            if isSuccess {
                if let jsonData = object as? Data {
                    do {
                        self.receiptRecords = try JSONDecoder().decode(ReceiptRecords.self, from: jsonData)
                        let str = String(decoding: jsonData, as: UTF8.self)
                        completion(true)
                        return
                    } catch {
                        Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Json Data not parsable", funcName: #function, moduleName: #file)
                    }
                } else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid JSON Object", funcName: #function, moduleName: #file)
                }
            } else {
                if let errorStruct = errorStruct {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "\(errorStruct.status):\(errorStruct.message)", funcName: #function, moduleName: #file)
                } else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid errorStruct", funcName: #function, moduleName: #file)
                }
            }
            completion(false)
        }
    }
}
