//
//  PlayListDetailViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD

class PlayListDetailViewController: UITableViewController {
    
    var playList: PlayList?
    
    fileprivate var needUpdatePresentationList: NSMutableArray = NSMutableArray.init()
    fileprivate var currentUploadPresentationIndex = 0
    fileprivate var pinCodeJsonString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register all cells
        self.tableView.register(UINib(nibName: "PlayListDetailCell", bundle: nil), forCellReuseIdentifier: "PlayListDetailCell")
        
        // init navigation bar
        initNavigationBar()
        
        playList?.displayList = (playList?.displayList.sorted { $0.zOrder < $1.zOrder })!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
//        self.title = localizedString(key: "playlist_detail_title")
        
//        let saveButton = UIBarButtonItem(image: UIImage(named: "icon_save.png"),  style: .plain, target: self, action: #selector(saveButtonClicked(barButton:)))
        let sendButton = UIBarButtonItem(image: UIImage(named: "icon_send.png"),  style: .plain, target: self, action: #selector(sendButtonClicked(barButton:)))
//        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked(barButton:)))
//        navigationItem.rightBarButtonItems = [self.editButtonItem, sendButton, saveButton, addButton]
        navigationItem.rightBarButtonItems = [self.editButtonItem, sendButton]
    }

    fileprivate func updateZOderForDisplayList() {
        var count = 1
        for playListPresentation in (playList?.displayList)! {
            playListPresentation.zOrder = count
            count += 1
        }
    }
    
    fileprivate func isValidDurationData(duration: String) -> Bool {
        if duration == "" {
            return true
        }
        
        let letterCharacters = CharacterSet.letters
        let letterRange = duration.rangeOfCharacter(from: letterCharacters)
        
        if letterRange != nil {
            return false
        }
        return true
    }
    
    fileprivate func isValidDuration(seconds: Int) -> Bool {
        if seconds < kPlayListMinDuration {
            return false
        }
        return true
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension PlayListDetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (playList?.displayList.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListDetailCell") as? PlayListDetailCell
        
        if (playList?.displayList.count)! > 0 {
            cell?.initViewWithPlayListPresentation((playList?.displayList[indexPath.row])!)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Create the alert controller.
//        let alert = UIAlertController(title: "",
//                                      message: localizedString(key: "playlist_detail_update_duration_message"),
//                                      preferredStyle: .alert)
//        
//        // Add Days text field
//        alert.addTextField { (textField) in
//            textField.placeholder = localizedString(key: "playlist_detail_enter_days")
//            textField.keyboardType = UIKeyboardType.numberPad
//        }
//        
//        // Add Hours text field
//        alert.addTextField { (textField) in
//            textField.placeholder = localizedString(key: "playlist_detail_enter_hours")
//            textField.keyboardType = UIKeyboardType.numberPad
//        }
//        
//        // Add Minutes text field
//        alert.addTextField { (textField) in
//            textField.placeholder = localizedString(key: "playlist_detail_enter_minutes")
//            textField.keyboardType = UIKeyboardType.numberPad
//        }
//        
//        // Add Seconds text field
//        alert.addTextField { (textField) in
//            textField.placeholder = localizedString(key: "playlist_detail_enter_seconds")
//            textField.keyboardType = UIKeyboardType.numberPad
//        }
//        
//        // add cancel action
//        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel, handler: { (_) in
//            // just dismiss alert
//        }))
//        
//        // add OK action
//        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"), style: .default, handler: { [weak alert] (_) in
//            weak var weakSelf = self
//            
//            let daysTextField = alert?.textFields![0] // Force unwrapping because we know it exists.
//            let hoursTextField = alert?.textFields![1] // Force unwrapping because we know it exists.
//            let minutesTextField = alert?.textFields![2] // Force unwrapping because we know it exists.
//            let secondsTextField = alert?.textFields![3] // Force unwrapping because we know it exists.
//
//            var seconds = 0
//            if daysTextField?.text == "" && hoursTextField?.text == "" && minutesTextField?.text == "" && secondsTextField?.text == "" {
//                Utility.showAlertWithErrorMessage(message: localizedString(key: "playlist_detail_duration_invalid"), controller: weakSelf!)
//                return
//            }
//            
//            if daysTextField?.text != "" && (weakSelf?.isValidDurationData(duration: (daysTextField?.text)!))! {
//                let days = Int((daysTextField?.text)!)!
//                seconds += days*24*60*60
//            }
//            if hoursTextField?.text != "" && (weakSelf?.isValidDurationData(duration: (hoursTextField?.text)!))! {
//                let hours = Int((hoursTextField?.text)!)!
//                seconds += hours*60*60
//            }
//            if minutesTextField?.text != "" && (weakSelf?.isValidDurationData(duration: (minutesTextField?.text)!))! {
//                let minutes = Int((minutesTextField?.text)!)!
//                seconds += minutes*60
//            }
//            if secondsTextField?.text != "" && (weakSelf?.isValidDurationData(duration: (secondsTextField?.text)!))! {
//                let secs = Int((secondsTextField?.text)!)!
//                seconds += secs
//            }
//            
//            if !(weakSelf?.isValidDuration(seconds: seconds))! {
//                Utility.showAlertWithErrorMessage(message: localizedString(key: "playlist_detail_duration_invalid"), controller: weakSelf!)
//                return
//            }
//            
//            weakSelf?.playList?.displayList[indexPath.row].duration = seconds
//            weakSelf?.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
//        }))
//        
//        // Present the alert.
//        self.present(alert, animated: true, completion: nil)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            playList?.displayList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = playList?.displayList[fromIndexPath.row]
        playList?.displayList.remove(at: fromIndexPath.row)
        playList?.displayList.insert(itemToMove!, at: to.row)
        
        updateZOderForDisplayList()
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}

// MARK: - Handle Events

extension PlayListDetailViewController {
    
    func addButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.goToPresentationListScreen(controller: self)
    }
    
    func saveButtonClicked(barButton: UIBarButtonItem) {
        // get all presentations exist in local
        for playListPresentation in (self.playList?.displayList)! {
            if TemplateSlide.isExistPresentation(presentationId: playListPresentation.presentation) {
                self.needUpdatePresentationList.add(playListPresentation)
            }
        }
        
        // process upload all presentaion in local to cloud
        SVProgressHUD.show(withStatus: localizedString(key: "common_saving"))

        self.currentUploadPresentationIndex = 0
        self.processSaveNewPlayList { (success, message) in
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_saved"))
                weakSelf?.tableView.reloadData()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
    
    func sendButtonClicked(barButton: UIBarButtonItem) {
        ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .playList, controller: self)
        
//        // show actionsheet to choose video type
//        let actionSheetController = UIAlertController(title: localizedString(key: "common_send_alert_title"),
//                                                      message: localizedString(key: "common_send_alert_message"),
//                                                      preferredStyle: .actionSheet)
//
//        // Create and add the Cancel action
//        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
//            // Just dismiss the action sheet
//        }
//        actionSheetController.addAction(cancelAction)
//        
//        // Create and add send to cloud option action
//        let sendToCloudAction = UIAlertAction(title: localizedString(key: "common_send_to_cloud"), style: .default) {
//            [weak self] action -> Void in
//            
//            ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .playList, controller: self!)
//        }
//        actionSheetController.addAction(sendToCloudAction)
//        
//        // Create and add send to local option action
//        let sendToLocalAction = UIAlertAction(title: localizedString(key: "common_send_to_local"), style: .default) {
//            [weak self] action -> Void in
//            
//            ControllerManager.goToLocalDeviceListScreen(playList: (self?.playList!)!, controller: self!)
//        }
//        actionSheetController.addAction(sendToLocalAction)
//        
//        // Present the actionsheet
//        self.present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - PresentationListViewControllerDelegate

extension PlayListDetailViewController: PresentationListViewControllerDelegate {
    
    func handleAddPresentation(presentation: Presentation) {
        // create new PlayListPresentation
        let playListPresentation = PlayListPresentation()
        playListPresentation.zOrder = (self.playList?.displayList.count)! + 1
        playListPresentation.presentation = presentation.id
        playListPresentation.duration = kPlayListDurationDefault
        playListPresentation.name = presentation.name
        playListPresentation.code = presentation.code
        
        // add it to DisplayList & reload table
        playList?.displayList.append(playListPresentation)
        self.tableView.insertRows(at: [IndexPath.init(item: ((playList?.displayList.count)!-1), section: 0)],
                                  with: UITableViewRowAnimation.fade)
    }
}

// MARK: - Handle upload presentation

extension PlayListDetailViewController {
    
    func processSaveNewPlayList(completion: @escaping (Bool, String) -> Void) {
        // no need upload any presentation, just update new playlist
        if needUpdatePresentationList.count == 0 {
            // process upload playlist
            self.processUpdatePlayList(completion: { (success, message) in
                completion(success, message)
            })
            return
        }
        
        if currentUploadPresentationIndex < needUpdatePresentationList.count {
            // process upload presentation
            let playListPresentation = self.needUpdatePresentationList[self.currentUploadPresentationIndex] as! PlayListPresentation
            
            let uploadHelper = UploadPresentationHelper.init(presentationId: playListPresentation.presentation)
            uploadHelper.delegate = self
            uploadHelper.completionHandler = {
                (success, message) in
                
                weak var weakSelf = self
                
                if success {
                    // upload next presentation
                    weakSelf?.currentUploadPresentationIndex += 1
                    weakSelf?.processSaveNewPlayList(completion: completion)
                } else {
                    completion(false, message)
                }
            }
            uploadHelper.processUploadPresentation()
        } else {
            // process update playlist
            self.processUpdatePlayList(completion: { (success, message) in
                completion(success, message)
            })
        }
    }
    
    fileprivate func processUpdatePlayList(completion: @escaping (Bool, String) -> Void) {
        NetworkManager.shared.updatePlayList(id: (playList?.id)!, code: nil, totalTime: nil, name: nil, shortDescription: nil, displayList: playList?.displayList.toJsonString(), group: nil, token: Utility.getToken()) {
            (success, message) in
            
            completion(success, message)
        }
    }
}

// MARK: - Handle send PlayList to Cloud

extension PlayListDetailViewController {
    
    func processSendPlayListToCloud() {
//        // process save playList
//        // get all presentations exist in local
//        for playListPresentation in (self.playList?.displayList)! {
//            if TemplateSlide.isExistPresentation(presentationId: playListPresentation.presentation) {
//                self.needUpdatePresentationList.add(playListPresentation)
//            }
//        }
//        
//        // process upload all presentaion in local to cloud
//        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
//        
//        self.currentUploadPresentationIndex = 0
//        self.processSaveNewPlayList { (success, message) in
//            
//            weak var weakSelf = self
//            
//            if success {
//                // call API control to play with type = PLAYLIST
//                weakSelf?.processCallAPItoPlayPlayList()
//            } else {
//                SVProgressHUD.dismiss()
//                
//                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
//            }
//        }
        
        
        // call API control to play with type = PLAYLIST
        self.processCallAPItoPlayPlayList()
    }
    
    fileprivate func processCallAPItoPlayPlayList() {
        NetworkManager.shared.controlDeviceToPlay(pinCodeList: self.pinCodeJsonString, contentId: (playList?.id)!, contentType: ContentType.playlist.name(), contentName: (playList?.name)!, contentData: nil, token: Utility.getToken()) {
            (success, message) in
            
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            if success {
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_sent"))
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
    }
}

// MAKR: - UploadHelperDelegate

extension PlayListDetailViewController: UploadPresentationHelperDelegate {
    
    func handleAfterUpdatePresentationId(witOldPresentationId oldPresentationId: String, andNewPresentationId newPresentationId: String) {
        for playListPresentation in (playList?.displayList)! {
            if playListPresentation.presentation == oldPresentationId {
                playListPresentation.presentation = newPresentationId
                playListPresentation.code = newPresentationId
                
                // reload playlist with new thumbnail
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - CloudDeviceListViewControllerDelegate

extension PlayListDetailViewController: CloudDeviceListViewControllerDelegate {
    
    func handleSendPlayList(pinCodeJsonString: String) {
        self.pinCodeJsonString = pinCodeJsonString
        processSendPlayListToCloud()
    }
}
