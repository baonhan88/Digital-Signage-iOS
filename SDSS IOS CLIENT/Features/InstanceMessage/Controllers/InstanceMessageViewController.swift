//
//  InstanceMessageViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 04/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

fileprivate enum IMSection: Int {
    case common = 0
    case message = 1
    case font = 2
    case effect = 3
    case display = 4
}

fileprivate enum CommonRow: Int {
    case eventName = 0
    case infoLevel = 1
}

fileprivate enum MessageRow: Int {
    case instantMessage = 0
    case duration = 1
}

fileprivate enum FontRow: Int {
    case name = 0
    case color = 1
    case size = 2
}

fileprivate enum EffectRow: Int {
    case animation = 0
    case bold = 1
    case italic = 2
}

class InstanceMessageViewController: BaseTableViewController {
    
    fileprivate var pinCodeJsonString: String = ""
    
    var displayEvent: DisplayEvent = DisplayEvent()
    
    var isShowDatePicker = false
    
    fileprivate let dateFormatter = DateFormatter()
    
    var isEditMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // register all cells
        self.tableView.register(UINib(nibName: "IMMessageCell", bundle: nil), forCellReuseIdentifier: "IMMessageCell")
        self.tableView.register(UINib(nibName: "IMNameCell", bundle: nil), forCellReuseIdentifier: "IMNameCell")
        self.tableView.register(UINib(nibName: "SelectColorCell", bundle: nil), forCellReuseIdentifier: "SelectColorCell")
        self.tableView.register(UINib(nibName: "IMSizeCell", bundle: nil), forCellReuseIdentifier: "IMSizeCell")
        self.tableView.register(UINib(nibName: "IMOnOffCell", bundle: nil), forCellReuseIdentifier: "IMOnOffCell")
        self.tableView.register(UINib(nibName: "IMAlignmentCell", bundle: nil), forCellReuseIdentifier: "IMAlignmentCell")
        self.tableView.register(UINib(nibName: "IMDurationCell", bundle: nil), forCellReuseIdentifier: "IMDurationCell")
        self.tableView.register(UINib(nibName: "IMEventNameCell", bundle: nil), forCellReuseIdentifier: "IMEventNameCell")
        self.tableView.register(UINib(nibName: "IMInfoLevelCell", bundle: nil), forCellReuseIdentifier: "IMInfoLevelCell")
        self.tableView.register(UINib(nibName: "IMPlayTimeCell", bundle: nil), forCellReuseIdentifier: "IMPlayTimeCell")
        self.tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initController() {
        
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "im_title")
        
        let sendImage = UIImage(named: "icon_send")!
        let sendButton = UIBarButtonItem(image: sendImage,  style: .plain, target: self, action: #selector(sendButtonClicked(barItem:)))
        
        let saveImage = UIImage(named: "icon_save")!
        let saveButton = UIBarButtonItem(image: saveImage,  style: .plain, target: self, action: #selector(saveButtonClicked(barItem:)))
        
        navigationItem.rightBarButtonItems = [sendButton, saveButton]
    }
    
    fileprivate func getPositionNameByTag(tag: Int) -> String {
        switch tag {
        case Alignment.topLeft.tag():
            return Alignment.topLeft.positionName()
        case Alignment.topCenter.tag():
            return Alignment.topCenter.positionName()
        case Alignment.topRight.tag():
            return Alignment.topRight.positionName()
        case Alignment.middleLeft.tag():
            return Alignment.middleLeft.positionName()
        case Alignment.middleCenter.tag():
            return Alignment.middleCenter.positionName()
        case Alignment.middleRight.tag():
            return Alignment.middleRight.positionName()
        case Alignment.bottomLeft.tag():
            return Alignment.bottomLeft.positionName()
        case Alignment.bottomCenter.tag():
            return Alignment.bottomCenter.positionName()
        case Alignment.bottomRight.tag():
            return Alignment.bottomRight.positionName()
        default:
            return Alignment.topLeft.positionName()
        }
    }
    
    fileprivate func getTagByPositionName(positionName: String) -> Int {
        switch positionName {
        case Alignment.topLeft.positionName():
            return Alignment.topLeft.tag()
        case Alignment.topCenter.positionName():
            return Alignment.topCenter.tag()
        case Alignment.topRight.positionName():
            return Alignment.topRight.tag()
        case Alignment.middleLeft.positionName():
            return Alignment.middleLeft.tag()
        case Alignment.middleCenter.positionName():
            return Alignment.middleCenter.tag()
        case Alignment.middleRight.positionName():
            return Alignment.middleRight.tag()
        case Alignment.bottomLeft.positionName():
            return Alignment.bottomLeft.tag()
        case Alignment.bottomCenter.positionName():
            return Alignment.bottomCenter.tag()
        case Alignment.bottomRight.positionName():
            return Alignment.bottomRight.tag()
        default:
            return Alignment.topLeft.tag()
        }
    }
    
    fileprivate func getFontIndexByName(fontName: String) -> Int {
        var count = 0
        
        for name in kFontNameList {
            if name == fontName {
                return count
            }
            count += 1
        }
        
        return 0
    }
    
    fileprivate func isValidData() -> Bool {
        if displayEvent.name != "" && displayEvent.contentData.message != "" {
            return true
        }
        
        return false
    }
    
    fileprivate func processSendInstantMessageToCloud() {
        // generate instant message object to json
        let contentDataJson = displayEvent.contentData.toJsonString()
        dLog(message: "generated content data json object = " + contentDataJson)
        
        // show loading
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        
        NetworkManager.shared.playEventInstantMessage(token: Utility.getToken(),
                                                      name: displayEvent.name,
                                                      data: contentDataJson,
                                                      eventType: "INSTANT_MESSAGE",
                                                      playTime: displayEvent.playTime,
                                                      duration: displayEvent.contentData.duration, // duration by minutes
                                                      pinCodeList: self.pinCodeJsonString) {
            (success, message) in
            
            // remove loading
            SVProgressHUD.dismiss()
            
            weak var weakSelf = self
            
            if (success) {
                Utility.showAlertWithSuccessMessage(message: localizedString(key: "im_success_send_cloud_message"), controller: weakSelf!, completion: {
                    
                    if (weakSelf?.isEditMode)! {
                        weakSelf?.processSaveDisplayEvent()
                    } else {
                        weakSelf?.processAddDisplayEvent()
                    }
                })
                
            } else {
                // show error message
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!, completion: nil)
            }
        }
    }
    
    fileprivate func processSaveDisplayEvent() {
        // generate instant message object to json
        let contentDataJson = displayEvent.contentData.toJsonString()
        dLog(message: "generated content data json object = " + contentDataJson)
        
        // show loading
        SVProgressHUD.show(withStatus: localizedString(key: "common_saving"))
        
        NetworkManager.shared.editDisplayEvent(id: displayEvent.id,
                                               name: displayEvent.name,
                                               duration: displayEvent.duration,
                                               eventType: "INSTANT_MESSAGE",
                                               playTime: displayEvent.playTime,
                                               data: contentDataJson,
                                               token: Utility.getToken()) { (success, message) in
            
                                                // remove loading
                                                SVProgressHUD.dismiss()
                                                
                                                weak var weakSelf = self
                                                
                                                if (success) {
                                                    Utility.showAlertWithSuccessMessage(message: localizedString(key: "common_saved"), controller: weakSelf!, completion: nil)
                                                    
                                                } else {
                                                    // show error message
                                                    Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!, completion: nil)
                                                }
        }
    }
    
    fileprivate func processAddDisplayEvent() {
        let contentDataJson = displayEvent.contentData.toJsonString()

        SVProgressHUD.show()
        
        NetworkManager.shared.addDisplayEvent(name: displayEvent.name,
                                              duration: displayEvent.duration,
                                              eventType: "INSTANT_MESSAGE",
                                              playTime: displayEvent.playTime,
                                              data: contentDataJson,
                                              token: Utility.getToken()) { (success, id, message) in
            
//            weak var weakSelf = self
            
            // remove loading
            SVProgressHUD.dismiss()
            
            if (success) {
                
                
            } else {
                // show error message
                Utility.showAlertWithErrorMessage(message: message, controller: self, completion: nil)
            }
        }
    }
}

// MARK: - Handle events

extension InstanceMessageViewController {
    
    func sendButtonClicked(barItem: UIBarButtonItem) {
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "im_error_empty_content"), controller: self, completion: nil)
            return
        }
        
        ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .instantMessage, controller: self)
    }
    
    func saveButtonClicked(barItem: UIBarButtonItem) {
        if !isValidData() {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "im_error_empty_content"), controller: self, completion: nil)
            return
        }
        
        if isEditMode {
            processSaveDisplayEvent()
        } else {
            processAddDisplayEvent()
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension InstanceMessageViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return IMSection.display.rawValue + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case IMSection.common.rawValue:
            return CommonRow.infoLevel.rawValue + 1
        case IMSection.message.rawValue:
            return MessageRow.duration.rawValue + 1
        case IMSection.font.rawValue:
            return FontRow.size.rawValue + 1
        case IMSection.effect.rawValue:
            return EffectRow.italic.rawValue + 1
        case IMSection.display.rawValue:
            var count = 3
            if !displayEvent.contentData.isFullscreen {
                count += 1
            }
            if displayEvent.contentData.isSchedule {
                count += 2
                
                if isShowDatePicker == true {
                    count += 1
                }
            }
            
            return count
        
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == IMSection.message.rawValue && indexPath.row == 0 {
            return 124
        }
        
        if indexPath.section == IMSection.display.rawValue {
            if displayEvent.contentData.isSchedule  {
                if displayEvent.contentData.isFullscreen {
                    if indexPath.row == 5 {
                        return 216
                    }
                } else {
                    if indexPath.row == 6 {
                        return 216
                    }
                }
            }
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            
        // Common section
        case IMSection.common.rawValue:
            if indexPath.row == CommonRow.eventName.rawValue { // event name
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMEventNameCell") as? IMEventNameCell
                
                cell?.initView(name: displayEvent.name)
                cell?.delegate = self
                
                return cell!
            } else { // info level
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMInfoLevelCell") as? IMInfoLevelCell
                
                cell?.initView(infoLevelString: displayEvent.infoLevel)
                cell?.delegate = self
                
                return cell!
            }
        
        // Message section
        case IMSection.message.rawValue:
            if indexPath.row == MessageRow.instantMessage.rawValue { // message
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMMessageCell") as? IMMessageCell
                
                cell?.initView(displayEvent: displayEvent)
                cell?.delegate = self
                
                return cell!
            } else { // Duration
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMDurationCell") as? IMDurationCell
                
                cell?.initView(duration: displayEvent.contentData.duration)
                cell?.delegate = self
                
                return cell!
            }
            
        // Font section
        case IMSection.font.rawValue:
            if indexPath.row == FontRow.name.rawValue { // Font Name
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMNameCell") as? IMNameCell
                
                cell?.leftLabel.text = localizedString(key: "im_cell_name")
                
                // default Font = Garamond
                cell?.rightLabel.text = displayEvent.contentData.fontName
                
                return cell!
            } else if indexPath.row == FontRow.color.rawValue { // Color
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell") as? SelectColorCell
                
                // default color = Blue
                cell?.initViewWithColor(color: UIColor.init(hexString: displayEvent.contentData.fontColor)!)
                
                return cell!
            } else { // Size
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMSizeCell") as? IMSizeCell
                
                cell?.delegate = self
                
                return cell!
            }
            
        // Effect section
        case IMSection.effect.rawValue:
            if indexPath.row == EffectRow.animation.rawValue { // Animation
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMNameCell") as? IMNameCell
                
                cell?.leftLabel.text = localizedString(key: "im_cell_animation")
                
                // default Animation = Blinking
                cell?.rightLabel.text = "Blinking"
                
                return cell!
            } else if indexPath.row == EffectRow.bold.rawValue { // Bold
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMOnOffCell") as? IMOnOffCell
                
                cell?.leftLabel.text = localizedString(key: "im_cell_bold")
                cell?.onOffSwitch.isOn = displayEvent.contentData.isBold
                cell?.currentOnOffType = OnOffType.bold
                cell?.delegate = self
                
                return cell!
            } else { // Italic
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMOnOffCell") as? IMOnOffCell
                
                cell?.leftLabel.text = localizedString(key: "im_cell_italic")
                cell?.onOffSwitch.isOn = displayEvent.contentData.isItalic
                cell?.currentOnOffType = OnOffType.italic
                cell?.delegate = self
                
                return cell!
            }
            
        // Display section
        case IMSection.display.rawValue:
            if indexPath.row == 0 { // background
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell") as? SelectColorCell
                
                cell?.initViewWithColor(color: UIColor.init(hexString: displayEvent.contentData.bgColor)!)
                
                return cell!
                
            } else if indexPath.row == 1 { // full screen
                let cell = tableView.dequeueReusableCell(withIdentifier: "IMOnOffCell") as? IMOnOffCell
                
                cell?.leftLabel.text = localizedString(key: "im_cell_full_screen")
                cell?.onOffSwitch.isOn = displayEvent.contentData.isFullscreen
                cell?.currentOnOffType = OnOffType.fullScreen
                cell?.delegate = self
                
                return cell!
                
            }
            
            if displayEvent.contentData.isFullscreen {
                if indexPath.row == 2 { // schedule
                    let cell = tableView.dequeueReusableCell(withIdentifier: "IMOnOffCell") as? IMOnOffCell
                    
                    cell?.leftLabel.text = localizedString(key: "im_cell_schedule")
                    cell?.onOffSwitch.isOn = displayEvent.contentData.isSchedule
                    cell?.currentOnOffType = OnOffType.schedule
                    cell?.delegate = self
                    
                    return cell!
                }
            } else {
                if indexPath.row == 2 { // aligment
                    let cell = tableView.dequeueReusableCell(withIdentifier: "IMAlignmentCell") as? IMAlignmentCell
                    
                    cell?.initView(tag: getTagByPositionName(positionName: displayEvent.contentData.position))
                    
                    return cell!
                } else if indexPath.row == 3 { // schedule
                    let cell = tableView.dequeueReusableCell(withIdentifier: "IMOnOffCell") as? IMOnOffCell
                    
                    cell?.leftLabel.text = localizedString(key: "im_cell_schedule")
                    cell?.onOffSwitch.isOn = displayEvent.contentData.isSchedule
                    cell?.currentOnOffType = OnOffType.schedule
                    cell?.delegate = self
                    
                    return cell!
                }
            }
            
            if displayEvent.contentData.isSchedule {
                if displayEvent.contentData.isFullscreen {
                    if indexPath.row == 3 { // loop
                        let cell = tableView.dequeueReusableCell(withIdentifier: "IMOnOffCell") as? IMOnOffCell
                        
                        cell?.leftLabel.text = localizedString(key: "im_cell_loop")
                        cell?.onOffSwitch.isOn = displayEvent.contentData.isLoopSchedule
                        cell?.currentOnOffType = OnOffType.loop
                        cell?.delegate = self
                        
                        return cell!
                    } else if indexPath.row == 4 { // play time
                        let cell = tableView.dequeueReusableCell(withIdentifier: "IMPlayTimeCell") as? IMPlayTimeCell
                        
                        cell?.initView(playTime: displayEvent.playTime)
                        
                        return cell!
                    }
                } else {
                    if indexPath.row == 4 { // loop
                        let cell = tableView.dequeueReusableCell(withIdentifier: "IMOnOffCell") as? IMOnOffCell
                        
                        cell?.leftLabel.text = localizedString(key: "im_cell_loop")
                        cell?.onOffSwitch.isOn = displayEvent.contentData.isLoopSchedule
                        cell?.currentOnOffType = OnOffType.loop
                        cell?.delegate = self
                        
                        return cell!
                    } else if indexPath.row == 5 { // play time
                        let cell = tableView.dequeueReusableCell(withIdentifier: "IMPlayTimeCell") as? IMPlayTimeCell
                        
                        cell?.initView(playTime: displayEvent.playTime)
                        
                        return cell!
                    }
                }
                
            }
            
            if isShowDatePicker {
                if displayEvent.contentData.isSchedule {
                    if displayEvent.contentData.isFullscreen {
                        if indexPath.row == 5 {
                            // show date picker cell
                            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as? DatePickerCell
                            cell?.initViewWithDate(self.dateFormatter.date(from: self.displayEvent.playTime)!)
                            cell?.delegate = self
                            return cell!
                        }
                    } else {
                        if indexPath.row == 6 {
                            // show date picker cell
                            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell") as? DatePickerCell
                            cell?.initViewWithDate(self.dateFormatter.date(from: self.displayEvent.playTime)!)
                            cell?.delegate = self
                            return cell!
                        }
                    }
                }
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "IMMessageCell") as? IMMessageCell
            
            return cell!
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IMMessageCell") as? IMMessageCell
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            
        case IMSection.common.rawValue:
            return localizedString(key: "im_section_common")
            
        case IMSection.message.rawValue:
            return localizedString(key: "im_section_message")
            
        case IMSection.font.rawValue:
            return localizedString(key: "im_section_font")
            
        case IMSection.effect.rawValue:
            return localizedString(key: "im_section_effect")
            
        case IMSection.display.rawValue:
            return localizedString(key: "im_section_display")
            
        default:
            return localizedString(key: "im_section_message")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
            
        case IMSection.font.rawValue:
            if indexPath.row == FontRow.name.rawValue {
                ControllerManager.goToCommonSelectionScreen(selectionList: kFontNameList as NSArray,
                                                            currentSelection: getFontIndexByName(fontName: displayEvent.contentData.fontName),
                                                            currentType: SelectionType.fontName,
                                                            title: localizedString(key: "im_title_font_name"),
                                                            controller: self)
            } else if indexPath.row == FontRow.color.rawValue {
                ControllerManager.goToColorPickerScreen(currentColor: UIColor.init(hexString: displayEvent.contentData.fontColor)!,
                                                        type: .fontColor,
                                                        controller: self)
            }
            
        case IMSection.display.rawValue:
            if indexPath.row == 0 {
                ControllerManager.goToColorPickerScreen(currentColor: UIColor.init(hexString: displayEvent.contentData.bgColor)!,
                                                        type: .bgColor,
                                                        controller: self)
            } else if (indexPath.row == 2) {
                ControllerManager.goToChooseAlignmentScreen(currentSelectedButtonTag: getTagByPositionName(positionName: displayEvent.contentData.position),
                                                        controller: self)
            } else {
                if displayEvent.contentData.isSchedule {
                    if displayEvent.contentData.isFullscreen {
                        if indexPath.row == 4 {
                            // show/hide date picker cell
                            isShowDatePicker = !isShowDatePicker
                            tableView.reloadData()
                        }
                    } else {
                        if indexPath.row == 5 {
                            // show/hide date picker cell
                            isShowDatePicker = !isShowDatePicker
                            tableView.reloadData()
                        }
                    }
                }
            }
            
        default:
            dLog(message: "do something")
        }
    }
}

// MARK: - CommonSelectionViewControllerDelegate

extension InstanceMessageViewController: CommonSelectionViewControllerDelegate {
    
    func handleDoneButton(currentSelectionIndex: Int, selectionType: SelectionType) {
        
        switch selectionType {
            
        case .fontName:
            displayEvent.contentData.fontName =  kFontNameList[currentSelectionIndex]
            
        default:
            break
        }
        
        tableView.reloadData()
    }
}

// MARK: - CommonColorPickerViewControllerDelegate

extension InstanceMessageViewController: CommonColorPickerViewControllerDelegate {
    
    func handleChangeColor(color: UIColor, type: SelectColorType) {
        switch type {
        case SelectColorType.fontColor:
            displayEvent.contentData.fontColor = color.toHexString()
            break
        case SelectColorType.bgColor:
            displayEvent.contentData.bgColor = color.toHexString()
        default:
            dLog(message: "do nothing")
        }
        
        tableView.reloadData()
    }
}

// MARK: - IMOnOffCellDelegate

extension InstanceMessageViewController: IMOnOffCellDelegate {
    
    func switcherChanged(isOn: Bool, onOffType: OnOffType) {
        
        switch onOffType {
            
        case OnOffType.bold:
            displayEvent.contentData.isBold = isOn
            break
            
        case OnOffType.italic:
            displayEvent.contentData.isItalic = isOn
            break
        
        case OnOffType.fullScreen:
            displayEvent.contentData.isFullscreen = isOn
            tableView.reloadData()
            break
            
        case OnOffType.schedule:
            displayEvent.contentData.isSchedule = isOn
            tableView.reloadData()
            break
        
        case OnOffType.loop:
            displayEvent.contentData.isLoopSchedule = isOn
            break
            
        }
    }
}

// MARK: - IMSizeCellDelegate

extension InstanceMessageViewController: IMSizeCellDelegate {
    
    func fontSizeChanged(size: Int) {
        displayEvent.contentData.fontSize = size
    }
}

// MARK: - ChooseAlignmentControllerDelegate

extension InstanceMessageViewController: ChooseAlignmentControllerDelegate {
    
    func handleAlignmentChanged(alignmentTag: Int) {
        displayEvent.contentData.position = getPositionNameByTag(tag: alignmentTag)
        
        tableView.reloadData()
    }
}

// MARK: - CloudDeviceListViewControllerDelegate

extension InstanceMessageViewController: CloudDeviceListViewControllerDelegate {
    
    func handleSendInstantMessage(pinCodeJsonString: String) {
        self.pinCodeJsonString = pinCodeJsonString
        processSendInstantMessageToCloud()
    }
}

// MARK: - IMDurationCellDelegate

extension InstanceMessageViewController: IMDurationCellDelegate {
    
    func handleDurationChanged(duration: Int) {
        displayEvent.contentData.duration = duration
        dLog(message: "duration = \(duration)")
    }
}

// MARK: - IMMessageCellDelegate

extension InstanceMessageViewController: IMMessageCellDelegate {
    
    func handleTTSSwitchChanged(isOn: Bool) {
        displayEvent.contentData.isTTS = isOn
        
        tableView.reloadData()
    }
    
    func handleTTSRepeatSwitchChanged(isOn: Bool) {
        displayEvent.contentData.TTSRepeat = isOn
        
        tableView.reloadData()
    }
    
    func handleMessageChanged(message: String) {
        displayEvent.contentData.message = message
    }
    
    func handleTTSMessageChanged(ttsMessage: String) {
        displayEvent.contentData.ttsMsg = ttsMessage
    }
}

// MARK: - IMEventNameCellDelegate

extension InstanceMessageViewController: IMEventNameCellDelegate {
    
    func handleNameTextFieldChanged(name: String) {
        displayEvent.name = name
    }
}

// MARK: - IMInfoLevelCellDelegate

extension InstanceMessageViewController: IMInfoLevelCellDelegate {
    
    func handleInfoLevelChanged(infoLevel: String) {
        displayEvent.infoLevel = infoLevel
    }
}

// MARK: - DatePickerCellDelegate

extension InstanceMessageViewController: DatePickerCellDelegate {
    
    func handleDatePickerValueChanged(date: Date) {
        self.displayEvent.playTime = self.dateFormatter.string(from: date)
        
        tableView.reloadData()
    }
}
