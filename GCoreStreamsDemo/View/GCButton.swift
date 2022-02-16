//
//  GCButton.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 13.12.2021.
//

import UIKit

final class GCButton: UIButton {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 15
        backgroundColor = .blue
        setTitleColor(.white, for: .normal)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 200),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 0.3
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 0.3
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
        super.touchesEnded(touches, with: event)
    }
}
