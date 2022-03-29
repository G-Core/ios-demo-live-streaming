//
//  GCBroadcastSettingsController.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 12.12.2021.
//

import UIKit

final class GCBroadcastSettingsController: UIViewController {
    var streamIndex: Int!
    private var updatedBroadcastCount = 0
    private var originModelBroadcastsState = GCModel.shared.broadcasts
    private var screenIsLock = false
    private lazy var networkManager = NetworkManager(delegate: self)
    private lazy var originModelStreamState = model.streams[streamIndex].broadcastIDs
    
    private var didUpdatedBroadcastCount = 0 {
        didSet {
            if didUpdatedBroadcastCount == updatedBroadcastCount, updatedBroadcastCount != 0 {
                updateStateScreen()
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private let cellID = "Broadcast"
    private let model = GCModel.shared
    private let nsLock = NSLock()
    
    private let segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["All", "Stream"])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.black.cgColor
        view.backgroundColor = .white
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(tapSelectedControl), for: .valueChanged)
        
        return view
    }()
    
    private let createBroadcastButton: GCButton = {
        let button = GCButton()
        button.setTitle("New broadcast", for: .normal)
        button.addTarget(self, action: #selector(tapCreateBroadcastButton), for: .touchUpInside)
        
        return button
    }()
    
    private let saveButton: GCButton = {
        let button = GCButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(tapSaveButton), for: .touchUpInside)
        
        return button
    }()
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: UIScreen.main.bounds.width - 40, height: 110)
        layout.minimumInteritemSpacing = 5
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(GCBroadcastSettingCell.self, forCellWithReuseIdentifier: cellID)
        collection.contentInset = .init(top: 5, left: 0, bottom: 0, right: 0)
        view.addSubview(collection)
        
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(segmentedControl)
        view.addSubview(saveButton)
        view.addSubview(createBroadcastButton)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 5),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 5),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -5),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 90),
            saveButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -5),
            
            createBroadcastButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -90),
            createBroadcastButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        networkManager.token = model.accessToken
    }
    
    private func updateStateScreen() {
        switch screenIsLock {
        case true:
            view.isUserInteractionEnabled = false
            screenIsLock = false
        case false:
            view.isUserInteractionEnabled = true
            screenIsLock = true
        }
    }
    
    @objc private func tapSelectedControl() {
        collectionView.reloadData()
    }
    
    @objc private func tapCreateBroadcastButton() {
        let alertVC = UIAlertController(title: "Print the name", message: nil, preferredStyle: .alert)
        var textField: UITextField!
        
        alertVC.addTextField { field in
            field.placeholder = "Name..."
            textField = field
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertVC.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            guard let self = self, let name = textField.text, name != ""
            else { return }
            
            self.networkManager.newBroadcast(name: name,
                                             streamID: self.model.streams[self.streamIndex].id)
        }))
        
        present(alertVC, animated: true)
    }
    
    @objc private func tapSaveButton() {
        var updatedBroadcast: [ GCBroadcast ] = []
        
        for index in self.model.broadcasts.indices {
            if self.originModelBroadcastsState[index].streamIDs != self.model.broadcasts[index].streamIDs {
                updatedBroadcast += [self.model.broadcasts[index]]
            }
        }
        
        guard !updatedBroadcast.isEmpty else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let alertVC = UIAlertController(title: "Save changes?", message: nil, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            guard let self = self
            else { return }
            
            self.model.broadcasts = self.originModelBroadcastsState
            self.model.streams[self.streamIndex].broadcastIDs = self.originModelStreamState
            self.dismiss(animated: true, completion: nil)
        }))
        
        alertVC.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self
            else { return }
            
            self.updateStateScreen()
            self.updatedBroadcastCount = updatedBroadcast.count
            self.networkManager.updateBroadcasts(broadcasts: updatedBroadcast)
        }))
        
        present(alertVC, animated: true)
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension GCBroadcastSettingsController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        (segmentedControl.selectedSegmentIndex == 0) ? (model.broadcasts.count) : (model.streams[streamIndex].broadcastIDs.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GCBroadcastSettingCell
        let stream = model.streams[streamIndex]
        let broadcast: GCBroadcast
        
        if segmentedControl.selectedSegmentIndex == 0 {
            broadcast = model.broadcasts[indexPath.row]
        } else {
            let broadcastID = stream.broadcastIDs[indexPath.row]
            broadcast = model.broadcasts.first(where: { $0.id == broadcastID })!
        }
        
        let connectionToStream = model.hasBroadcastConnectionToStream(broadcastID: broadcast.id, streamID: stream.id)
        cell.updateCell(name: broadcast.name,
                        streamsCount: broadcast.streamIDs.count,
                        id: String(broadcast.id),
                        connection: connectionToStream)
        
        if let imageData = broadcast.posterImageData {
            cell.posterImageView.image = UIImage(data: imageData)
        } else {
            cell.posterImageView.image = nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let broadcastIndex: Int
        let stream = model.streams[streamIndex]
        
        if segmentedControl.selectedSegmentIndex == 0 {
            broadcastIndex = indexPath.row
        } else {
            let broadcastID = stream.broadcastIDs[indexPath.row]
            broadcastIndex = model.broadcasts.firstIndex(where: { $0.id == broadcastID })!
        }
        let broadcast = model.broadcasts[broadcastIndex]
        
        let isConnection = model.hasBroadcastConnectionToStream(broadcastID: broadcast.id, streamID: stream.id)
        
        switch isConnection {
        case true:
            model.broadcasts[broadcastIndex].streamIDs.removeAll(where: { $0 == stream.id })
            model.streams[streamIndex].broadcastIDs.removeAll(where: { $0 == broadcast.id })
        case false:
            model.broadcasts[broadcastIndex].streamIDs += [stream.id]
            model.streams[streamIndex].broadcastIDs += [broadcast.id]
        }
        
        collectionView.reloadData()
    }
}

//MARK: - NetworkManagerDelegate
extension GCBroadcastSettingsController: NetworkManagerDelegate {
    func broadcastDidCreate(broadcast: GCBroadcast) {
        model.broadcasts += [broadcast]
        originModelBroadcastsState += [broadcast]
        collectionView.reloadData()
    }
    
    func didUpdateBroadcast(_ broadcast: GCBroadcast) {
        nsLock.lock()
        didUpdatedBroadcastCount += 1
        nsLock.unlock()
    }
}

