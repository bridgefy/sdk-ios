//
//  InitialViewController.swift
//  TicTacToe
//
//  Created by Bridgefy on 5/22/17.
//  Copyright © 2017 Bridgefy. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITextFieldDelegate {
    
    let maxCharacters = 20

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
        nameTextField.delegate = self
        addStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addStyle() {
        //Textfield
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0.0,
                              y: nameTextField.frame.size.height - width,
                              width: nameTextField.frame.size.width,
                              height: width)
        border.borderWidth = width
        nameTextField.layer.addSublayer(border)
        nameTextField.layer.masksToBounds = true
        
        //Button
        startButton.layer.cornerRadius = 6.0
        startButton.layer.borderWidth = 1.0
        startButton.layer.borderColor = UIColor.gray.cgColor
        
    }
    
    func cleanTextFieldIfNeeded(sender: UITextField) {
        if sender.text == nil {
            sender.text = ""
        }
    }
    
    @IBAction func didChangeText(sender: UITextField) {
    }
    
    @IBAction func startApp(sender: UIButton) {
        if self.nameTextField.text == "" {
            self.askForUsername()
        } else {
            self.sendStartEvent()
        }
    }
    
    private func sendStartEvent() {
        UserDefaults.standard.setValue(nameTextField?.text, forKey: StoredValues.username)
        let username: String = nameTextField!.text!
        let userInfo: [AnyHashable : Any] = [StoredValues.username: username]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.userReady),
                                        object: self,
                                        userInfo: userInfo)
        self.dismiss(animated: true)
    }
    
    private func askForUsername() {
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        self.cleanTextFieldIfNeeded(sender: self.nameTextField)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.cleanTextFieldIfNeeded(sender: self.nameTextField)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = string
        let existingChars = self.nameTextField.text?.count ?? 0
        if (existingChars + text.count) > maxCharacters {
            return false
        }

        let range = text.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted)
        return range == nil
    }

}

// - MARK: UIAdaptivePresentationControllerDelegate

extension InitialViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}


