//
//  TableReceiptViewCell.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 29/3/22.
//

import UIKit

class TableReceiptViewCell: UITableViewCell {

    @IBOutlet weak var titleTextView: UILabel!
    @IBOutlet weak var priceTextView: UILabel!
    @IBOutlet weak var uiImageView: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    
    private var priceValue: Double = 0
    private var titleValue: String?
    private var imageUrl: String?
    private var uIImage: UIImage?
    
    private var recordVM: ReceiptRecordVM?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.basicUISetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Make padding in the cell to look like space between cell
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setRecordVM(recordVM: ReceiptRecordVM?) {
        self.recordVM = recordVM
    }
    
    func setInformation( ) {
        guard let recordVM = recordVM else {
            return
        }
        
        titleTextView.text = recordVM.getPropertiesValue(type: .Title)
        priceTextView.text = "$\(recordVM.getPropertiesNumericValue(type: .Price))"
        
        // Calling this will trigger image download background process
//        self.uiImageView.loadImage(imageFromUrl: recordVM.getPropertiesValue(type: .ImageUrl)) { loadedUIImage in
//            recordVM.setUIImage(Image: loadedUIImage)
//        }
    }
    
    func postProcess() {
        guard let recordVM = recordVM else {
            priceTextView.isHidden = true
            uiImageView.makeRounded(radius: 15)
            return
        }
        if recordVM.getPropertiesNumericValue(type: .Price) == -1 {
            priceTextView.isHidden = true
            uiImageView.makeRounded(radius: 15)
        }
        else
        {
            priceTextView.isHidden = false
            uiImageView.makeRounded(radius: 45)
        }
    }
    
    private func basicUISetup() {
        // Image View Rounded wirh border
        self.setAllFontAdjustable(isAdjustable: true)
        self.makeRoundedCorner(cornerRadius: 15)
        self.dropShadowOnCell()
        self.setAllFontColor(fontColor: UIColor.secondaryColor)
    }
    
    private func makeRoundedCorner(cornerRadius: CGFloat){
        
        self.viewContainer.layer.cornerRadius = cornerRadius
        self.viewContainer.clipsToBounds = true

        self.contentView.layer.cornerRadius = cornerRadius
        self.contentView.clipsToBounds = true
    }
    
    private func dropShadowOnCell() {
        self.layer.shadowOpacity = 0.5
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 15
        self.layer.shadowOffset = CGSize(width: 10, height: self.frame.height - 20)
    }
    
    private func setAllFontAdjustable(isAdjustable: Bool) {
        titleTextView.adjustsFontSizeToFitWidth = isAdjustable
        priceTextView.adjustsFontSizeToFitWidth = isAdjustable
    }
    
    private func setAllFontColor(fontColor: UIColor) {
        titleTextView.textColor = fontColor
        priceTextView.textColor = fontColor
    }
}
