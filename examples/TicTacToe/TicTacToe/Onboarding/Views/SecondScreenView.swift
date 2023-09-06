//
//  SecondScreenView.swift
//  TicTacToe
//
//  Created by Francisco on 15/08/23.
//  Copyright © 2023 Bridgefy Inc. All rights reserved.
//

import UIKit

class SecondScreenView: UIView {
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let footLabel = UILabel()
    let nextButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                               constant: -30),
            nextButton.heightAnchor.constraint(equalToConstant: 60),
            nextButton.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -40),
        ])
        nextButton.backgroundColor = APP_RED_COLOR
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nextButton.clipsToBounds = true
        nextButton.layer.masksToBounds = true
        nextButton.setTitle("Allow Bluetooth Permissions", for: .normal)
        
        addSubview(footLabel)
        footLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: 20),
            footLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                               constant: -20),
            footLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor,
                                              constant: -40)
        ])
        footLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        footLabel.text = "Don't worry, we will never share your personal data with anyone."
        footLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        footLabel.numberOfLines = 0
        footLabel.textAlignment = .center
        
        addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bodyLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                               constant: -20),
            bodyLabel.bottomAnchor.constraint(equalTo: footLabel.topAnchor,
                                              constant: -30)
        ])
        bodyLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        bodyLabel.text = "Before you dive into the fun, we need your permission to enable Bluetooth on your device. Bluetooth is necessary to establish a secure and fast connection with other players. "
        bodyLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                               constant: -40),
            titleLabel.bottomAnchor.constraint(equalTo: bodyLabel.topAnchor,
                                              constant: -20)
        ])
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        titleLabel.text = "Bluetooth Permissions"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
    }
    
}

