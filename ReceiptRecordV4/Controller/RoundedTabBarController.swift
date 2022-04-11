//
//  RoundedTabBarController.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 29/3/22.
//
import UIKit


class RoundedTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
      
      let layer = CAShapeLayer()
      let screenSize: CGRect = UIScreen.main.bounds
      layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.tabBar.bounds.width, height: screenSize.height - self.tabBar.frame.minY + 65), cornerRadius: 20).cgPath
      layer.shadowColor = UIColor.white.cgColor
      layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
      layer.shadowRadius = 25.0
      layer.shadowOpacity = 0.3
      layer.borderWidth = 1.0
      layer.opacity = 1.0
      layer.isHidden = false
      layer.masksToBounds = false
      layer.fillColor = UIColor(red: 253, green: 255, blue: 252, alpha: 100).cgColor

      self.tabBar.layer.insertSublayer(layer, at: 0)
  }
}
