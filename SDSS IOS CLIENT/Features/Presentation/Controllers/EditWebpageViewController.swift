//
//  EditWebpageViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 02/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol EditWebpageViewControllerDelegate {
    func handleUpdateWebpageCompleted(newWebpageUrl: String, region: Region)
}

class EditWebpageViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    // input value
    var region: Region?
    
    var delegate: EditWebpageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()

        initNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "presentation_editor_update_webpage_title")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(handleDoneButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func initView() {
        guard let webpage = Utility.getFirstWebpageFromRegion(region: region!) else {
            return
        }
        
        textField.text = webpage.sourcePath
    }

}

// MARK: - Handle Events

extension EditWebpageViewController {
    
    func handleDoneButtonClicked(barButton: UIBarButtonItem) {
        if textField.text == "" {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_webpage_empty"), controller: self)
            return
        }
        
        delegate?.handleUpdateWebpageCompleted(newWebpageUrl: textField.text!, region: region!)
        
        self.navigationController?.popViewController(animated: true)
    }
}
