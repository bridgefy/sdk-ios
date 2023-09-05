//
//  CommandClientViewController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit
import AVFoundation

var alreadyAdmin = false

class CommandClientViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var presentationLabel: UILabel!
    @IBOutlet weak var presentationImage: UIImageView!
    
    var lastCommand = Command.color
    var playWorkItem: DispatchWorkItem?
    var player: AVAudioPlayer?

    
    weak var transmissionManager: TransmissionManager? {
        didSet {
            self.transmissionManager?.commandDelegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 250
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func askForAdmin(_ sender: Any) {
        if alreadyAdmin {
            self.performSegue(withIdentifier: "showAdminView", sender: self)
            return
        }
        let alertController = UIAlertController(title: "Enter the password to access the administrator panel",
                                                message: "",
                                                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        })
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: { [unowned self] (_ action: UIAlertAction) -> Void in
            if (alertController.textFields?[0].text == adminPassword) {
                alreadyAdmin = true
                self.performSegue(withIdentifier: "showAdminView", sender: self)
            }
            else {
                self.showWrongPasswordAlert()
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.view.tintColor = #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1)
        present(alertController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAdminView" {
            let adminVC = segue.destination as! AdminViewTabBarController
            adminVC.transmissionManager = self.transmissionManager
        }
    }
    
    func showWrongPasswordAlert() {
        let alertController = UIAlertController(title: "Wrong password!", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.view.tintColor = #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1)
        present(alertController, animated: true)
    }
    
    // MARK: -
    
    func showImage(from dictionary: [String: Any]) {
        let imageIndex = dictionary[PacketKeys.image] as! Int
        var image: UIImage!
        if imageIndex == 0 {
            image = #imageLiteral(resourceName: "map")
        } else {
            image = #imageLiteral(resourceName: "telephone")
        }
        
        self.resetView()
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = image
        self.imageView.isHidden = false
    }
    
    func showColor(from dictionary: [String: Any]) {
        let c = dictionary[PacketKeys.color] as! String
        let colors = c.split(separator: "-")
        
        if colors.count >= 3 {
            if let red = Float(String(colors[0])),
                let green = Float(String(colors[1])),
               let blue = Float(String(colors[2])) {
                let receivedColor = UIColor(red: CGFloat(red / 255),
                                            green: CGFloat(green / 255),
                                            blue: CGFloat(blue / 255),
                                            alpha: 1)
                
                self.resetView()
                self.view.backgroundColor = receivedColor
                self.imageView.contentMode = .center
                self.imageView.image = #imageLiteral(resourceName: "whiteLogo")
                self.imageView.isHidden = false
                
            } else {
                // Handle invalid color components
            }
        } else {
            // Handle insufficient color components
        }
    }
    
    func turnOnFlashlight(flag: Bool) {
        
        guard let flashlight = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Can't play with torch")
            return
        }
        
        if flashlight.isTorchAvailable && flashlight.hasTorch {
            
            do {
                try flashlight.lockForConfiguration()
            } catch let err as NSError {
                print("ERROR: \(err.localizedDescription)")
                return
            }
            
            if flag {
                
                if flashlight.torchMode == .on {
                    // If flashlight is turned on, the command is ignored
                    return
                } else {
                    flashlight.torchMode = .on
                    self.resetView()
                    self.imageView.image = #imageLiteral(resourceName: "Flashlight")
                    self.imageView.isHidden = false
                    self.imageView.contentMode = .center
                    self.perform(#selector(turnOffFlashlight),
                                 with: nil,
                                 afterDelay: 15.0)
                }
                
            } else {
                flashlight.torchMode = .off
                if self.lastCommand == .flashlight {
                    self.resetViewToInitial()
                }
            }
            
            flashlight.unlockForConfiguration()
        }
    }
    
    @objc func turnOffFlashlight() {
        self.turnOnFlashlight(flag: false)
    }
    
    func showPlaySoundScreen() {
        self.resetView()
        self.imageView.image = #imageLiteral(resourceName: "speaker")
        self.imageView.contentMode = .center
        self.imageView.isHidden = false
        self.playSound()
        if let playWorkItem = self.playWorkItem {
            playWorkItem.cancel()
            self.playWorkItem = nil
        }
        self.playWorkItem = DispatchWorkItem.init(flags: .inheritQoS, block: { [weak self] in
            if self?.lastCommand == .sound {
                self?.resetViewToInitial()
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + Sound.length, execute: playWorkItem!)
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: Sound.fileName, withExtension: Sound.ext) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func showText(from dictionary: [String: Any]) {
        let text = dictionary[PacketKeys.text] as! String
        self.resetView()
        self.messageLabel.isHidden = false
        self.messageLabel.text = text
    }
    
    func resetViewToInitial() {
        self.resetView()
        self.presentationLabel.isHidden = false
        self.presentationImage.isHidden = false
    }
    
    func resetView() {
        self.messageLabel.text = ""
        self.imageView.isHidden = true
        self.messageLabel.isHidden = true
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func updateScreen(forCommand command: Command, dictionary: [String: Any]?) {
        self.presentationImage.isHidden = true
        self.presentationLabel.isHidden = true
        self.lastCommand = command
        switch command {
        case .image:
            self.showImage(from: dictionary!)
        case .color:
            self.showColor(from: dictionary!)
        case .flashlight:
            self.turnOnFlashlight(flag: true)
        case .text:
            self.showText(from: dictionary!)
        case .sound:
            self.showPlaySoundScreen()
        default:
            return
        }
    }

}

extension CommandClientViewController: TransmissionManagerCommandDelegate {
    func transmissionManager(_ manager: TransmissionManager, didReceiveCommand command: Command, dictionary: [String: Any]) {
        self.updateScreen(forCommand: command, dictionary: dictionary)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
