//
//  AddMainController.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 30/3/22.
//

import Foundation


import UIKit

class AddMainVC: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var storeTextField: UITextField!
    @IBOutlet private weak var categoryTextField: UITextField!
    
    private var recordVM: ReceiptRecordVM?
    private var viewRetrived = false
    var addSubVC: AddSubVC!
    var receiptRecordManager: ReceiptRecordManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let recordVM = self.recordVM else { dismiss(animated: false); return }
        self.setupKeyboardBehaviour()
        viewRetrived = true
        imageView.image = recordVM.getUIImage()
        imageView.makeRounded(radius: 15)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AddSubVC
        destination.setRecordVM(recordVM: self.recordVM)
        destination.setInfo(title: titleTextField.text!, price: Double(priceTextField.text!)!, store: storeTextField.text!, cat: categoryTextField.text!)
        destination.receiptRecordManager = receiptRecordManager
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !self.checkIfAnyFieldEmpty()
    }
}

extension AddMainVC {
    
    func clearTextField() {
        if self.viewRetrived {
            titleTextField.text = ""
            storeTextField.text = ""
            categoryTextField.text = ""
            priceTextField.text = ""
        }
    }
    
    func setRecordVM(recordVM: ReceiptRecordVM) {
        self.recordVM = recordVM
        self.clearTextField()
        if self.viewRetrived {
            imageView.image = recordVM.getUIImage()
            imageView.makeRounded(radius: 15)
        }
    }

    private func checkIfAnyFieldEmpty() -> Bool {
        guard let title = titleTextField.text, !title.isEmpty,
              let store = storeTextField.text, !store.isEmpty,
              let cat = categoryTextField.text, !cat.isEmpty else { return true }
        
        return false
    }
    
    private func setupKeyboardBehaviour() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }
}

///
/// Keyboard setting
///
extension AddMainVC {
    
    @objc func keyboardWillAppear() {
        //Do something here
    }

    @objc func keyboardWillDisappear() {
        //Do something here
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

