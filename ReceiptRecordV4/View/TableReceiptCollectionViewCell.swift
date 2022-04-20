//
//  TableReceiptCollectionViewCell.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 11/4/22.
//

import UIKit

class TableReceiptCollectionViewCell: UICollectionViewCell {

    private var recordVM: ReceiptRecordVM?
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageView.makeRounded(radius: 15)
    }
    
    
    func setRecordVM(recordVM: ReceiptRecordVM) {
        self.recordVM = recordVM
        self.setImage()
    }

    
    private func setImage() {
        guard let recordVM = recordVM else {
            return
        }
        self.imageView.loadImage(imageFromUrl: recordVM.getPropertiesValue(type: .ImageUrl)) { loadedImage in
            self.recordVM?.setUIImage(Image: loadedImage)
        }
    }
}
