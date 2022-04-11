//
//  FirebaseService.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 2/3/22.
//

import Foundation
import FirebaseStorage

class FirebaseService {
    
    
    // Creating singleton object
    public static let shared: FirebaseService = FirebaseService()
    
    // Make us of Storage reference object of the FirebaseStorage
    // to make firabase upload service
    private var storageRef: StorageReference? = Storage.storage().reference()
    
    
    private init() {
        
    }
    
    enum ImageType: String {
        case JPEG =  ".jpeg"
        case PNG = ".png"
    }
    
    struct FirebaseImageUploadInfo {
        var rootFolder: String?
        var imageName: String?
        var imageType: ImageType?
        var uiImage: UIImage?
    }
}

extension FirebaseService {
    
    // Internal use function
    private func getRefURL(refPath: String?, completionBlock: @escaping ((String?, FirebaseServiceError?) -> Void)) {
        
        Logging.shared.logMsgEvent(loggingType: .INFO, message: "Initiated", funcName: #function, moduleName: #file)
        
        guard let localStorageRef = self.storageRef else { completionBlock(nil, .FirebaseServiceStorageRefIsMissing); return }
        guard let refPath = refPath else { completionBlock(nil, .FirebaseServiceRefPathInvalid); return }
        
        
        // Execute the download url process
        localStorageRef.child(refPath).downloadURL { url, error in
            
            // check if error is valid
            // if valid throw download url fail error to caller
            guard error == nil else {
                completionBlock(nil, .FirebaseServiceDownloadUrlFail)
                return
            }
            
            // check if url is valid
            // if invalid throw url invalid error to caller
            guard let url = url else {
                completionBlock(nil, .FirebaseServiceUrlInvalid)
                return
            }
            Logging.shared.logMsgEvent(loggingType: .INFO, message: "Completed, \(url.absoluteString)", funcName: #function, moduleName: #file)
            // calling callback block
            completionBlock(url.absoluteString, nil)
        }
    }
    
    
    // API Interface
    private func UploadData(refPath: String?, data: Data?, completionBlock: @escaping ((FirebaseService.FirebaseServiceError?) -> Void)) {
        Logging.shared.logMsgEvent(loggingType: .DEBUG, message: "Initiated", funcName: #function, moduleName: #file)
        
        guard let localStorageRef = self.storageRef else { completionBlock(.FirebaseServiceStorageRefIsMissing); return }
        guard let refPath = refPath else { completionBlock(.FirebaseServiceRefPathInvalid); return }
        guard let dataToUpload = data else { completionBlock(.FirebaseServiceDataIsMissing); return }
        
        // Execute the download url process
        localStorageRef.child(refPath).putData(dataToUpload, metadata: nil) { metadata, error in
            // check if error is valid
            // if invalid throw upload data fail error to caller
            guard error == nil else { completionBlock(.FirebaseServiceDataUploadFail); return }
            
            // check if metadata is invalid
            // if invalid throw invalid upload data due to unknown reason
            if let metadata = metadata {
                Logging.shared.logMsgEvent(loggingType: .DEBUG, message: "Completed,\(metadata.size) bytes", funcName: #function, moduleName: #file)
                completionBlock(nil)
            } else {
                completionBlock(.FirebaseServiceInvalidDataUpload)
            }
        }
    }
    
    // Interface API for client to upload image through firebase service
    public func uploadImage(uploadInfo: FirebaseImageUploadInfo?, completionBlock: @escaping (String?, String?)->Void) {
        
        guard let uploadInfo = uploadInfo else { completionBlock(nil, "Upload information missing"); return }
        guard let imageName = uploadInfo.imageName else { completionBlock(nil, "Image name cannot be nil"); return }
        guard let imageType = uploadInfo.imageType else { completionBlock(nil, "Image type cannot be nil"); return }
        guard let uiImage = uploadInfo.uiImage else { completionBlock(nil, "Image file cannot be nil"); return }
        
        let refPath: String?
        let dataToUpload: Data?
        
        // construct ref path
        if let rootFolder = uploadInfo.rootFolder{
            refPath = "\(rootFolder)/\(imageName)\(imageType.rawValue)"
        } else {
            refPath = "/\(imageName)/\(imageName)\(imageType.rawValue)"
        }
        
        // convert uimage into data
        dataToUpload = uiImage.jpegData(compressionQuality: 100)

        // start uploading image
        self.UploadData(refPath: refPath, data: dataToUpload) { error in
            guard error == nil else {
                Logging.shared.logMsgEvent(loggingType: .ERROR, message: "\(error!.localizedDescription),\(refPath!)", funcName: #function, moduleName: #file)
                completionBlock(nil, "\(refPath!)")
                return
            }
            
            // if success, download url
            self.getRefURL(refPath: refPath) { urlString, error in
                guard error == nil else {
                    Logging.shared.logMsgEvent(loggingType: .ERROR, message: "\(error!.localizedDescription),\(refPath!)", funcName: #function, moduleName: #file)
                    completionBlock(nil, "\(error.debugDescription),\(refPath!)")
                    return
                }
                
                completionBlock(urlString,nil)
            }
        }
    }
}

extension FirebaseService {
    enum FirebaseServiceError: Swift.Error {
        case FirebaseServiceStorageRefIsMissing
        case FirebaseServiceRefPathInvalid
        case FirebaseServiceImageNameIsMissing
        case FirebaseServiceDataIsMissing
        case FirebaseServiceDataUploadFail
        case FirebaseServiceInvalidDataUpload
        case FirebaseServiceDownloadUrlFail
        case FirebaseServiceUrlInvalid
        case unknown
    }
}

