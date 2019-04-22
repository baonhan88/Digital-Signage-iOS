//
//  EditTextViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 07/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

enum EditTextSection: Int {
    case message = 0
    case font = 1
    case effect = 2
}

enum EditTextMessageRow: Int {
    case newText = 0
}

enum EditTextFontRow: Int {
    case name = 0
    case color = 1
    case size = 2
}

enum EditTextEffectRow: Int {
    case bold = 0
    case italic = 1
    case underline = 2
    case strikethrough = 3
}

protocol EditTextViewControllerDelegate {
    func handleUpdateText(newText: Text, region: Region)
}

class EditTextViewController: BaseTableViewController {
    
    var delegate: EditTextViewControllerDelegate?
    
    // input value
    var region: Region?
    var text: Text?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        // register all cells
        self.tableView.register(UINib(nibName: "EditTextMessageCell", bundle: nil), forCellReuseIdentifier: "EditTextMessageCell")
        self.tableView.register(UINib(nibName: "EditTextNameCell", bundle: nil), forCellReuseIdentifier: "EditTextNameCell")
        self.tableView.register(UINib(nibName: "SelectColorCell", bundle: nil), forCellReuseIdentifier: "SelectColorCell")
        self.tableView.register(UINib(nibName: "EditTextSizeCell", bundle: nil), forCellReuseIdentifier: "EditTextSizeCell")
        self.tableView.register(UINib(nibName: "EditTextOnOffCell", bundle: nil), forCellReuseIdentifier: "EditTextOnOffCell")
        self.tableView.register(UINib(nibName: "EditTextAlignmentCell", bundle: nil), forCellReuseIdentifier: "EditTextAlignmentCell")
        
        // init view
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initView() {
        guard let tmpText = Utility.getFirstTextFromRegion(region: region!) else {
            return
        }
        
        text = tmpText
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "presentation_editor_update_text_title")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(handleDoneButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func isValidData() -> Bool {
        if self.text?.text != "" {
            return true
        }
        return false
    }
    
    fileprivate func getCurrentFontIndex() -> Int {
        var index = 0
        for tmpFontName in kFontNameList {
            if tmpFontName == text?.fontName {
                return index
            }
            index += 1
        }
        return 0
    }
    
    fileprivate func isBold() -> Bool {
        if text?.fontStyle == "" || text?.fontStyle == FontStyle.regular.name() {
            return false
        }
        
        guard let parts = text?.fontStyle.components(separatedBy: " ") else {
            return false
        }
        
        for part in parts {
            if part == FontStyle.bold.name() {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func isItalic() -> Bool {
        if text?.fontStyle == "" || text?.fontStyle == FontStyle.regular.name() {
            return false
        }
        
        guard let parts = text?.fontStyle.components(separatedBy: " ") else {
            return false
        }
        
        for part in parts {
            if part == FontStyle.italic.name() {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func isUnderline() -> Bool {
        if text?.fontStyle == "" || text?.fontStyle == FontStyle.regular.name() {
            return false
        }
        
        guard let parts = text?.fontStyle.components(separatedBy: " ") else {
            return false
        }
        
        for part in parts {
            if part == FontStyle.underline.name() {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func isStrikethrough() -> Bool {
        if text?.fontStyle == "" || text?.fontStyle == FontStyle.regular.name() {
            return false
        }
        
        guard let parts = text?.fontStyle.components(separatedBy: " ") else {
            return false
        }
        
        for part in parts {
            if part == FontStyle.strikethrough.name() {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Handle Events 

extension EditTextViewController {
    
    func handleDoneButtonClicked(barButton: UIBarButtonItem) {
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_update_text_empty"), controller: self)
            return
        }
        
        delegate?.handleUpdateText(newText: text!, region: region!)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension EditTextViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return EditTextSection.effect.rawValue + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case EditTextSection.message.rawValue:
            return EditTextMessageRow.newText.rawValue + 1
        case EditTextSection.font.rawValue:
            return EditTextFontRow.size.rawValue + 1
        case EditTextSection.effect.rawValue:
            return EditTextEffectRow.strikethrough.rawValue + 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            
        // Message section
        case EditTextSection.message.rawValue:
            if indexPath.row == EditTextMessageRow.newText.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextMessageCell") as? EditTextMessageCell
                
                cell?.enterIMTextField.text = text?.text
                cell?.delegate = self
                
                return cell!
            }
            
        // Font section
        case EditTextSection.font.rawValue:
            if indexPath.row == EditTextFontRow.name.rawValue { // Font Name
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextNameCell") as? EditTextNameCell
                
                cell?.leftLabel.text = localizedString(key: "im_cell_name")
                
                if text?.fontName == "" {
                    cell?.rightLabel.text = kFontNameList[kFontDefaultIndex]
                } else {
                    cell?.rightLabel.text = kFontNameList[getCurrentFontIndex()]
                }
                
                return cell!
            } else if indexPath.row == EditTextFontRow.color.rawValue { // Color
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell") as? SelectColorCell
                
                cell?.initViewWithColor(hexString: (text?.fontColor)!)
                
                return cell!
            } else { // Size
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextSizeCell") as? EditTextSizeCell
                
                cell?.delegate = self
                cell?.initView(fontSize: Float((text?.fontSize)!))
                
                return cell!
            }
            
        // Effect section
        case EditTextSection.effect.rawValue:
            if indexPath.row == EditTextEffectRow.bold.rawValue { // Bold
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextOnOffCell") as? EditTextOnOffCell
                
                cell?.leftLabel.text = localizedString(key: "presentation_editor_update_text_cell_bold")
                cell?.currentOnOffType = FontStyle.bold
                cell?.onOffSwitch.isOn = isBold()
                cell?.delegate = self
                
                return cell!
            } else if indexPath.row == EditTextEffectRow.italic.rawValue { // Italic
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextOnOffCell") as? EditTextOnOffCell
                
                cell?.leftLabel.text = localizedString(key: "presentation_editor_update_text_cell_italic")
                cell?.currentOnOffType = FontStyle.italic
                cell?.onOffSwitch.isOn = isItalic()
                cell?.delegate = self

                return cell!
            } else if indexPath.row == EditTextEffectRow.underline.rawValue { // Underline
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextOnOffCell") as? EditTextOnOffCell
                
                cell?.leftLabel.text = localizedString(key: "presentation_editor_update_text_cell_underline")
                cell?.currentOnOffType = FontStyle.underline
                cell?.onOffSwitch.isOn = isUnderline()
                cell?.delegate = self

                return cell!
            } else if indexPath.row == EditTextEffectRow.strikethrough.rawValue { // Strikethrough
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextOnOffCell") as? EditTextOnOffCell
                
                cell?.leftLabel.text = localizedString(key: "presentation_editor_update_text_cell_strikethrough")
                cell?.currentOnOffType = FontStyle.strikethrough
                cell?.onOffSwitch.isOn = isStrikethrough()
                cell?.delegate = self

                return cell!
            }
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextMessageCell") as? EditTextMessageCell
            return cell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextMessageCell") as? EditTextMessageCell
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            
        case EditTextSection.message.rawValue:
            return localizedString(key: "presentation_editor_update_text_section_message")
            
        case EditTextSection.font.rawValue:
            return localizedString(key: "im_section_font")
            
        case EditTextSection.effect.rawValue:
            return localizedString(key: "im_section_effect")
            
        default:
            return localizedString(key: "im_section_message")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
            
        case EditTextSection.font.rawValue:
            if indexPath.row == EditTextFontRow.name.rawValue {
                ControllerManager.goToCommonSelectionScreen(selectionList: kFontNameList as NSArray,
                                                            currentSelection: getCurrentFontIndex(),
                                                            currentType: SelectionType.fontName,
                                                            title: localizedString(key: "im_title_font_name"),
                                                            controller: self)
            } else if indexPath.row == EditTextFontRow.color.rawValue {
                ControllerManager.goToColorPickerScreen(currentColor: UIColor.init(hexString: (text?.fontColor)!)!, type: .none, controller: self)
            }
            
        default:
            dLog(message: "do something")
        }
    }
}

// MARK: - CommonSelectionViewControllerDelegate

extension EditTextViewController: CommonSelectionViewControllerDelegate {
    
    func handleDoneButton(currentSelectionIndex: Int, selectionType: SelectionType) {
        switch selectionType {
        case .fontName:
            text?.fontName = kFontNameList[currentSelectionIndex]
        default:
            return
        }
        
        tableView.reloadData()
    }
}

// MARK: - CommonColorPickerViewControllerDelegate

extension EditTextViewController: CommonColorPickerViewControllerDelegate {
    
    func handleChangeColor(color: UIColor, type: SelectColorType) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? SelectColorCell
        cell?.colorView.backgroundColor = color
        text?.fontColor = color.toHexString()
    }
}

// MARK: - EditTextSizeCellDelegate

extension EditTextViewController: EditTextSizeCellDelegate {
    
    func fontSizeChanged(size: Int) {
        text?.fontSize = CGFloat(size)
    }
}

// MARK: - EditTextOnOffCellDelegate

extension EditTextViewController: EditTextOnOffCellDelegate {
    
    func handleOnOffChanged(currentOnOffType: FontStyle, isOn: Bool) {
        var newFontStyle = text?.fontStyle
        
        var isEmpty = false
        if text?.fontStyle.lowercased() == FontStyle.regular.name() || text?.fontStyle == "" {
            isEmpty = true
        }
        
        if isOn {
            // add font style
            if isEmpty {
                newFontStyle = currentOnOffType.name()
            } else {
                newFontStyle = newFontStyle! + " " + currentOnOffType.name()
            }

        } else {
            if isEmpty {
                return
            }
            
            // remove that font style on old string
            newFontStyle = newFontStyle?.replacingOccurrences(of: currentOnOffType.name() + " ", with: "")
            newFontStyle = newFontStyle?.replacingOccurrences(of: " " + currentOnOffType.name(), with: "")
            newFontStyle = newFontStyle?.replacingOccurrences(of: currentOnOffType.name(), with: "")
        }
        
        if newFontStyle == "" {
            newFontStyle = FontStyle.regular.name()
        }
        
        dLog(message: "new font stype = \(String(describing: newFontStyle))")
        
        text?.fontStyle = newFontStyle!
    }
}

// MARK: - EditTextMessageCellDelegate

extension EditTextViewController: EditTextMessageCellDelegate {
    
    func handleUpdateText(newText: String) {
        text?.text = newText
    }
}

