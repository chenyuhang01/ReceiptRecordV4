//
//  FirebaseManager.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 7/3/22.
//

import Foundation
import UIKit

class FirebaseManager {
    // Apply singleton pattern
    static let shared: FirebaseManager = FirebaseManager()
    
    private init() {
        
    }
}


extension FirebaseManager {
    func uploadingImage(uiImage: UIImage, imageName: String, completion: @escaping (String?, String?) -> Void) {
        var imageUploadInfo =  FirebaseService.FirebaseImageUploadInfo()
        
        imageUploadInfo.uiImage = uiImage
        imageUploadInfo.imageType = .JPEG
        imageUploadInfo.imageName = imageName
        imageUploadInfo.rootFolder = "images"
        
        FirebaseService.shared.uploadImage(uploadInfo: imageUploadInfo) { urlString, errorMsg in
            guard errorMsg == nil else {
                if let errorMsg = errorMsg {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: errorMsg, funcName: #function, moduleName: #file)
                    completion(nil, errorMsg)
                } else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid errorMsg", funcName: #function, moduleName: #file)
                }
                return
            }
            
            if let urlString = urlString {
                Logging.shared.logMsgEvent(loggingType: .INFO, message: "Success,\(urlString)", funcName: #function, moduleName: #file)
                completion(urlString, nil)
                return
            }
            Logging.shared.logMsgEvent(loggingType: .ERROR, message: "Invalid errorMsg and urlString ", funcName: #function, moduleName: #file)
            completion(nil, nil)
        }
    }
}

