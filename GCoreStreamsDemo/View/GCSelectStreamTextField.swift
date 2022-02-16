//
//  GCSelectStreamTextField.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 21.11.2021.
//

import UIKit

protocol GCSelectStreamViewDelegate: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func tapDeleteButton()
}

final class GCSelectStreamView: UITextField {
    let pickerView = UIPickerView()
    
    private let pickerToolBar: UIToolbar = {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(tapDonePickersButton))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(tapDeletePickersButton))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }()
    
    init(delegate: GCSelectStreamViewDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        pickerView.delegate = delegate
        pickerView.dataSource = delegate
        setupSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSelf() {
        inputView = pickerView
        inputAccessoryView = pickerToolBar
        autocorrectionType = .no
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 10
        leftView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 1))
        leftViewMode = .always
        textAlignment = .center
    }
    
    @objc private func tapDeletePickersButton() {
        guard let delegate = delegate as? GCSelectStreamViewDelegate else { return }
        delegate.tapDeleteButton()
    }
    
    @objc private func tapDonePickersButton() {
        self.resignFirstResponder()
    }
}
