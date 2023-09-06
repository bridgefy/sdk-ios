//
//  OnboardingViewController.swift
//  TicTacToe
//
//  Created by Francisco on 10/08/23.
//  Copyright © 2023 Bridgefy Inc. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol OnboardingViewControllerDelegate: AnyObject {
    func didFinishOnboarding()
}

class OnboardingViewController: UIViewController {
    weak var delegate: OnboardingViewControllerDelegate?
    let firstScreenView = FirstScreenView()
    let secondScreenView = SecondScreenView()
    let thirdScreenView = ThirdScreenView()
    let iconImageView = UIImageView()
    private var centralManager: CBCentralManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setGradientBackground()
    }
    
    func setGradientBackground() {
        let color1 =  UIColor(red: 235/255.0, green: 53/255.0, blue: 107/255.0, alpha: 1.0).cgColor
        let color2 =  UIColor(red: 238/255.0, green: 101/255.0, blue: 112/255.0, alpha: 1.0).cgColor
        let color3 =  UIColor(red: 238/255.0, green: 101/255.0, blue: 112/255.0, alpha: 1.0).withAlphaComponent(0.5).cgColor
        let color4 = UIColor.white.cgColor
        let color5 = UIColor.white.cgColor
        let color6 = UIColor.white.cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [color1,
                                color2,
                                color3,
                                color4,
                                color5,
                                color6]
        gradientLayer.locations = [0.0,
                                   0.2,
                                   0.4,
                                   0.5,
                                   0.6,
                                   1.0]
        gradientLayer.frame = self.view.bounds
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                    multiplier: 0.8),
            iconImageView.heightAnchor.constraint(equalTo: view.widthAnchor,
                                                     multiplier: 0.8),
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                  constant: 40)
        ])
        iconImageView.image = UIImage(named: "icon1")
        iconImageView.contentMode = .scaleAspectFit
        
        
        view.addSubview(thirdScreenView)
        NSLayoutConstraint.activate([
            thirdScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thirdScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thirdScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            thirdScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        thirdScreenView.transform = CGAffineTransform(translationX: view.frame.width,
                                                      y: 0)
        thirdScreenView.nextButton.addTarget(self,
                                             action: #selector(tapThirdButton),
                                             for: .touchUpInside)
        view.addSubview(secondScreenView)
        NSLayoutConstraint.activate([
            secondScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            secondScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            secondScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            secondScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        secondScreenView.transform = CGAffineTransform(translationX: view.frame.width,
                                                      y: 0)
        secondScreenView.nextButton.addTarget(self,
                                              action: #selector(tapSecondButton),
                                              for: .touchUpInside)
        view.addSubview(firstScreenView)
        NSLayoutConstraint.activate([
            firstScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            firstScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            firstScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            firstScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        firstScreenView.nextButton.addTarget(self,
                                             action: #selector(tapFirstButton),
                                             for: .touchUpInside)
    }
    
    @objc func tapFirstButton() {
        UIView.animate(withDuration: 0.35, delay: 0.0) {
            let offsetX = self.firstScreenView.frame.width
            self.firstScreenView.transform = .init(translationX: -offsetX,
                                                   y: 0)
            self.secondScreenView.transform = .identity
            self.iconImageView.setImage(UIImage(named: "icon2"))
        }
    }
    
    @objc func tapSecondButton() {
        centralManager = CBCentralManager(delegate: self,
                                 queue: .main, options: [:])
    }
    
    @objc func tapThirdButton() {
        delegate?.didFinishOnboarding()
    }
}

extension OnboardingViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        UIView.animate(withDuration: 0.35, delay: 0.0) {
            let offsetX = self.secondScreenView.frame.width
            self.secondScreenView.transform = .init(translationX: -offsetX,
                                                    y: 0)
            self.thirdScreenView.transform = .identity
            self.iconImageView.setImage(UIImage(named: "icon1"))
        }
    }
}

extension UIImageView{
    func setImage(_ image: UIImage?, animated: Bool = true) {
        let duration = animated ? 0.3 : 0.0
        UIView.transition(with: self,
                          duration: duration,
                          options: .transitionFlipFromBottom,
                          animations: {
            self.image = image
        }, completion: nil)
    }
}
