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
    private let settings = ["LQ", "SQ", "HQ", "SHQ", "HD 720"]
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
        case .lq:
            tableView.selectRow(at: .init(row: 0, section: 0), animated: false, scrollPosition: .none)
        case .sq:
            tableView.selectRow(at: .init(row: 1, section: 0), animated: false, scrollPosition: .none)
        case .hq:
            tableView.selectRow(at: .init(row: 2, section: 0), animated: false, scrollPosition: .none)
        case .shq:
            tableView.selectRow(at: .init(row: 3, section: 0), animated: false, scrollPosition: .none)
        case .hd720:
            tableView.selectRow(at: .init(row: 4, section: 0), animated: false, scrollPosition: .none)
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
        case 0: delegate?.settingDidChange(type: .lq, typeString: settings[0])
        case 1: delegate?.settingDidChange(type: .sq, typeString: settings[1])
        case 2: delegate?.settingDidChange(type: .hq, typeString: settings[2])
        case 3: delegate?.settingDidChange(type: .shq, typeString: settings[3])
        case 4: delegate?.settingDidChange(type: .hd720, typeString: settings[4])
        default: return
        }
    }
}
