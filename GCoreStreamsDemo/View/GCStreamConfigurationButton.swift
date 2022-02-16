//
//  GCStreamConfigurationButton.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 08.12.2021.
//

import UIKit

final class GCStreamConfigurationButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 15
        backgroundColor = .blue
        setTitleColor(.white, for: .normal)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),
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
