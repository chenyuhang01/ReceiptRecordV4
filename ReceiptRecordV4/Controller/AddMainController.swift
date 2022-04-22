//
//  AddMainController.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 30/3/22.
//

import Foundation
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields

import UIKit

class AddMainVC: UIViewController {
    
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var superView: UIView!
    
    
    private var titleTextField: MaterialInputField!
    private var storeTextField: MultiSelectInputField!
    private var categoryTextField: MultiSelectInputField!
    private var priceTextField: MaterialInputField!
    
    private var storePullDownBtn: UIButton!
    private var catPullDownBtn: UIButton!
    
    private var recordVM: ReceiptRecordVM?
    private var viewRetrived = false
    var receiptRecordManager: ReceiptRecordManager!
    var overlayManager: OverlayManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupKeyboardBehaviour()
        viewRetrived = true
        self.setupUI()
        self.setupNotificationObserver()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let storeTextField = self.storeTextField {
            storeTextField.setPullDownList(pullDownList: (receiptRecordManager.getDatabase()?.getProperties(type: .Store) as! DatabaseMultiOptions))
        }
        
        if let categoryTextField = self.categoryTextField {
            categoryTextField.setPullDownList(pullDownList: (receiptRecordManager.getDatabase()?.getProperties(type: .Category) as! DatabaseMultiOptions))
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AddSubVC
        destination.setRecordVM(recordVM: self.recordVM)
        let price = priceTextField.text.replacingOccurrences(of: "NT$ ", with: "")
        destination.setInfo(title: titleTextField.text, price: Double(price)!,  store: storeTextField.text, cat: categoryTextField.text)
        destination.overlayManager = self.overlayManager
        destination.receiptRecordManager = receiptRecordManager
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !self.checkIfAnyFieldEmpty()
    }
 
}

// Setting up UI Event and observer
extension AddMainVC {

    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text!.replacingOccurrences(of: "NT$ ", with: "")
        if !textField.text!.isEmpty {
            textField.text = "NT$ \(textField.text!)"
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// Setting up UI Component
extension AddMainVC {
    
    func setupUI() {
        guard let recordVM = self.recordVM else { dismiss(animated: false); return }
        
        // Set Image UI
        imageView.image = recordVM.getUIImage()
        imageContainer.dropShadowOnCell(width: 0, height: 15)
        imageContainer.makeRounded(radius: 15, masksToBounds: false)
        imageView.makeRounded(radius: 15, masksToBounds: true)
        
        
        // Set title text field
        let titleTextFieldPositionValue = AnchorPositionValue()
        titleTextFieldPositionValue.topAnchor = YAnchorPostion(anchor: imageView.bottomAnchor, value: 25)
        titleTextFieldPositionValue.leftAnchor = XAnchorPostion(anchor: self.superView.leadingAnchor, value: 30)
        titleTextFieldPositionValue.rightAnchor = XAnchorPostion(anchor: self.superView.trailingAnchor, value: -30)
        
        self.titleTextField = self.createMaterialTF(promptText: "Title", placeHolder: "Title Of The Receipt", superView: self.superView, sizeRect: CGRect(x: 0, y: 0, width: 0, height: 50), positionValue: titleTextFieldPositionValue, pullDownList: nil, btnFrame: nil)
        
        
        // Set Store Text Field
        let storeTextFieldpositionValue = AnchorPositionValue()
        storeTextFieldpositionValue.topAnchor = YAnchorPostion(anchor: self.titleTextField.textField!.bottomAnchor, value: 25)
        storeTextFieldpositionValue.leftAnchor = XAnchorPostion(anchor: self.superView.leadingAnchor, value: 30)
        
        self.storeTextField = self.createMaterialTF(
            promptText: "Store Name",
            placeHolder: "Store Of The Receipt",
            superView: self.superView,
            sizeRect: CGRect(x: 0, y: 0, width: 0, height: 50),
            positionValue: storeTextFieldpositionValue,
            pullDownList: (receiptRecordManager.getDatabase()?.getProperties(type: .Store) as! DatabaseMultiOptions),
            btnFrame: CGRect(x: 100, y: 100, width: 100, height: 100)) as? MultiSelectInputField ?? nil
        
        let storeBtnAnchorPosition = AnchorPositionValue()
        storeBtnAnchorPosition.rightAnchor = XAnchorPostion(anchor: self.superView.trailingAnchor, value: -30)
        storeBtnAnchorPosition.leftAnchor = XAnchorPostion(anchor: nil, value: -5)
        storeBtnAnchorPosition.height = 60
        storeBtnAnchorPosition.width = 70
        
        self.storeTextField.setPullDownTextTitle(title: "Choose")
        self.storeTextField.setPullDownBtnTextColor(textColor: .primaryColor)
        self.storeTextField.setBtnPosition(anchorPositionValue: storeBtnAnchorPosition)
        
        
        // Set Category Field Position
        let catTextFieldpositionValue = AnchorPositionValue()
        catTextFieldpositionValue.topAnchor = YAnchorPostion(anchor: self.storeTextField.textField!.bottomAnchor, value: 25)
        catTextFieldpositionValue.leftAnchor = XAnchorPostion(anchor: self.superView.leadingAnchor, value: 30)
        
        self.categoryTextField = self.createMaterialTF(
            promptText: "Category",
            placeHolder: "Category Of The Receipt",
            superView: self.superView,
            sizeRect: CGRect(x: 0, y: 0, width: 0, height: 50),
            positionValue: catTextFieldpositionValue,
            pullDownList: (receiptRecordManager.getDatabase()?.getProperties(type: .Category) as! DatabaseMultiOptions),
            btnFrame: CGRect(x: 100, y: 100, width: 100, height: 100)) as? MultiSelectInputField ?? nil
        
        let catBtnAnchorPosition = AnchorPositionValue()
        catBtnAnchorPosition.rightAnchor = XAnchorPostion(anchor: self.superView.trailingAnchor, value: -30)
        catBtnAnchorPosition.leftAnchor = XAnchorPostion(anchor: nil, value: -5)
        catBtnAnchorPosition.height = 60
        catBtnAnchorPosition.width = 70
        
        self.categoryTextField.setPullDownTextTitle(title: "Choose")
        self.categoryTextField.setPullDownBtnTextColor(textColor: .primaryColor)
        self.categoryTextField.setBtnPosition(anchorPositionValue: catBtnAnchorPosition)
        
        
        // Set Price Text Field
        let priceTextFieldPositionValue = AnchorPositionValue()
        priceTextFieldPositionValue.topAnchor = YAnchorPostion(anchor: self.categoryTextField.textField!.bottomAnchor, value: 25)
        priceTextFieldPositionValue.leftAnchor = XAnchorPostion(anchor: self.superView.leadingAnchor, value: 30)
        priceTextFieldPositionValue.rightAnchor = XAnchorPostion(anchor: self.superView.trailingAnchor, value: -30)
        
        self.priceTextField = self.createMaterialTF(promptText: "Price", placeHolder: "Price Of The Receipt", superView: self.superView, sizeRect: CGRect(x: 0, y: 0, width: 0, height: 50), positionValue: priceTextFieldPositionValue, pullDownList: nil, btnFrame: nil)
        
        // Only allow decimal
        self.priceTextField.textField!.keyboardType = .decimalPad
        self.priceTextField.textField!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    /*
     Method Name: createMaterialTF
     Description: Create material textfield. if pull down list and btn frame is not given, it will return MaterialInputfield. If so,
                  return the MultiSelectInputField
     */
    private func createMaterialTF(promptText: String, placeHolder: String, superView: UIView, sizeRect: CGRect, positionValue: AnchorPositionValue, pullDownList: DatabaseMultiOptions?, btnFrame: CGRect?) -> MaterialInputField? {
        var tf: MaterialInputField?
        if let options = pullDownList, let btnRect = btnFrame {
            tf = MultiSelectInputField(superView: superView, frame: sizeRect, pullDownList: options, btnFrame: btnRect)
            tf!.setAnchorValue(anchorPositionValue: positionValue)
        } else {
            tf = MaterialInputField(superView: superView, frame: sizeRect)
            tf!.makeAnchorTo(anchorPositionValue: positionValue)
        }
        
        if let tf = tf {
            tf.setTextFieldInfo(promptText: promptText, placeHolder: placeHolder)
            tf.styleTextField(primaryColor: .primaryColor, secondaryColor: .secondaryColor)
        }

        return tf
    }
}

// Keyboard and text value related method
extension AddMainVC {
    func clearTextField() {
        if self.viewRetrived {
            self.titleTextField?.text = ""
            self.storeTextField?.text = ""
            self.categoryTextField?.text = ""
            self.priceTextField?.text = ""
        }
    }
    
    func setRecordVM(recordVM: ReceiptRecordVM) {
        self.recordVM = recordVM
        self.clearTextField()
        if self.viewRetrived {
            imageView.image = recordVM.getUIImage()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 100
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    private func checkIfAnyFieldEmpty() -> Bool {
        return ( self.titleTextField.text.isEmpty ||
                 self.storeTextField.text.isEmpty ||
                 self.categoryTextField.text.isEmpty ||
                 self.priceTextField.text.isEmpty )
    }
    
    
    private func setupKeyboardBehaviour() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }
    
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
