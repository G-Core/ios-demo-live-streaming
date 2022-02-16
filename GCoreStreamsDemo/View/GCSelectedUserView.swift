//
//  GCSelectedTokenView.swift
//  G-CoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 15.10.2021.
//

import UIKit

final class GCSelectedUserView: UIView {
    private let title = UILabel()
    private let selectedUserLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        addSubview(title)
        addSubview(selectedUserLabel)
        
        backgroundColor = .white
        layer.cornerRadius = 25
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkGray.cgColor
        clipsToBounds = true
        
        setupTitle()
        setupSelectedUserLabel()
        createConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitle() {
        title.text = NSLocalizedString("The selected user", comment: "")
        title.backgroundColor = .darkGray
        title.textColor = .white
        title.textAlignment = .center
        title.adjustsFontSizeToFitWidth = true
        title.font = UIFont.systemFont(ofSize: 20)
    }
    
    private func setupSelectedUserLabel() {
        selectedUserLabel.numberOfLines = 0
        selectedUserLabel.textColor = UIColor(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.6)
        selectedUserLabel.font = UIFont.systemFont(ofSize: 12)
        selectedUserLabel.textAlignment = .center
        selectedUserLabel.backgroundColor = .white
    }
    
    private func createConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false
        selectedUserLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: leftAnchor),
            title.topAnchor.constraint(equalTo: topAnchor),
            title.rightAnchor.constraint(equalTo: rightAnchor),
            title.heightAnchor.constraint(equalToConstant: title.intrinsicContentSize.height + 15),
            
            selectedUserLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            selectedUserLabel.topAnchor.constraint(equalTo: title.bottomAnchor),
            selectedUserLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            selectedUserLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func updateUser(_ user: String) {
        selectedUserLabel.text = user
    }
}
