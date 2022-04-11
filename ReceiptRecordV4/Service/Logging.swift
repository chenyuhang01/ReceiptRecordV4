//
//  Logging.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 2/3/22.
//

import Foundation
import os

class Logging {
    
    public static let shared = Logging()
    private let defaultLog = Logger()
    
    enum LogginType: String {
        case INFO = "info"
        case DEBUG = "debug"
        case ERROR = "error"
    }
    
    private init() {
        
    }
}

extension Logging {
    
    public func logMsgEvent(loggingType: LogginType, message: String, funcName: String?, moduleName: String?) {
        var msg: String = ""
        if let funcName = funcName, let moduleName = moduleName {
            let moduleNameGroup = moduleName.components(separatedBy: "/")
            msg = "[\(moduleNameGroup.last!)][\(funcName)][\(message)]"
        } else if let funcName = funcName {
            msg = "[\(funcName)][\(message)]"
        }  else if let moduleName = moduleName {
            msg = "[\(moduleName)][\(message)]"
        } else {
            msg = "[\(message)]"
        }
        
        switch(loggingType) {
            case .INFO:
                self.defaultLog.info("\(msg)")
                break
            case .DEBUG:
                self.defaultLog.debug("\(msg)")
                break
            case .ERROR:
                self.defaultLog.error("\(msg)")
                break
        }
    }
}
