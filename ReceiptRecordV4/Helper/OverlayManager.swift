//
//  OverlayManager.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 20/4/22.
//

import Foundation
import UIKit

class OverlayManager {
    private var overlayView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    public static let shared: OverlayManager = OverlayManager()
    
    private init() {
        
    }
    
    func showLoadingView() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window
        else {
          return
        }
        
        overlayView.frame = CGRect(x: 0, y:0, width: 80, height: 80)
        overlayView.center = CGPoint(x: window.frame.width / 2.0, y: window.frame.height / 2.0)
        overlayView.backgroundColor = UIColor.gray
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10

        activityIndicator.frame = CGRect(x: 0, y:0, width: 40, height: 40)
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(activityIndicator)
        window.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    public func hideOverlayView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.overlayView.removeFromSuperview()
        }
    }
}
