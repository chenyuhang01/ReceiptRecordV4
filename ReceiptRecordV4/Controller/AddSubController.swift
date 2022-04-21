//
//  AddSubController.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 30/3/22.
//

import Foundation


import UIKit

class AddSubVC: UIViewController {
    
    @IBOutlet weak var calendarDatePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var finishedBtn: UIBarButtonItem!
    
    private var recordVM: ReceiptRecordVM?
    private var titleText: String = ""
    private var price: Double = -1
    private var store: String = ""
    private var category: String = ""
    private var chosenDate: Date = Date()
    var receiptRecordManager: ReceiptRecordManager!
    var overlayManager: OverlayManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarDatePicker.setDate(self.chosenDate, animated: true)
        recordVM?.setPropertiesDateValue(type: .PurchasedDate, value: self.chosenDate)
        self.dateLabel.text = recordVM?.getPropertiesValue(type: .PurchasedDate)
        self.finishedBtn.action = #selector(buttonTapped)
        self.finishedBtn.target = self
    }
    
    @objc func buttonTapped() {
        recordVM?.setPropertiesValue(type: .Title, value: self.titleText)
        recordVM?.setPropertiesNumericValue(type: .Price, value: price)
        recordVM?.setPropertiesArrayStringValue(type: .Category, valueList: [self.category])
        recordVM?.setPropertiesArrayStringValue(type: .Store, valueList: [self.store])
        self.overlayManager.showLoadingView()
        self.receiptRecordManager.updateNewReceiptRecord(receiptRecord: recordVM?.receiptRecord) { isSuccess in
            if isSuccess {
                
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        self.chosenDate = self.calendarDatePicker.date
        recordVM?.setPropertiesDateValue(type: .PurchasedDate, value: self.chosenDate)
        
        self.dateLabel.text = recordVM?.getPropertiesValue(type: .PurchasedDate)
    }
}


extension AddSubVC {
    func setRecordVM(recordVM: ReceiptRecordVM?) {
        self.recordVM = recordVM
    }
    
    func setInfo(title: String,
                  price: Double,
                  store: String,
                  cat: String) {
        self.titleText = title
        self.price = price
        self.store = store
        self.category = cat
        
        self.chosenDate = Date()
    }
}
