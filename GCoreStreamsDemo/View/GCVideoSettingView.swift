//
//  GCVideoSettingView.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 08.12.2021.
//

import UIKit

protocol GCVideoSettingViewDelegate: AnyObject {
    func settingDidChange(type: VideoSettings.VideoType, typeString: String)
}

final class GCVideoSettingView: UIView {
    var delegate: GCVideoSettingViewDelegate?
    
    private let tableView = UITableView()
    private let settings = ["360", "480", "HD 720"]
    private let cellID = "Cell"
    
    func setupView(selected setting: VideoSettings.VideoType) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = UIColor.brown.cgColor
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        switch setting {
        case .v360:
            tableView.selectRow(at: .init(row: 0, section: 0), animated: false, scrollPosition: .none)
        case .v480:
            tableView.selectRow(at: .init(row: 1, section: 0), animated: false, scrollPosition: .none)
        case .v720:
            tableView.selectRow(at: .init(row: 2, section: 0), animated: false, scrollPosition: .none)
        }
    }
}

extension GCVideoSettingView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.textLabel?.text = settings[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: delegate?.settingDidChange(type: .v360, typeString: settings[0])
        case 1: delegate?.settingDidChange(type: .v480, typeString: settings[1])
        case 2: delegate?.settingDidChange(type: .v720, typeString: settings[2])
        default: return
        }
    }
}
