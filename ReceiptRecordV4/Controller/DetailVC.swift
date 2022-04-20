//
//  DetailViewController.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 11/4/22.
//

import Foundation
import UIKit

class DetailVC: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var storeLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    
    var recordVM: ReceiptRecordVM!
    var receiptManager: ReceiptRecordManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.makeRounded(radius: 15)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(ImageOnClick))
        self.imageView.addGestureRecognizer(gesture)
        self.imageView.isUserInteractionEnabled = true
        self.deleteButton.layer.cornerRadius = 15
        self.deleteButton.clipsToBounds = true
        
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.priceLabel.adjustsFontSizeToFitWidth = true
        self.storeLabel.adjustsFontSizeToFitWidth = true
        self.categoryLabel.adjustsFontSizeToFitWidth = true
        self.dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageFullVC = segue.destination as? ImageFullScreenVC {
            imageFullVC.recordVM = self.recordVM
            imageFullVC.reloadInfo()
        }
    }
    
    @objc func ImageOnClick() {
        performSegue(withIdentifier: "presentImageFS", sender: self)
    }
    
    func reloadInfo() {
        if let uIImage = recordVM.getUIImage() {
            imageView.image = uIImage
        }
        else
        {
            imageView.loadImage(imageFromUrl: recordVM.getPropertiesValue(type: .ImageUrl)) { loadedImage in
            guard let loadedImage = loadedImage else {
                return
            }

            self.recordVM.receiptRecord.setUIImage(uiImage: loadedImage)
            }
        }
        titleLabel.text = recordVM.getPropertiesValue(type: .Title)
        priceLabel.text = "NT$ \(recordVM.getPropertiesNumericValue(type: .Price))"
        
        storeLabel.text = recordVM.getPropertiesArrayStringValue(type: .Store)[0]
        categoryLabel.text = recordVM.getPropertiesArrayStringValue(type: .Category)[0]
        dateLabel.text = recordVM.getPropertiesValue(type: .PurchasedDate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.imageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadInfo()
    }
    @IBAction func deleteButtonOnClicked(_ sender: Any) {
        self.recordVM.markAsArchived()
        
        self.receiptManager.updateNewReceiptRecord(receiptRecord: self.recordVM.receiptRecord) { isSuccess in
            if isSuccess {
                print("Success")
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                print("Failed")
            }
        }
    }
}
