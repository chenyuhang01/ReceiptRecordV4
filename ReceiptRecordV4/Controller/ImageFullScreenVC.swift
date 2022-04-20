//
//  ImageFullScreenVC.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 11/4/22.
//

import Foundation
import UIKit

class ImageFullScreenVC: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private var loaded: Bool = false
    
    var recordVM: ReceiptRecordVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loaded = true
        self.reloadInfo()
    }
    
    func reloadInfo() {
        if !self.loaded { return }
        if let uIImage = recordVM.getUIImage() {
            imageView.image = uIImage
        } else {
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // self.imageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadInfo()
    }
}
