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
    
    func setInformation(title: String, price: Double) {
        titleTextView.text = title
        priceTextView.text = "$\(price)"
        
        titleValue = title
        priceValue = price
    }
    
    func setUIImage(uIImage: UIImage?) {
        if let theUIImage = uIImage {
            self.uIImage = uIImage
            self.uiImageView.image = self.uIImage
        }
    }
    
    // Calling this will trigger image download background process
    func setImage(imageUrl: String) {
        self.imageUrl = imageUrl
        
        if let imageUrl = self.imageUrl {
            DispatchQueue(label: "Download Image").async {
                let task = URLSession.shared.dataTask(with: URL(string:imageUrl)!) { data, response, error in
                    
                    guard let response = response as? HTTPURLResponse else {
                        // self.setDefaultImage()
                        return
                    }
                    
                    if response.statusCode == 200 {
                        guard let data = data, error == nil else {
                            // self.setDefaultImage()
                            return
                        }
                        self.uIImage = UIImage(data: data)
                        
                        DispatchQueue.main.async {
                            self.uiImageView.image = self.uIImage
                        }
                    } else {
//                        self.setDefaultImage()
                        return
                    }
                }
                task.resume()
            }
        }
    }
    
    func postProcess() {
        if priceValue == -1 {
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
