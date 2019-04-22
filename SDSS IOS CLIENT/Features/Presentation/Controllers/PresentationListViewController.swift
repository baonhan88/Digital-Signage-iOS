//
//  PresentationListViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 08/06/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import SVProgressHUD
import AlamofireImage

fileprivate let cellReuseIdentifier = "PresentationListCollectionViewCell"
fileprivate let headerReuseIdentifier = "PresentationListHeaderView"

protocol PresentationListViewControllerDelegate {
    func handleAddPresentation(presentation: Presentation)
}

class PresentationListViewController: BaseCollectionViewController {
    
    fileprivate var dataList: NSMutableArray = NSMutableArray()
    fileprivate var tagSectionList: [String] = []
    fileprivate var templateSlideList: [TemplateSlide] = []
    
    var delegate: PresentationListViewControllerDelegate?
    
    var shouldHandleAddPresentation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "PresentationListCollectionViewCell", bundle: nil),
                                      forCellWithReuseIdentifier: cellReuseIdentifier)
        self.collectionView!.register(UINib(nibName: "PresentationListHeaderView", bundle: nil),
                                      forCellWithReuseIdentifier: headerReuseIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataList = NSMutableArray()
        tagSectionList = []
        
        loadLocalPresentationData()
    }
    
    fileprivate func initNavigationBar() {
        self.title = localizedString(key: "presentation_list_title")
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(handleAddButtonClicked(button:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    fileprivate func loadLocalPresentationData() {
        // get template slide list of current user
        templateSlideList = TemplateSlide.getPresentationListForCurerntUser()
        if templateSlideList.count == 0 {
            collectionView?.reloadData()
            return
        }
        
        do {
            // create PresentationList from that files
            let presentationList = NSMutableArray()
            for templateSlide in templateSlideList {
                let presentationURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + templateSlide.id  + "/" + templateSlide.presentationId + Dir.presentationDesignExtension)
                if let jsonData = NSData(contentsOfFile: presentationURL.path) {
                    let jsonDict = try JSONSerialization.jsonObject(with: jsonData as Data, options: .mutableContainers) as! NSDictionary
                    let presentationInfoDict = jsonDict[DesignFile.paramPresentationInfo] as! NSDictionary
                    let presentaion = Presentation(dictionary: presentationInfoDict)
                    presentaion.folderName = templateSlide.id
                    presentationList.add(presentaion)
                    dLog(message: "tags = " + presentaion.tags.description)
                } else {
                    dLog(message: "can't load presentation at url \(presentationURL.path)")
                }
            }
            
            // get TagName in Presentaion and create TagNameList
            let tagNameList = NSMutableSet()
            for presentaion in presentationList as! [Presentation] {
                if presentaion.tags.count == 0 {
                    tagNameList.add("...")
                } else {
                    for tagName in presentaion.tags {
                        tagNameList.add(tagName)
                    }
                }
            }
            // distinct TagNameList
            self.tagSectionList = Array(tagNameList) as! [String]
            
            // create [[Presentation]] with each TagName in TagNameList
            for tagName in self.tagSectionList {
                let tmpList = NSMutableArray()
                for presentaion in presentationList as! [Presentation] {
                    if tagName == "..." && presentaion.tags.count == 0 {
                        // add presentation for "..." tag
                        tmpList.add(presentaion)
                    } else {
                        for tmpTag in presentaion.tags {
                            if tagName == tmpTag {
                                tmpList.add(presentaion)
                            }
                        }
                    }
                }
                if tmpList.count > 0 {
                    self.dataList.add(tmpList)
                }
            }
            
            collectionView?.reloadData()
            
            dLog(message: "dataList count = " + String(self.dataList.count))
            
        } catch {
            dLog(message: error.localizedDescription)
        }
    }
}

// MARK: - Handle Events

extension PresentationListViewController {
    
    func handleAddButtonClicked(button: UIBarButtonItem) {
        // go to template screen with local segment
        ControllerManager.goToTemplateScreen(isComeFromPresentationListScreen: true, controller: self)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension PresentationListViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tagSectionList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let presentationList = dataList[section] as! [Presentation]
        return presentationList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
//        switch kind {
//        case UICollectionElementKindSectionHeader:
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
//                                                                             withReuseIdentifier: "PresentationListHeaderView",
//                                                                             for: indexPath) as! PresentationListHeaderView
//            headerView.label.text = tagSectionList[indexPath.section]
//            return headerView
//        default:
//            assert(false, "Unexpected element kind")
//        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "PresentationListHeaderView",
                                                                         for: indexPath) as! PresentationListHeaderView
        headerView.label.text = tagSectionList[indexPath.section]
        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? PresentationListCollectionViewCell
        
        let presentationList = dataList[indexPath.section] as! [Presentation]
        let presentation = presentationList[indexPath.row]
        cell?.label.text = presentation.name
        
        let placeholderImage = UIImage(named: "icon_template_placeholder")!

        let thumbnailUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + presentation.folderName + "/" + presentation.id + Dir.presentationThumbnailExtension)
//        if FileManager.default.fileExists(atPath: thumbnailUrl.path) {
//            DispatchQueue.global().async {
//                let image = UIImage.init(contentsOfFile: thumbnailUrl.path)
//                DispatchQueue.main.async {
//                    cell?.imageView.image = image
//                }
//            }
//        }
        Utility.clearImageFromCache(withURL: thumbnailUrl)
        cell?.imageView.af_setImage(withURL: thumbnailUrl, placeholderImage: placeholderImage)
        
        return cell!
    }
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let presentationList = dataList[indexPath.section] as! [Presentation]
        let presentation = presentationList[indexPath.row]
        
        if shouldHandleAddPresentation {
            // check accessRight -> User must have permission to use
            if AccessRightManager.canUse(accessRight: presentation.accessRight) {
                delegate?.handleAddPresentation(presentation: presentation)
                self.navigationController?.popViewController(animated: true)
            } else {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "access_right_can't_use"), controller: self)
            }
        } else {
            // go to PresentationEditorViewController
            ControllerManager.goToPresentationEditorScreen(presentationId: presentation.id,
                                                           presentationFolderName: presentation.folderName,
                                                           isComeFromTemplate: false,
                                                           isComeFromPresentationListScreen: false,
                                                           controller: self)
        }
    }
}

