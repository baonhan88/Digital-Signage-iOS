//
//  EditShapeViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 14/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

enum EditShapeCellType: Int {
    case lineWidth = 0
    case linePattern = 1
    case strokeColor = 2
    case fillColor = 3
}

protocol EditShapeViewControllerDelegate {
    func handleUpdateFrame(newFrame: Frame, region: Region)
}

class EditShapeViewController: BaseTableViewController {
    
    var delegate: EditShapeViewControllerDelegate?
    
    // input value
    var region: Region?
    var frame: Frame?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()

        self.tableView.register(UINib(nibName: "EditTextNameCell", bundle: nil), forCellReuseIdentifier: "EditTextNameCell")
        self.tableView.register(UINib(nibName: "EditShapeLineWidthCell", bundle: nil), forCellReuseIdentifier: "EditShapeLineWidthCell")
        self.tableView.register(UINib(nibName: "SelectColorCell", bundle: nil), forCellReuseIdentifier: "SelectColorCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "presentation_editor_update_shape_title")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(handleDoneButtonClicked(barButton:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func getCurrentLinePatternIndex() -> Int {
        var index = 0
        for linePattern in kLinePatternList {
            if linePattern == frame?.linePattern {
                return index
            }
            index += 1
        }
        return 0
    }
}

// MARK: - Handle Events

extension EditShapeViewController {
    
    func handleDoneButtonClicked(barButton: UIBarButtonItem) {
        delegate?.handleUpdateFrame(newFrame: frame!, region: region!)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension EditShapeViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            
        case EditShapeCellType.lineWidth.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditShapeLineWidthCell") as? EditShapeLineWidthCell
            
            cell?.delegate = self
            cell?.initView(lineWidth: (frame?.lineDepth)!)
            
            return cell!
            
        case EditShapeCellType.linePattern.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextNameCell") as? EditTextNameCell
            
            cell?.leftLabel.text = localizedString(key: "presentation_editor_update_shape_line_pattern_title")
            
            if frame?.linePattern == "" {
                cell?.rightLabel.text = kLinePatternList[kLinePatternDefault]
            } else {
                cell?.rightLabel.text = kLinePatternList[getCurrentLinePatternIndex()]
            }
            
            return cell!
            
        case EditShapeCellType.strokeColor.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell") as? SelectColorCell
            
            cell?.leftLabel.text = localizedString(key: "presentation_editor_update_shape_stroke_color_title")
            
            if frame?.lineColor == "" {
                cell?.initViewWithColor(color: UIColor.white)
            } else {
                cell?.initViewWithColor(hexString: (frame?.lineColor)!)
            }
        
            return cell!
            
        case EditShapeCellType.fillColor.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell") as? SelectColorCell
            
            cell?.leftLabel.text = localizedString(key: "presentation_editor_update_shape_fill_color_title")
            
            if frame?.fillColor == "" {
                cell?.initViewWithColor(color: UIColor.white)
            } else {
                cell?.initViewWithColor(hexString: (frame?.fillColor)!)
            }
            
            return cell!

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditShapeLineWidthCell") as? EditShapeLineWidthCell
            return cell!
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
            
        case EditShapeCellType.linePattern.rawValue:
            ControllerManager.goToCommonSelectionScreen(selectionList: kLinePatternList as NSArray,
                                                        currentSelection: getCurrentLinePatternIndex(),
                                                        currentType: SelectionType.linePattern,
                                                        title: localizedString(key: "presentation_editor_update_shape_line_pattern_title"),
                                                        controller: self)
            break
            
        case EditShapeCellType.strokeColor.rawValue:
            ControllerManager.goToColorPickerScreen(currentColor: UIColor.init(hexString: (frame?.lineColor)!)!, type: .strokeColor, controller: self)
            break
            
        case EditShapeCellType.fillColor.rawValue:
            ControllerManager.goToColorPickerScreen(currentColor: UIColor.init(hexString: (frame?.fillColor)!)!, type: .fillColor, controller: self)
            break
            
        default:
            break
        }
    }

}

// MARK: - CommonSelectionViewControllerDelegate

extension EditShapeViewController: CommonSelectionViewControllerDelegate {
    
    func handleDoneButton(currentSelectionIndex: Int, selectionType: SelectionType) {
        switch selectionType {
        case .linePattern:
            frame?.linePattern = kLinePatternList[currentSelectionIndex]
        default:
            return
        }
        
        tableView.reloadRows(at: [IndexPath.init(row: EditShapeCellType.linePattern.rawValue, section: 0)], with: .fade)
    }
}

// MARK: - CommonColorPickerViewControllerDelegate

extension EditShapeViewController: CommonColorPickerViewControllerDelegate {
    
    func handleChangeColor(color: UIColor, type: SelectColorType) {
        switch type {
        case .strokeColor:
            frame?.lineColor = color.toHexString()
            tableView.reloadRows(at: [IndexPath.init(row: EditShapeCellType.strokeColor.rawValue, section: 0)], with: .fade)
            break
        case .fillColor:
            frame?.fillColor = color.toHexString()
            tableView.reloadRows(at: [IndexPath.init(row: EditShapeCellType.fillColor.rawValue, section: 0)], with: .fade)
        default:
            break
        }
    }
}

// MARK: - EditShapeLineWidthCellDelegate

extension EditShapeViewController: EditShapeLineWidthCellDelegate {
    
    func lineWidthChanged(width: Int) {
        frame?.lineDepth = width
    }
}
