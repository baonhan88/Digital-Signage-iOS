//
//  BaseCollectionViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 21/07/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class BaseCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.emptyDataSetSource = self
        //        self.collectionView?.emptyDataSetDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - DZNEmptyDataSetSource

extension BaseCollectionViewController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "icon_empty")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 13.0), NSForegroundColorAttributeName : UIColor.darkGray]
        return NSAttributedString.init(string: localizedString(key: "common_empty_title"), attributes: attributes)
    }
}
