//
//  InputTextViewController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

let maxCharacters = 400

class InputTextViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentTextMessageLabel: UILabel!
    @IBOutlet weak var newMessageButton: UIButton!
    weak var auxAlertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newMessageButton.layer.cornerRadius = 8.0
        self.newMessageButton.clipsToBounds = true
        
        self.currentTextMessageLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendNewText(sender: Any) {
        let alertController = UIAlertController.init(title: "Enter the new message to send",
                                                    message: "\(maxCharacters) characters left", preferredStyle: .alert)
        alertController.addTextField { [unowned self] (textField) in
            textField.placeholder = "New message"
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .send
            textField.delegate = self
        }
        let cancelAction = UIAlertAction.init(title: "Cancel",
                                              style: .cancel,
                                              handler: { [unowned self] action in
                                                    self.sendMessage("")
                                                })
        let okAction = UIAlertAction.init(title: "Send",
                                              style: .default,
                                              handler: { [unowned self] action in
                                                self.sendMessage(alertController.textFields!.first!.text!)
                                                })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.view.tintColor = #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1)
        self.present(alertController,
                     animated: true,
                     completion: nil)
        self.auxAlertController = alertController
    }
    
    func sendMessage(_ text: String) {
        let cleanMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if  cleanMessage != "" {
            self.currentTextMessageLabel.text = cleanMessage
            let tabBarController = self.tabBarController as! AdminViewTabBarController
            tabBarController.sendCommand(.text, withObject: cleanMessage as Any)
        }
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (range.length == 0) {
            let newLength: Int = textField.text!.lengthOfBytes(using: String.Encoding.utf8) + string.lengthOfBytes(using: String.Encoding.utf8)
            if newLength <= maxCharacters {
                let remainingCharacters: UInt = UInt(maxCharacters - newLength)
                auxAlertController?.message = "\(remainingCharacters) characters left"
                return true
            }
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        self.sendMessage(textField.text!)
        return true
    }
    

}
