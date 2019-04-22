//
//  ChooseAlignmentController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 10/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

protocol ChooseAlignmentControllerDelegate {
    func handleAlignmentChanged(alignmentTag: Int)
}

class ChooseAlignmentController: UIViewController {

    @IBOutlet weak var leftTopButton: UIButton!
    @IBOutlet weak var leftCenterButton: UIButton!
    @IBOutlet weak var leftBottomButton: UIButton!
    
    @IBOutlet weak var middleTopButton: UIButton!
    @IBOutlet weak var middleCenterButton: UIButton!
    @IBOutlet weak var middleBottomButton: UIButton!
    
    @IBOutlet weak var rightTopButton: UIButton!
    @IBOutlet weak var rightCenterButton: UIButton!
    @IBOutlet weak var rightBottomButton: UIButton!
    
    var currentSelectedButtonTag = 2
    
    var delegate: ChooseAlignmentControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        
        selectButtonWithCurrentTag()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "im_alignment_title")
        
        // init done icon
        let doneButton   = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func selectButtonWithCurrentTag() {
        switch currentSelectedButtonTag {
        case Alignment.topLeft.tag():
            leftTopButton.isSelected = true
        case Alignment.topCenter.tag():
            middleTopButton.isSelected = true
        case Alignment.topRight.tag():
            rightTopButton.isSelected = true
        case Alignment.middleLeft.tag():
            leftCenterButton.isSelected = true
        case Alignment.middleCenter.tag():
            middleCenterButton.isSelected = true
        case Alignment.middleRight.tag():
            rightCenterButton.isSelected = true
        case Alignment.bottomLeft.tag():
            leftBottomButton.isSelected = true
        case Alignment.bottomCenter.tag():
            middleBottomButton.isSelected = true
        case Alignment.bottomRight.tag():
            rightBottomButton.isSelected = true
        default:
            middleTopButton.isSelected = true
        }
    }

    fileprivate func unselectAllButton() {
        leftTopButton.isSelected = false
        leftCenterButton.isSelected = false
        leftBottomButton.isSelected = false
        
        middleTopButton.isSelected = false
        middleCenterButton.isSelected = false
        middleBottomButton.isSelected = false
        
        rightTopButton.isSelected = false
        rightCenterButton.isSelected = false
        rightBottomButton.isSelected = false
    }
}

// MARK: - Handle Events

extension ChooseAlignmentController {
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleAlignmentChanged(alignmentTag: currentSelectedButtonTag)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func alignButtonClicked(_ sender: UIButton) {
        unselectAllButton()
        
        sender.isSelected = true
        
        currentSelectedButtonTag = sender.tag
    }
}

