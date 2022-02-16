//
//  GCHeaderView.swift
//  G-CoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 15.10.2021.
//

import UIKit

final class GCHeaderLabel: UILabel {
    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 15
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkGray.cgColor
        text = "G-Core Labs"
        textAlignment = .center
        textColor = UIColor(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.6)
        font = UIFont.systemFont(ofSize: 25)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
