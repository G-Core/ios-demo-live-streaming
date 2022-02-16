//
//  GCBroadcastCellCollectionViewCell.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 13.12.2021.
//

import UIKit

final class GCBroadcastSettingCell: UICollectionViewCell {
    let posterImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name: "
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "ID: "
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let connectionSignWithStream: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.image = .checkamrk15
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 15),
            view.heightAnchor.constraint(equalToConstant: 15),
        ])
        
        return view
    }()
    
    private let countConnectionStreamsLabel: UILabel = {
        let label = UILabel()
        label.text = "streams: "
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(connectionSignWithStream)
        contentView.addSubview(countConnectionStreamsLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.heightAnchor.constraint(equalToConstant: 100),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            posterImageView.rightAnchor.constraint(equalTo: nameLabel.leftAnchor, constant: -5),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            posterImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            
            nameLabel.heightAnchor.constraint(equalToConstant: nameLabel.intrinsicContentSize.height),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            nameLabel.rightAnchor.constraint(equalTo: connectionSignWithStream.leftAnchor, constant: -5),
            
            countConnectionStreamsLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            countConnectionStreamsLabel.heightAnchor.constraint(equalToConstant: countConnectionStreamsLabel.intrinsicContentSize.height),
            countConnectionStreamsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            countConnectionStreamsLabel.rightAnchor.constraint(equalTo: connectionSignWithStream.leftAnchor, constant: -5),
            
            idLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            idLabel.heightAnchor.constraint(equalToConstant: idLabel.intrinsicContentSize.height),
            idLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            idLabel.rightAnchor.constraint(equalTo: connectionSignWithStream.leftAnchor, constant: -5),
            
            connectionSignWithStream.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            connectionSignWithStream.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
        ])
    }
    
    func updateCell(name: String, streamsCount: Int, id: String, connection: Bool) {
        nameLabel.text = NSLocalizedString("Name", comment: "") + ": " + name
        idLabel.text = "ID: " + id
        countConnectionStreamsLabel.text = "streams: \(streamsCount)"
        connection ? (connectionSignWithStream.alpha = 1) : (connectionSignWithStream.alpha = 0)
    }
    
    func changeConnectionImage() {
        (connectionSignWithStream.alpha == 0) ? (connectionSignWithStream.alpha = 1) : (connectionSignWithStream.alpha = 0)
    }
}
