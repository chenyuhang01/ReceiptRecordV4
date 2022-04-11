//
//  AddMainController.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 30/3/22.
//

import Foundation


import UIKit

class AddMainVC: UIViewController {
    
    var addSubVC: AddSubVC!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextButtonOnClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(self.addSubVC, animated: true)
    }
}
