//
//  MultiSelectInputField.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 22/4/22.
//

import Foundation
import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields


class MaterialInputField {
    
    internal var anchorPositionValue: AnchorPositionValue?
    private var outlinedTextField: MDCOutlinedTextField?
    internal var parentView: UIView?
    var text: String {
        get {
            if let textStr = self.outlinedTextField!.text {
                return textStr
            } else {
                return ""
            }
        }
        
        set {
            if let outlinedTextField = outlinedTextField {
                outlinedTextField.text = newValue
            }
        }
    }
    
    var textField: MDCOutlinedTextField? {
        get {
            return self.outlinedTextField
        }
        
        set {
            // Only can set once
            if let _ = self.outlinedTextField {
                return
            } else {
                self.outlinedTextField = newValue
            }
        }
    }
    
    init(superView: UIView, frame: CGRect) {
        self.textField = MDCOutlinedTextField(frame: frame)
        self.parentView = superView
        if let textField = textField {
            self.parentView?.addSubview(textField)
        }
    }
    
    func setTextFieldInfo(promptText: String, placeHolder: String) {
        if let textField = textField {
            textField.label.text = promptText
            textField.placeholder = placeHolder
        }
    }
    
    func styleTextField(primaryColor: UIColor, secondaryColor: UIColor) {
        if let textField = textField {
            textField.sizeToFit()
            textField.setOutlineColor(secondaryColor, for: .editing)
            textField.setTextColor(.white, for: .editing)
            textField.setFloatingLabelColor(secondaryColor, for: .editing)
            textField.setFloatingLabelColor(primaryColor, for: .normal)
            
            textField.setOutlineColor(primaryColor, for: .normal)
            textField.setTextColor(primaryColor, for: .normal)
            textField.setNormalLabelColor(primaryColor, for: .normal)
            textField.setNormalLabelColor(primaryColor, for: .editing)
            textField.tintColor = primaryColor
        }
    }
    
    func setAnchorValue(anchorPositionValue: AnchorPositionValue) {
        self.anchorPositionValue = anchorPositionValue
    }
    
    func makeAnchorTo(anchorPositionValue: AnchorPositionValue) {
        self.setAnchorValue(anchorPositionValue: anchorPositionValue)
        
        if let textField = textField, let positionInfo = self.anchorPositionValue {
            textField.anchorPostiionTo(position: positionInfo)
        }
    }
}


class MultiSelectInputField: MaterialInputField {
    
    var pullDownListButton: UIButton?
    var pullDownList: DatabaseMultiOptions?
    
    convenience init(superView: UIView, frame: CGRect, pullDownList: DatabaseMultiOptions?, btnFrame: CGRect) {
        self.init(superView: superView, frame: frame)
        self.createPullDownListBtn(frameSize: btnFrame)
        self.setPullDownList(pullDownList: pullDownList)
    }

    
    func setBtnPosition(anchorPositionValue: AnchorPositionValue) {
        
        if let textFieldPositionValue = super.anchorPositionValue {
            let positionValue = AnchorPositionValue()
            positionValue.topAnchor = textFieldPositionValue.topAnchor
            positionValue.rightAnchor = anchorPositionValue.rightAnchor
            positionValue.width = anchorPositionValue.width ?? 0
            positionValue.height = anchorPositionValue.height ?? 0
            if let pullDownListButton = pullDownListButton {
                pullDownListButton.anchorPostiionTo(position: positionValue)
                
                // Need to reset the textfield anchor point
                textFieldPositionValue.rightAnchor = XAnchorPostion(
                    anchor: self.pullDownListButton!.leadingAnchor,
                    value: anchorPositionValue.leftAnchor?.anchorValue ?? 0)
                super.makeAnchorTo(anchorPositionValue: textFieldPositionValue)
            }
        }
    }
    
    private func createPullDownListBtn(frameSize: CGRect) {
        let button = UIButton(type: .roundedRect)
        button.frame = frameSize
        if let pView = super.parentView {
            pView.addSubview(button)
        }
        button.showsMenuAsPrimaryAction = true

        self.pullDownListButton = button
    }
    
    func setPullDownTextTitle(title: String) {
        if let pullDownListButton = pullDownListButton {
            pullDownListButton.setTitle(title, for: .normal)
        }
    }
    
    func setPullDownBtnTextColor(textColor: UIColor) {
        if let pullDownListButton = pullDownListButton {
            pullDownListButton.setTitleColor(textColor, for: .normal)
        }
    }
    
    func setPullDownList(pullDownList: DatabaseMultiOptions?) {
        self.pullDownList = pullDownList
        self.configureMultiSelectList()
    }
    
    func configureMultiSelectList() {
        var uiElementArray: [UIMenuElement] = []
        
        if let pullDownListButton = pullDownListButton,
            let multiOption = self.pullDownList,
            let options = multiOption.options {
            pullDownListButton.menu = UIMenu(children: uiElementArray)
            
            for option in options {
                uiElementArray.append(
                    UIAction(title: option.name, handler: { action in
                        DispatchQueue.main.async {
                            if let textfield = super.textField {
                                textfield.text = option.name
                            }
                        }
                    })
                )
            }
            pullDownListButton.menu = UIMenu(children: uiElementArray)
        }
    }
}
