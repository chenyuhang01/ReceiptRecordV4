//
//  HeaderViewCell.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 30/3/22.
//

import UIKit

class HeaderViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setTitle(title: String) {
        self.titleLabel.text = title
        self.titleLabel.textColor = UIColor.tertiaryColor
        self.titleLabel.setUnderlineBorder(bottomLineColor: UIColor.tertiaryColor)
    }
    
    func setWidth(widthOfCell width: CGFloat) {
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: width - 10, height: self.frame.height - 10)
    }
}
