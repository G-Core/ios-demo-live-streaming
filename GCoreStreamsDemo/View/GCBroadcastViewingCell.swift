//
//  CGVideoCollectionViewCell.swift
//  G-CoreLabsDemoOne
//
//  Created by Evgeniy Polyubin on 27.08.2021.
//

import UIKit

protocol GCBroadcastViewingCellDelegate: AnyObject {
    func tappedUnwrappedDescription(_ cell: GCBroadcastViewingCell)
}

final class GCBroadcastViewingCell: UICollectionViewCell {
    weak var delegate: GCBroadcastViewingCellDelegate?
    
    let previewImageView = UIImageView()
    let posterMissingLabel = UILabel()
    let indicatorView = UIActivityIndicatorView(style: .gray)
    let descriptionView = GCShortDescriptionCellView(frame: .zero)
    private let preview = UIView()
    private let unwrappedDescriptionButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        setupSelf()
        setupPreview()
        setupIndicator()
        setupUnwrappedDescriptionButton()
        
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        posterMissingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        preview.addSubview(posterMissingLabel)
        posterMissingLabel.textAlignment = .center
        posterMissingLabel.textColor = .darkGray.withAlphaComponent(0.8)
        posterMissingLabel.text = "Poster is missing"
        
        createConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSelf() {
        layer.cornerRadius = 15
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = layer.cornerRadius
    }
    
    private func setupPreview() {
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.backgroundColor = UIColor.lightGray
        preview.layer.cornerRadius = layer.cornerRadius
        addSubview(preview)
        
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.clipsToBounds = true
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.backgroundColor = .lightGray
        previewImageView.layer.cornerRadius = layer.cornerRadius
        previewImageView.addSubview(descriptionView)
        preview.addSubview(previewImageView)
    }
    
    private func setupIndicator() {
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.startAnimating()
        addSubview(indicatorView)
    }
    
    private func setupUnwrappedDescriptionButton() {
        let image = UIImage(named: "info.circle.icon")?.withRenderingMode(.alwaysOriginal)
        
        addSubview(unwrappedDescriptionButton)
        unwrappedDescriptionButton.setImage(image, for: .normal)
        unwrappedDescriptionButton.imageView?.contentMode = .scaleAspectFill
        unwrappedDescriptionButton.addTarget(self, action: #selector(tappedUnwrappedButton), for: .touchUpInside)
        unwrappedDescriptionButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func toggleDescriptionVisability(hiddenNow: Bool, withAnimation: Bool) {
        if hiddenNow {
            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else { return }
                
                if withAnimation {
                    UIView.animate(withDuration: 0.5) {
                        self.descriptionView.alpha = 0
                    }
                } else {
                    self.descriptionView.alpha = 0
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else { return }
                
                if withAnimation {
                    UIView.animate(withDuration: 0.5) {
                        self.descriptionView.alpha = 1
                    }
                } else {
                    self.descriptionView.alpha = 1
                }
            }
        }
    }
    
    func updateDescription(broadcastName: String, id: Int) {
        descriptionView.nameVideoLabel.text = NSLocalizedString("Name", comment: "") + ": " + broadcastName
        descriptionView.idVideolLabel.text = "ID: " + String(id)
    }
    
    @objc private func tappedUnwrappedButton() {
        delegate?.tappedUnwrappedDescription(self)
    }
    
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            preview.leftAnchor.constraint(equalTo: leftAnchor),
            preview.topAnchor.constraint(equalTo: topAnchor),
            preview.rightAnchor.constraint(equalTo: rightAnchor),
            preview.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            indicatorView.leftAnchor.constraint(equalTo: leftAnchor),
            indicatorView.topAnchor.constraint(equalTo: topAnchor),
            indicatorView.rightAnchor.constraint(equalTo: rightAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            previewImageView.leftAnchor.constraint(equalTo: leftAnchor),
            previewImageView.topAnchor.constraint(equalTo: topAnchor),
            previewImageView.rightAnchor.constraint(equalTo: rightAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            descriptionView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 100) / 4),
            descriptionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            descriptionView.leftAnchor.constraint(equalTo: leftAnchor),
            descriptionView.rightAnchor.constraint(equalTo: rightAnchor),
            
            unwrappedDescriptionButton.heightAnchor.constraint(equalToConstant: 25),
            unwrappedDescriptionButton.widthAnchor.constraint(equalToConstant: 25),
            unwrappedDescriptionButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            unwrappedDescriptionButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            
            posterMissingLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            posterMissingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            posterMissingLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            posterMissingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        ])
    }
}


