//
//  GCShortDescriptionCellView.swift
//  G-CoreLabs_DemoOne
//
//  Created by Evgeniy Polyubin on 29.09.2021.
//

import UIKit

final class GCShortDescriptionCellView: UIView {
    let nameVideoLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Name", comment: "") + ": "
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let idVideolLabel: UILabel = {
        let label = UILabel()
        label.text = "ID: "
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nameVideoLabel)
        addSubview(idVideolLabel)
        backgroundColor = .white
        layer.borderWidth = 2
        layer.borderColor = UIColor.gray.cgColor
        createConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            nameVideoLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            nameVideoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            nameVideoLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            nameVideoLabel.bottomAnchor.constraint(equalTo: idVideolLabel.topAnchor, constant: -5),
            
            idVideolLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            idVideolLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -40),
            idVideolLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            idVideolLabel.heightAnchor.constraint(equalToConstant: idVideolLabel.intrinsicContentSize.height + 10),
        ])
    }
}
