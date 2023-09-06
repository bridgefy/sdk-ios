//
//  JSQMessagesCollectionViewCell+RemoteUtils.swift
//  Remote Control
//
//  Created by Danno on 8/29/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

extension JSQMessagesCollectionViewCell {

    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(block(_:)) ||
            action == #selector(unblock(_:)) ||
            action == #selector(report(_:)) ||
            action == #selector(copy(_:)){
            return true
        }
        return false
    }
    
    @objc func block(_ menuController: UIMenuController) {
        self.performOnParentView(selector: #selector(block(_:)), withSender: menuController)
    }
    
    @objc func unblock(_ menuController: UIMenuController) {
        self.performOnParentView(selector: #selector(unblock(_:)), withSender: menuController)
    }
    
    @objc func report(_ menuController: UIMenuController) {
        self.performOnParentView(selector: #selector(report(_:)), withSender: menuController)
    }
    
    func performOnParentView(selector: Selector, withSender sender: Any?) {
        var view: UIView = self
        repeat {
            guard let superview = view.superview else {
                return
            }
            view = superview
        } while ( !(view is UICollectionView))
        
        let collectionView = view as! UICollectionView
        guard let indexPath = collectionView.indexPath(for: self) else {
            return
        }
        collectionView.delegate?.collectionView?(collectionView,
                                                performAction: selector,
                                                forItemAt: indexPath,
                                                withSender: sender)
    }
    

}
