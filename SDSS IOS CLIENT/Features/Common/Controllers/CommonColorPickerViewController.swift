//
//  CommonColorPickerViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 08/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

enum SelectColorType {
    case none
    case strokeColor
    case fillColor
    case fontColor
    case bgColor
}

protocol CommonColorPickerViewControllerDelegate {
    func handleChangeColor(color: UIColor, type: SelectColorType)
}

class CommonColorPickerViewController: UIViewController {

    @IBOutlet weak var colorPicker: ColorPicker!
    @IBOutlet weak var colorView: UIView!
    
    var currentColor: UIColor = UIColor.blue
    var currentSelectColorType: SelectColorType = .none
    
    var delegate: CommonColorPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        colorPicker.delegate = self;
        
        colorView.backgroundColor = currentColor
        
        initNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "common_color_picker_title")
        
        // init done icon
        let doneButton   = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func doneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleChangeColor(color: currentColor, type: currentSelectColorType)
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CommonColorPickerViewController: colorDelegate {
    
    func pickedColor(_ color: UIColor) {
        colorView.backgroundColor = color
        currentColor = color
    }
}
