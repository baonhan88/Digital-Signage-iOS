//
//  PresentationEditorViewController.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 17/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

@objc protocol PresentationEditorViewControllerDelegate {
    @objc optional func handleReloadRightMenu()
    @objc optional func handleAccessRightForNavigationBar(accessRight: Int)
}

class PresentationEditorViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var displayViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var displayViewHeightConstraint: NSLayoutConstraint!
    
    // input data
    var currentPresentationId: String = ""
    var isComeFromTemplate: Bool = true
    var folderName: String = ""
    var isComeFromPresentationListScreen = false

    fileprivate var presentation: Presentation = Presentation()
    fileprivate var regionList: [Region] = []
    
    fileprivate var selectedViewDrawed: UIImageView?
    fileprivate var selectedRegion: Region?
    
    fileprivate var isFirstTimeLoadView = true
    
    var delegate: PresentationEditorViewControllerDelegate?
    var slideMenuDelegate: PresentationEditorViewControllerDelegate?
    
    fileprivate var pinCodeJsonString = ""
    
    fileprivate var shapeList: [CAShapeLayer] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayView.layer.borderColor = UIColor.lightGray.cgColor
        self.displayView.layer.borderWidth = 1
        self.displayView.layer.masksToBounds = true
        
        // load local data
        loadLocalPresentationData()
        
        slideMenuDelegate?.handleAccessRightForNavigationBar!(accessRight: presentation.accessRight)
        
        if isComeFromTemplate {
            // create new folder and copy all assets + presentation design file + presentation thumbnail to it
            createNewFolderAndCopyAllThingRelatedToPresentation()
        }
        
        // config zoom in/out for scrollview
        configScrollViewToZoomInOut()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapOnPresentation(gesture:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        self.displayView.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstTimeLoadView {
            SVProgressHUD.show()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstTimeLoadView {
            // clear old display view
//            self.displayView.subviews.forEach({ $0.removeFromSuperview() })
            
            // calculate resolution of display view
            calculateResolutionDisplayView()
            
            // delay 0.1s to make sure autolayout finished
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                self.addBgImage()

                self.addAllRegionOnDisplayView()
                
                SVProgressHUD.dismiss()
                
                self.isFirstTimeLoadView = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        scrollView.setZoomScale(1.0, animated: false)
        selectedViewDrawed?.removeFromSuperview()
        selectedRegion = nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    fileprivate func checkAndCreateTmpFolderUnlessExist() {
        if !FileManager.default.fileExists(atPath: getTmpFolderPath().path) {
            // create tmp folder to keep all changes (image & video asset)
            DesignFileHelper.createNewFolder(folderUrl: getTmpFolderPath())
            
            // copy presentation design file to tmp folder
            DesignFileHelper.copyFile(fromPath: getCurrentDesignFile(), toPath: getTmpDesignFile())
        }
    }
    
    fileprivate func hasChange() -> Bool {
        if FileManager.default.fileExists(atPath: getTmpFolderPath().path) {
            return true
        }
        
        return false
    }
    
    fileprivate func getCurrentPresentationFolderPath() -> URL {
        return Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName)
    }
    
    fileprivate func getTmpFolderPath() -> URL {
        return Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName + "/" + Dir.tmpFolderName)
    }
    
    fileprivate func getTmpDesignFile() -> URL {
        return getTmpFolderPath().appendingPathComponent(folderName + Dir.presentationDesignExtension)
    }
    
    fileprivate func getCurrentDesignFile() -> URL {
        return getCurrentPresentationFolderPath().appendingPathComponent(folderName + Dir.presentationDesignExtension)
    }
}

// MARK: - Process calculate to load Presentation

extension PresentationEditorViewController {
    
    fileprivate func loadLocalPresentationData() {
        var fileURL: URL?
        if isComeFromTemplate {
            fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.template + currentPresentationId + Dir.presentationDesignExtension)
        } else {
            fileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName + "/" + currentPresentationId + Dir.presentationDesignExtension)
        }
        
        guard let tmpPresentation = DesignFileHelper.getPresentationFromDesignFile(fileURL: fileURL!),
            let tmpRegionList = DesignFileHelper.getRegionListFromDesignFile(fileURL: fileURL!) else {
            
            dLog(message: "can't load data from design file with path \(String(describing: fileURL?.path))")
            return
        }
        
        presentation = tmpPresentation
        
        regionList = tmpRegionList
    }
    
    fileprivate func createNewFolderAndCopyAllThingRelatedToPresentation() {
        // create new folder
        let folderUrl = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName)
        DesignFileHelper.createNewFolder(folderUrl: folderUrl)
        
        // copy all things to new folder
        // copy assets
        for region in regionList {
            switch region.type {
                
            case MediaType.image.name():
                if let image = Utility.getFirstImageFromRegion(region: region) {
                    if image.sourceType == ImageAssetType.localImage.name() {
                        // copy image to new folder
                        let fromPath = Utility.getUrlFromDocumentWithAppend(url: Dir.assets + image.assetId + image.assetExt)
                        let toPath = folderUrl.appendingPathComponent(image.assetId + image.assetExt)
                        DesignFileHelper.copyFile(fromPath: fromPath, toPath: toPath)
                    }
                }
                
            case MediaType.video.name():
                if let video = Utility.getFirstVideoFromRegion(region: region) {
                    // copy video to new folder
                    let fromPath = Utility.getUrlFromDocumentWithAppend(url: Dir.assets + video.assetId + video.assetExt)
                    let toPath = folderUrl.appendingPathComponent(video.assetId + video.assetExt)
                    DesignFileHelper.copyFile(fromPath: fromPath, toPath: toPath)
                }

            default:
                continue
            }
        }
        
//        // create tmp folder to keep all changes (image & video asset)
//        let tmpFolderUrl = folderUrl.appendingPathComponent(Dir.tmpFolderName)
//        DesignFileHelper.createNewFolder(folderUrl: tmpFolderUrl)
//        
//        // copy presentation design file to tmp folder
//        DesignFileHelper.copyFile(fromPath: fromPath, toPath: getTmpDesignFile())
        
        // copy presentation thumbnail
        let fromPath = Utility.getUrlFromDocumentWithAppend(url: Dir.templateThumbnail + presentation.id + Dir.presentationThumbnailExtension)
        let toPath = folderUrl.appendingPathComponent(folderName + Dir.presentationThumbnailExtension)
        DesignFileHelper.copyFile(fromPath: fromPath, toPath: toPath)
        
        // save presentation design file to folderName path
        let saveDesignFileURL = folderUrl.appendingPathComponent(folderName + Dir.presentationDesignExtension)
        
        // change presentation id with folderName to save
        let tmpPresentationId = self.presentation.id
        self.presentation.lock = true
        self.presentation.id = folderName
        self.presentation.code = folderName
        
        DesignFileHelper.saveDesignFile(fromPresentation: self.presentation, andRegionList: self.regionList, saveTo: saveDesignFileURL)
        
        // revert to old presentation id to keep all references to resources of Template (design file, assets, thumbnail)
        self.presentation.id = tmpPresentationId
        self.presentation.code = tmpPresentationId
    }
    
    fileprivate func calculateResolutionDisplayView() {
        // convert from ratio string to ratio width & ratio height
        let ratioString = presentation.ratio
        let ratioWidthString = ratioString.components(separatedBy: ":")[0]
        let ratioHeightString = ratioString.components(separatedBy: ":")[1]
        var ratioWidth: CGFloat = 0
        var ratioHeight: CGFloat = 0
        if let n = NumberFormatter().number(from: ratioWidthString) {
            ratioWidth = CGFloat(n)
        }
        if let n = NumberFormatter().number(from: ratioHeightString) {
            ratioHeight = CGFloat(n)
        }
        
        // calculate displayView resolution
        let contentViewWidth = contentView.frame.size.width
        let contentViewHeight = contentView.frame.size.height
        let widthWithRatio = (contentViewHeight*ratioWidth)/ratioHeight
        
        if widthWithRatio > contentViewWidth { // out of width screen size
            displayViewWidthConstraint.constant = contentViewWidth
            displayViewHeightConstraint.constant = (contentViewWidth*ratioHeight)/ratioWidth
        } else {
            displayViewWidthConstraint.constant = (contentViewHeight*ratioWidth)/ratioHeight
            displayViewHeightConstraint.constant = contentViewHeight
        }
    }
    
    fileprivate func addBgImage() {
        let bgImage = presentation.bgImage
        
        switch bgImage.type {
            
        case BgImageType.color.name():
            guard let color = UIColor.init(hexString: bgImage.value) else {
                dLog(message: "can't convert to color with hex = \(bgImage.value)")
                return
            }
            displayView.backgroundColor = color
            
        case BgImageType.localImage.name():
            if let bgImageAsset = getBgImageAssetWithAssetId(bgImage.value) {
                let localImageURL = Utility.getUrlFromDocumentWithAppend(url: Dir.savePresentation + folderName + "/" + bgImageAsset.id + bgImageAsset.ext)
                guard let tmpImage = UIImage(contentsOfFile: localImageURL.path) else {
                    dLog(message: "can't load image from url: \(String(describing: localImageURL.path))")
                    return
                }
                bgImageView.image = tmpImage
            }
            
        case BgImageType.remoteImage.name():
            // implement later
            break
            
        default:
            return
        }
    }
    
    fileprivate func getBgImageAssetWithAssetId(_ assetId: String) -> Asset? {
        for asset in presentation.assetList {
            if asset.id == assetId {
                return asset
            }
        }
        
        return nil
    }
    
    fileprivate func addAllRegionOnDisplayView() {
        // sort RegionList with zOrder
        regionList = regionList.sorted { $0.zOrder < $1.zOrder }
        
        // render all regions to display view
        for region in regionList {
            switch region.type {
            case MediaType.image.name():
                addImageRegion(region: region)
            case MediaType.video.name():
                addVideoRegion(region: region)
            case MediaType.text.name():
                addTextRegion(region: region)
            case MediaType.webpage.name():
                addWebRegion(region: region)
            case MediaType.frame.name():
                addShapeRegion(region: region)
            case MediaType.widget.name():
                addWidget(region: region)
            default:
                dLog(message: "don't know region type")
            }
        }
    }
    
    fileprivate func addImageRegion(region: Region) {
        for image in region.objects as! [Image] {
            // mapping x,y,width,heigt of Image to DisplayView
            let currentRect = CGRect(x: image.x, y: image.y, width: image.width, height: image.height)
            let rectMapped = mappingToDisplayView(currentRect: currentRect)
            
            // get image url
            var imageURL: URL?
            switch image.sourceType {
                
            case ImageAssetType.localImage.name():
                imageURL = getCurrentPresentationFolderPath().appendingPathComponent(image.assetId + image.assetExt)
                
            case ImageAssetType.image.name():
                imageURL = URL(string: Network.baseURL + image.sourcePath)!
                
            default:
                dLog(message: "image asset type = \(image.sourceType) hadn't handled yet")
                return
            }
            
            guard let tmpImage = UIImage(contentsOfFile: (imageURL?.path)!) else {
                dLog(message: "can't load image from url: \(String(describing: imageURL?.path))")
                return
            }
            
            // create new imageView to mapping all image data and add to displayView
            let imageView = UIImageView()
            imageView.frame = rectMapped
            imageView.image = tmpImage
            imageView.alpha = CGFloat(image.alpha/255)
            
            // make rotation with root "top left"
            Utility.setAnchorPoint(anchorPoint: CGPoint.init(x: 0, y: 0), view: imageView)
            imageView.transform = imageView.transform.rotated(by: CGFloat(image.rotate.degreesToRadians))
            
            // bgColor don't use now, will use it next time
//            imageView.backgroundColor = UIColor.init(hexString: image.bgColor)
            
            // for handle tap on imageView
            imageView.tag = Int(region.id)!
            imageView.isUserInteractionEnabled = true
            
            displayView.addSubview(imageView)
            dLog(message: "added imageView with tag = \(imageView.tag.description)")
        }
    }
    
    fileprivate func addVideoRegion(region: Region) {
        for video in region.objects as! [Video] {
            // mapping x,y,width,heigt of Image to DisplayView
            let currentRect = CGRect(x: video.x, y: video.y, width: video.width, height: video.height)
            let rectMapped = mappingToDisplayView(currentRect: currentRect)
            
            let videoIconImageView = UIImageView()
            videoIconImageView.tag = (Int(region.id)! + 1)
            var image: UIImage?
            var videoURL: URL?
            
            // calculate size of icon
            var iconSize: CGFloat = 0
            if rectMapped.size.width > rectMapped.size.height {
                iconSize = rectMapped.size.height / 2
            } else {
                iconSize = rectMapped.size.width / 2
            }
            
            switch video.sourceType {
                
            case VideoAssetType.localVideo.name():
                videoURL = getCurrentPresentationFolderPath().appendingPathComponent(video.assetId + video.assetExt)
                
                // create new imageView to mapping all image data and add to displayView
                image = DesignFileHelper.thumbnailForLocalVideoAtURL(url: videoURL!)
                if image == nil {
                    dLog(message: "can't load video thumbnail with url: " + (videoURL?.path)!)
                    return
                }
                
                // create video icon add overlay on center of thumbnail video
                videoIconImageView.frame = CGRect.init(x: (rectMapped.size.width-iconSize)/2, y: (rectMapped.size.height-iconSize)/2, width: iconSize, height: iconSize)
                videoIconImageView.image = UIImage.init(named: "icon_video")

            case VideoAssetType.youtubeVideo.name():
                image = Utility.getYoutubeThumbnail(youtubeUrl: video.sourcePath)
                if image == nil {
                    return
                }
                
                // create youtube icon add overlay on center of thumbnail video with size 70x70
                videoIconImageView.frame = CGRect.init(x: (rectMapped.size.width-iconSize)/2, y: (rectMapped.size.height-iconSize)/2, width: iconSize, height: iconSize)
                videoIconImageView.image = UIImage.init(named: "icon_youtube")
                
            default:
                dLog(message: "video asset type = \(video.sourceType) hadn't handled yet")
                return
            }
            
            // create thumbnail video
            let thumbVideoImageView = UIImageView()
            thumbVideoImageView.frame = rectMapped
            thumbVideoImageView.image = image
            thumbVideoImageView.alpha = CGFloat(video.alpha/255)
            thumbVideoImageView.backgroundColor = UIColor.init(hexString: video.bgColor)
            
            // make rotation with root "top left"
            Utility.setAnchorPoint(anchorPoint: CGPoint.init(x: 0, y: 0), view: thumbVideoImageView)
            thumbVideoImageView.transform = thumbVideoImageView.transform.rotated(by: CGFloat(video.rotate.degreesToRadians))
            
            thumbVideoImageView.addSubview(videoIconImageView)
            // for handle tap on imageView
            thumbVideoImageView.tag = Int(region.id)!
            thumbVideoImageView.isUserInteractionEnabled = true
            
            displayView.addSubview(thumbVideoImageView)
            dLog(message: "added video thumbnail with tag = \(thumbVideoImageView.tag.description)")
        }
    }
    
    fileprivate func addTextRegion(region: Region) {
        for text in region.objects as! [Text] {
            // mapping x,y,width,heigt of Text to DisplayView
            let currentRect = CGRect(x: text.x, y: text.y, width: text.width, height: text.height)
            let rectMapped = mappingToDisplayView(currentRect: currentRect)
            
            // create new UILabel to mapping all text data and add to displayView
            let textLabel = UILabel.init(frame: rectMapped)
            textLabel.text = text.text
            textLabel.font = UIFont.init(name: text.fontName, size: getValueMapWithDisplayRatio(value:text.fontSize))
            textLabel.textColor = UIColor.init(hexString: text.fontColor)
            textLabel.backgroundColor = UIColor.init(hexString: text.bgColor)
            textLabel.numberOfLines = 0
            
            // make rotation with root "top left"
            Utility.setAnchorPoint(anchorPoint: CGPoint.init(x: 0, y: 0), view: textLabel)
            textLabel.transform = textLabel.transform.rotated(by: CGFloat(text.rotate.degreesToRadians))
            
            switch text.align {
            case TextAlignType.left.name():
                textLabel.textAlignment = NSTextAlignment.left
            case TextAlignType.right.name():
                textLabel.textAlignment = NSTextAlignment.right
            case TextAlignType.center.name():
                textLabel.textAlignment = NSTextAlignment.center
            default:
                textLabel.textAlignment = NSTextAlignment.left
            }
            
//            text.fontStyle = "bold italic underline strikethrough"
            // setup fontStyle
            setupFontStyle(textLabel: textLabel, text: text)
            
//            textLabel.shadowColor = UIColor.init(hexString: text.shadowColor)
//            textLabel.shadowOffset = CGSize.init(width: text.shadowDX, height: text.shadowDY)
//            textLabel.layer.shadowRadius = text.shadowRadius
            // for handle tap on Text
            textLabel.tag = Int(region.id)!
            textLabel.isUserInteractionEnabled = true
            displayView.addSubview(textLabel)
            dLog(message: "added text with tag = \(textLabel.tag.description)")
        }
    }
    
    fileprivate func setupFontStyle(textLabel: UILabel, text: Text) {
        if text.fontStyle == "" {
            return
        }
        
        var isBold = false
        var isItalic = false
        var isUnderline = false
        var isStrikethrough = false
        
        let parts = text.fontStyle.components(separatedBy: " ")
        for part in parts {
            switch part {
            case FontStyle.bold.name():
                isBold = true
            case FontStyle.italic.name():
                isItalic = true
            case FontStyle.underline.name():
                isUnderline = true
            case FontStyle.strikethrough.name():
                isStrikethrough = true
            case FontStyle.regular.name():
                // font stype = Regular, It's mean that we don't need to do anymore
                return
            default:
                dLog(message: "unknow font stype = \(part)")
            }
        }
        
        // for bold and italic
        if isBold == true && isItalic == true {
            textLabel.font = textLabel.font.boldItalic()
        } else if isBold {
            textLabel.font = textLabel.font.bold()
        } else if isItalic {
            textLabel.font = textLabel.font.italic()
        }
        
        // for underline & strikethrough
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text.text)
        if isUnderline {
            attributeString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
        }
        if isStrikethrough {
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        }
        textLabel.attributedText = attributeString
    }
    
    fileprivate func addWebRegion(region: Region) {
        for webpage in region.objects as! [Webpage] {
            // mapping x,y,width,heigt of Text to DisplayView
            let currentRect = CGRect(x: webpage.x, y: webpage.y, width: webpage.width, height: webpage.height)
            let rectMapped = mappingToDisplayView(currentRect: currentRect)
            
            switch webpage.sourceType {
                
            case WebAssetType.remote.name():
                // create new UIWebView to render webpage to displayView
                let webView = UIWebView.init(frame: rectMapped)
                
                // make rotation with root "top left"
                Utility.setAnchorPoint(anchorPoint: CGPoint.init(x: 0, y: 0), view: webView)
                webView.transform = webView.transform.rotated(by: CGFloat(webpage.rotate.degreesToRadians))
                
                webView.loadRequest(URLRequest.init(url: URL.init(string: webpage.sourcePath)!))
                // for handle tap on Webpage
                webView.tag = Int(region.id)!
                webView.isUserInteractionEnabled = true
                displayView.addSubview(webView)
                dLog(message: "added webpage with tag = \(webView.tag.description)")

            default:
                dLog(message: "web asset type = \(webpage.sourceType) hadn't handled yet")
                return
            }
            
        }
    }
    
    fileprivate func addShapeRegion(region: Region) {
        for frame in region.objects as! [Frame] {
            let shapeLayer = CAShapeLayer()

            // config to draw shape
            configShapeLayer(shapeLayer, with: frame, and: region)
            
            // draw shape layer on UIView
            let currentRect = CGRect(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
            let rectMapped = mappingToDisplayView(currentRect: currentRect)
            let renderView = UIView.init(frame: rectMapped)
            renderView.layer.addSublayer(shapeLayer)
            // make rotation
            Utility.setAnchorPoint(anchorPoint: CGPoint.init(x: 0, y: 0), view: renderView)
            renderView.transform = renderView.transform.rotated(by: CGFloat(frame.rotate.degreesToRadians))
            
            shapeList.append(shapeLayer)
            displayView.addSubview(renderView)
        }
    }
    
    fileprivate func updateShapeLayer(_ shapeLayer: CAShapeLayer, with region: Region) {
        guard let frame = Utility.getFirstShapeFromRegion(region: region) else {
            return
        }
        
        // config to draw shape
        configShapeLayer(shapeLayer, with: frame, and: region)
    }
    
    fileprivate func configShapeLayer(_ shapeLayer: CAShapeLayer, with frame: Frame, and region: Region) {
        let currentRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let rectMapped = mappingToDisplayView(currentRect: currentRect)
        
        shapeLayer.fillColor = UIColor.init(hexString: frame.fillColor)?.cgColor
        shapeLayer.strokeColor = UIColor.init(hexString: frame.lineColor)?.cgColor
        shapeLayer.lineWidth = CGFloat(getValueMapWithDisplayRatio(value: CGFloat(frame.lineDepth)))
        shapeLayer.zPosition = CGFloat(region.zOrder)

        // configure to draw RECT or ELLIPSE
        switch frame.shapeType {
            
        case ShapeAssetType.rectangle.name():
            let rectPath = UIBezierPath.init(rect: rectMapped)
            
            shapeLayer.path = rectPath.cgPath
            break
            
        case ShapeAssetType.circle.name():
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: rectMapped.origin.x + rectMapped.size.width/2,
                                                             y: rectMapped.origin.y + rectMapped.size.height/2),
                                          radius: CGFloat(rectMapped.size.height/2),
                                          startAngle: CGFloat(0),
                                          endAngle:CGFloat(Double.pi * 2),
                                          clockwise: true)
            
            shapeLayer.path = circlePath.cgPath
            break
            
        default:
            dLog(message: "shape asset type = \(frame.shapeType) hadn't handled yet")
            return
        }
        
        // configure line pattern
        switch frame.linePattern {
        case ShapeLinePatternType.dotted.name():
            shapeLayer.lineDashPhase = 5
            shapeLayer.lineDashPattern = [3, 5]
            break
        case ShapeLinePatternType.dashed.name():
            shapeLayer.lineDashPhase = 2
            shapeLayer.lineDashPattern = [5, 2]
            break
        case ShapeLinePatternType.solid.name():
            shapeLayer.lineDashPhase = 0
            shapeLayer.lineDashPattern = nil
            break
        default:
            dLog(message: "can't load linePattern = \(frame.linePattern)")
            break
        }
    }
    
    fileprivate func addWidget(region: Region) {
        for widget in region.objects as! [Widget] {
            // mapping x,y,width,heigt of Text to DisplayView
            let currentRect = CGRect(x: widget.x, y: widget.y, width: widget.width, height: widget.height)
            let rectMapped = mappingToDisplayView(currentRect: currentRect)
            
            switch widget.sourceType {
                
            case WidgetType.cloud.name():
                // create new UIWebView to render webpage to displayView
                let webView = UIWebView.init(frame: rectMapped)
                
                // make rotation with root "top left"
                Utility.setAnchorPoint(anchorPoint: CGPoint.init(x: 0, y: 0), view: webView)
                webView.transform = webView.transform.rotated(by: CGFloat(widget.rotate.degreesToRadians))
                
                let webViewURLString = Network.baseURL + String.init(format: Network.widgetRenderContentUrl, widget.value) + "?access_token=\(Utility.getToken())"
                webView.loadRequest(URLRequest.init(url: URL.init(string: webViewURLString)!))
                // for handle tap on Webpage
                webView.tag = Int(region.id)!
                webView.isUserInteractionEnabled = true
                displayView.addSubview(webView)
                dLog(message: "added widget with tag = \(webView.tag.description)")
                
            case WidgetType.local.name():
                break
                
            case WidgetType.remote.name():
                break
                
            default:
                dLog(message: "web asset type = \(widget.sourceType) hadn't handled yet")
                return
            }
            
        }
    }
    
    fileprivate func mappingToDisplayView(currentRect: CGRect) -> CGRect {
        let displayViewSize = displayView.frame.size
        let ratioWidth = displayViewSize.width / presentation.width
        let ratioHeight = displayViewSize.height / presentation.height
        
        return CGRect(x: CGFloat(ceilf(Float(currentRect.origin.x * ratioWidth))),
                      y: CGFloat(ceilf(Float(currentRect.origin.y * ratioHeight))),
                      width: CGFloat(ceilf(Float(currentRect.size.width * ratioWidth))),
                      height: CGFloat(ceilf(Float(currentRect.size.height * ratioHeight))))
    }
    
    fileprivate func getValueMapWithDisplayRatio(value: CGFloat) -> CGFloat {
        let displayViewSize = displayView.frame.size
        let ratioWidth = displayViewSize.width / presentation.width
        let ratioHeight = displayViewSize.height / presentation.height
        
        if ratioWidth > ratioHeight {
            return value * ratioWidth
        }
        return value * ratioHeight
    }
}

// MARK: - Handle Events

extension PresentationEditorViewController {
    
    func deleteButtonClicked(barButton: UIBarButtonItem) {
        let alert = UIAlertController(title: localizedString(key: "common_warning"),
                                      message: localizedString(key: "presentation_editor_delete_confirm_message"),
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"),
                                      style: UIAlertActionStyle.default,
                                      handler:nil))
        alert.addAction(UIAlertAction(title: localizedString(key: "common_delete"),
                                      style: UIAlertActionStyle.default,
                                      handler:{ _ in
                                        
                                        weak var weakSelf = self
                                        if (weakSelf?.isComeFromTemplate)! {
                                            weakSelf?.deleteTemplate()
                                        } else {
                                            weakSelf?.deletePresentation()
                                        }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveButtonClicked(barButton: UIBarButtonItem) {
        if !hasChange() && !isComeFromTemplate {
            return
        }
        
        if isComeFromTemplate {
            // show alertView to confirm
            let alertVC = UIAlertController(title: localizedString(key: "common_warning"),
                                            message: localizedString(key: "presentation_editor_message_confirm_save"),
                                            preferredStyle: .alert)
            
            // Create and add the Cancel action
            let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
                // Just dismiss the action sheet
            }
            alertVC.addAction(cancelAction)
            
            // Create and add save action
            let saveAction = UIAlertAction(title: localizedString(key: "common_save"), style: .default) { action -> Void in
                weak var weakSelf = self
        
                weakSelf?.showAlertInputPresentationName()
            }
            alertVC.addAction(saveAction)
            
            // Present the actionsheet
            self.present(alertVC, animated: true, completion: nil)
        } else {
            self.processSavePresentationWithName("", shouldPopViewControllerWhenFinish: false)
        }
       
    }
    
    func sendButtonClicked(barButton: UIBarButtonItem) {
        // show actionsheet to choose video type
        let actionSheetController = UIAlertController(title: localizedString(key: "common_send_alert_title"),
                                                      message: localizedString(key: "common_send_alert_message"),
                                                      preferredStyle: .actionSheet)
        
        // Create and add the Cancel action
        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
            // Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        // Create and add send to cloud option action
        let sendToCloudAction = UIAlertAction(title: localizedString(key: "common_send_to_cloud"), style: .default) {
            [weak self] action -> Void in
            
            self?.processShowAlertToChooseSaveOrJustSend(isSendToCloud: true)
        }
        actionSheetController.addAction(sendToCloudAction)
        
        // Create and add send to local option action
        let sendToLocalAction = UIAlertAction(title: localizedString(key: "common_send_to_local"), style: .default) {
            [weak self] action -> Void in
            
            self?.processShowAlertToChooseSaveOrJustSend(isSendToCloud: false)
        }
        actionSheetController.addAction(sendToLocalAction)
        
        // Present the actionsheet
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func updateDesignToCloudButtonClicked(barButton: UIBarButtonItem) {
//        if !hasChange() {
//            // just go to cloud device list screen
//            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_update_template_message_not_change"), controller: self)
//            return
//        }
//        
//        // show alertView to confirm
//        let alertVC = UIAlertController(title: localizedString(key: "common_warning"),
//                                        message: localizedString(key: "presentation_editor_update_template_message_confirm"),
//                                        preferredStyle: .alert)
//        
//        // Create and add the Cancel action
//        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
//            // just dismiss alert
//        }
//        alertVC.addAction(cancelAction)
//        
//        // Create and add Update action
//        let saveAction = UIAlertAction(title: localizedString(key: "common_update_it"), style: .default) { action -> Void in
//            weak var weakSelf = self
//            
//            // process update template
//            weakSelf?.processUpdateTemplate()
//        }
//        alertVC.addAction(saveAction)
//        
//        // Present the actionsheet
//        self.present(alertVC, animated: true, completion: nil)
    }
    
    func editBgButtonClicked(barButton: UIBarButtonItem) {
        switch self.presentation.bgImage.type {
        case BgImageType.color.name():
            ControllerManager.goToColorPickerScreen(currentColor: UIColor.init(hexString: self.presentation.bgImage.value)!, type: .none, controller: self)
            break
        case BgImageType.localImage.name():
            if self.bgImageView.image != nil {
                ControllerManager.goToEditImageScreen(region: nil, image: self.bgImageView.image!, editImageType: .background, controller: self)
            }
            break
        default:
            break
        }
    }
    
    func editNameButtonClicked(barButton: UIBarButtonItem) {
        // Create the alert controller.
        let alert = UIAlertController(title: "",
                                      message: localizedString(key: "presentation_editor_save_presentation_message"),
                                      preferredStyle: .alert)
        
        // Add the text field
        alert.addTextField { (textField) in
            weak var weakSelf = self
            textField.text = weakSelf?.presentation.name
            textField.placeholder = localizedString(key: "presentation_editor_input_name_placeholder")
        }
        
        // add cancel action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel, handler: { (_) in
            // just dismiss alert
        }))
        
        // add OK action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"), style: .default, handler: { [weak alert] (_) in
            weak var weakSelf = self
            
            // process save presentation
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let trimmedName = (textField?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines)
            if Utility.isValidName(name: trimmedName) {
                weakSelf?.processEditPresentationName(trimmedName)
            } else {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_input_name_invalid"), controller: weakSelf!)
            }
        }))
        
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleBackButton(sender: UIBarButtonItem) {
        if !hasChange() {
            if isComeFromTemplate {
                // remove current presentation folder
                DesignFileHelper.removeFile(fileUrl: getCurrentPresentationFolderPath())
            }
            
            self.popViewController()
            return
        }
        
        // show alertView to confirm
        let alertVC = UIAlertController(title: localizedString(key: "common_warning"),
                                        message: localizedString(key: "presentation_editor_message_confirm_save"),
                                        preferredStyle: .alert)
        
        // Create and add the Cancel action
        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
            // just dismiss alert
        }
        alertVC.addAction(cancelAction)
        
        // Create and add the Cancel action
        let dontSaveAction = UIAlertAction(title: localizedString(key: "common_dont_save"), style: .default) { action -> Void in
            weak var weakSelf = self
            
            weakSelf?.processCancelAllChanged()
            
            weakSelf?.popViewController()
        }
        alertVC.addAction(dontSaveAction)
        
        // Create and add save action
        let saveAction = UIAlertAction(title: localizedString(key: "common_save"), style: .default) { action -> Void in
            weak var weakSelf = self
            
            if (weakSelf?.isComeFromTemplate)! {
                weakSelf?.showAlertInputPresentationName()
            } else {
                weakSelf?.processSavePresentationWithName("", shouldPopViewControllerWhenFinish: true)
            }
        }
        alertVC.addAction(saveAction)
        
        // Present the actionsheet
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func handleTapOnPresentation(gesture: UITapGestureRecognizer) {
        // have selected view
        // true: if location on selected view -> handle tap on selected view
        // false: foreach regionList from highest zOder to lowest zOder -> check location on region
        
        // if user don't have permisson to design -> return
        if !AccessRightManager.canUpdate(accessRight: self.presentation.accessRight) {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "access_right_can't_design"), controller: self)
            return
        }
        
        let touchLocation = gesture.location(in: displayView)
        
        detectTapOnSelectedObject(touchLocation: touchLocation) { (shouldNext) in
            if shouldNext {
                weak var weakSelf = self
                
                // sort RegionList with zOrder from highest to lowest
                let tmpRegionList = weakSelf?.regionList.sorted { $0.zOrder > $1.zOrder }
                
                for region in tmpRegionList! {
                    var mappedRect: CGRect? = nil
                    
                    guard let media = region.objects?[0] else {
                        return
                    }
                    
                    mappedRect = CGRect.init(x: (weakSelf?.getValueMapWithDisplayRatio(value: media.x))!,
                                             y: (weakSelf?.getValueMapWithDisplayRatio(value: media.y))!,
                                             width: (weakSelf?.getValueMapWithDisplayRatio(value: media.width))!,
                                             height: (weakSelf?.getValueMapWithDisplayRatio(value: media.height))!)
                    
                    if mappedRect == nil {
                        continue
                    }
                    
                    if (mappedRect?.contains(touchLocation))! {
                        // process tap on region
                        weakSelf?.processTapOnRegion(region: region)
                        
                        return
                    }
                }
            }
        }
    }
    
    fileprivate func detectTapOnSelectedObject(touchLocation: CGPoint, shouldNext: @escaping (Bool) -> Void) {
        guard selectedViewDrawed != nil && selectedRegion != nil else {
            shouldNext(true)
            return
        }
        
        let rect = selectedViewDrawed?.frame
        if (rect?.contains(touchLocation))! {
            // handle touch on selected region
            processTapOnRegion(region: selectedRegion!)
            
            shouldNext(false)
            return
        }
        
        shouldNext(true)
    }
    
    fileprivate func processTapOnRegion(region: Region) {
        dLog(message: "id = \(region.id) and type = \(region.type)")
        switch region.type {
            
        case MediaType.image.name():
            guard let image = Utility.getFirstImageFromRegion(region: region) else {
                return
            }
            
            switch image.sourceType {
            case ImageAssetType.localImage.name():
                guard let imageView = self.view.viewWithTag(Int(region.id)!) as? UIImageView else {
                    return
                }
                ControllerManager.goToEditImageScreen(region: region, image: imageView.image!, editImageType: .normal, controller: self)
            default:
                dLog(message: "don't know image source type = \(image.sourceType)")
            }
            
        case MediaType.webpage.name():
            guard let webpage = Utility.getFirstWebpageFromRegion(region: region) else {
                return
            }
            
            switch webpage.sourceType {
            case WebAssetType.remote.name():
                ControllerManager.goToEditWebpageScreen(region: region, controller: self)
            default:
                dLog(message: "don't know webpage source type = \(webpage.sourceType)")
            }
            
        case MediaType.video.name():
            guard let imageView = self.view.viewWithTag(Int(region.id)!) as? UIImageView else {
                return
            }
            
            ControllerManager.goToEditVideoScreen(region: region, image: imageView.image!, controller: self)
            
        case MediaType.text.name():
            ControllerManager.goToEditTextScreen(region: region, controller: self)
            
        case MediaType.frame.name():
            guard let frame = Utility.getFirstShapeFromRegion(region: region) else {
                return
            }
            ControllerManager.goToEditShapeScreen(region: region, frame: frame, controller: self)
            
        default:
            dLog(message: "can't edit region with type = \(region.type)")
        }
    }
}

// MARK: - Process Business Logic

extension PresentationEditorViewController {
    
    fileprivate func deletePresentation() {
        // delete presentation on Cloud
        SVProgressHUD.show()
        
        NetworkManager.shared.deletePresentation(id: presentation.id, token: Utility.getToken()) {
            [weak self] (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                // process delete presentation on local
                self?.processDeletePresentationOnLocal()
                
                self?.popViewController()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
    
    fileprivate func processDeletePresentationOnLocal() {
        // remove presentation folder
        DesignFileHelper.removeFile(fileUrl: getCurrentPresentationFolderPath())
        
        // delete on TemplateSlide.json
        TemplateSlide.deletePresentationForCurrentUser(presentationId: presentation.id)
        
        SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_deleted"))
    }
    
    fileprivate func deleteTemplate() {
        // delete all assets
        deleteAllAssets()
        
        // delete presentation thumbnail
        let thumbnailURL = Utility.getUrlFromDocumentWithAppend(url: Dir.templateThumbnail + presentation.id + Dir.presentationThumbnailExtension)
        DesignFileHelper.removeFile(fileUrl: thumbnailURL)
        
        // delete presentation design file
        deletePresentationDesignFile()
        
        // remove current presentation folder
        DesignFileHelper.removeFile(fileUrl: getCurrentPresentationFolderPath())
        
        // delete on TemplateSlide.json
        TemplateSlide.deleteTemplateForCurrentUser(presentationId: presentation.id)
        
        SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_deleted"))
        
        self.popViewController()
    }
    
    fileprivate func deleteAllAssets() {
        for region in regionList {
            if region.type == MediaType.image.name() { // delete images
                guard let objects = region.objects else {
                    continue
                }
                
                if objects.count > 0 {
                    let image = objects[0] as! Image
                    if image.sourceType == ImageAssetType.localImage.name() {
                        // get image url
                        let imageURL = Utility.getUrlFromDocumentWithAppend(url: Dir.assets + image.assetId + image.assetExt)
                        
                        // Delete image file
                        do {
                            try FileManager.default.removeItem(atPath: imageURL.path)
                        }
                        catch {
                            dLog(message: error.localizedDescription)
                        }
                    }
                }
            } else if region.type == MediaType.video.name() { // delete videos
                guard let objects = region.objects else {
                    continue
                }
                
                if objects.count > 0 {
                    let video = objects[0] as! Video
                    if video.sourceType == VideoAssetType.localVideo.name() {
                        // get video url
                        let videoURL = Utility.getUrlFromDocumentWithAppend(url: Dir.assets + video.assetId + video.assetExt)
                        
                        // Delete video file
                        do {
                            try FileManager.default.removeItem(atPath: videoURL.path)
                        }
                        catch {
                            dLog(message: error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func deletePresentationDesignFile() {
        let presentationDesignFileURL = Utility.getUrlFromDocumentWithAppend(url: Dir.template + presentation.id + Dir.presentationDesignExtension)
        do {
            try FileManager.default.removeItem(atPath: presentationDesignFileURL.path)
        }
        catch {
            dLog(message: error.localizedDescription)
        }
    }
    
    fileprivate func processUpdateTemplate() {
        // upload all assets if not exist on server
        
        // update design file to server
        
        // update presentation thumbnail
    }
    
    fileprivate func showAlertInputPresentationName() {
        // Create the alert controller.
        let alert = UIAlertController(title: "",
                                      message: localizedString(key: "presentation_editor_save_presentation_message"),
                                      preferredStyle: .alert)
        
        // Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = localizedString(key: "presentation_editor_input_name_placeholder")
        }
        
        // add cancel action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel, handler: { (_) in
            // just dismiss alert
        }))
        
        // add OK action
        alert.addAction(UIAlertAction(title: localizedString(key: "common_ok"), style: .default, handler: { [weak alert] (_) in
            weak var weakSelf = self
            
            // process save presentation
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let trimmedName = (textField?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines)
            if Utility.isValidName(name: trimmedName) {
                weakSelf?.processSavePresentationWithName(trimmedName, shouldPopViewControllerWhenFinish: true)
            } else {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_input_name_invalid"), controller: weakSelf!)
            }
        }))
        
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func processSavePresentationWithName(_ name: String, shouldPopViewControllerWhenFinish shouldPop: Bool) {
        dLog(message: "save presentation with name \(name)")
        SVProgressHUD.show()
        
        // update asset (remove old, copy new) and info base on old and new design file
        DesignFileHelper.processSavePresentationWithName(name,
                                                         isComeFromTemplate: isComeFromTemplate,
                                                         fromOldDesignFile: getCurrentDesignFile(),
                                                         andNewDesignFile: getTmpDesignFile(),
                                                         withCurrentPresentationFolder: getCurrentPresentationFolderPath(),
                                                         andTmpFolder: getTmpFolderPath(), completion: {
                                                            
                                                            (success) in
                                                            
                                                            weak var weakSelf = self
                                                            
                                                            if !success {
                                                                SVProgressHUD.dismiss()
                                                                Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_save_failed"),
                                                                                                  controller: weakSelf!)
                                                                return
                                                            }
        })
        
        var snapshotURL: URL?
        if isComeFromTemplate {
            // save info to TemplateSlide.json
            TemplateSlide.processSaveNewPresentation(presentationId: folderName, completion: {
                (success) in
                
                weak var weakSelf = self
                
                if !success {
                    SVProgressHUD.dismiss()
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_save_failed"),
                                                      controller: weakSelf!)
                    return
                }
            })
            
            // define URL to save thumbnail for Template
            snapshotURL = getCurrentPresentationFolderPath().appendingPathComponent(folderName + Dir.presentationThumbnailExtension)
        } else {
            // define URL to save thumbnail for Presentation
            snapshotURL = getCurrentPresentationFolderPath().appendingPathComponent(presentation.id + Dir.presentationThumbnailExtension)
        }
        
        Utility.takeSnapshotWithView(displayView, andSaveTo: snapshotURL!, completion: {
            (success) in
            
            weak var weakSelf = self
            
            if !success {
                SVProgressHUD.dismiss()
                Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_save_failed"),
                                                  controller: weakSelf!)
                return
            }
        })
        
        SVProgressHUD.dismiss()
        SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_saved"))
        
        if shouldPop {
            self.popViewController()
        }
    }
    
    fileprivate func popViewController() {
        if isComeFromPresentationListScreen {
            // pop to PresentationListViewController
            for vc in (self.navigationController?.viewControllers)! {
                if vc.isKind(of: PresentationListViewController.self) {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        } else {
            // pop to previous view controller
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    fileprivate func processCancelAllChanged() {
        if isComeFromTemplate {
            // remove current presentation folder
            DesignFileHelper.removeFile(fileUrl: getCurrentPresentationFolderPath())
        } else {
            // remove tmp folder
            DesignFileHelper.removeFile(fileUrl: getTmpFolderPath())
        }
    }
    
    fileprivate func processEditPresentationName(_ name: String) {
        SVProgressHUD.show()
        
        // edit name on cloud
        NetworkManager.shared.editNamePresentation(id: self.presentation.id, name: name, token: Utility.getToken()) {
            [weak self] (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                // edit name on local
                DesignFileHelper.editPresentationName(name, presentationId: (self?.presentation.id)!)
                
                SVProgressHUD.showSuccess(withStatus: localizedString(key: "common_edited"))
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
    
    fileprivate func processShowAlertToChooseSaveOrJustSend(isSendToCloud: Bool) {
        if !hasChange() {
            if isSendToCloud {
                // just go to cloud device list screen
                ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .presentation, controller: self)
            } else {
                // just go to local device list screen
                ControllerManager.goToLocalDeviceListScreen(presentationId: presentation.id, folderName: folderName, controller: self)
            }
            return
        }
        
        // show alertView to confirm
        let alertVC = UIAlertController(title: localizedString(key: "common_warning"),
                                        message: localizedString(key: "presentation_editor_send_presentation_message_confirm"),
                                        preferredStyle: .alert)
        
        // Create and add the Cancel action
        let cancelAction = UIAlertAction(title: localizedString(key: "common_cancel"), style: .cancel) { action -> Void in
            // just dismiss alert
        }
        alertVC.addAction(cancelAction)
        
        // Create and add the Just Send action
        let dontSaveAction = UIAlertAction(title: localizedString(key: "common_just_send"), style: .default) {
            [weak self] action -> Void in
            
            if isSendToCloud {
                // just go to cloud device list screen
                ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .presentation, controller: self!)
            } else {
                // just go to local device list screen
                ControllerManager.goToLocalDeviceListScreen(presentationId: (self?.presentation.id)!, folderName: (self?.folderName)!, controller: self!)
            }
        }
        alertVC.addAction(dontSaveAction)
        
        // Create and add Save & Send action
        let saveAction = UIAlertAction(title: localizedString(key: "common_save_and_send"), style: .default) {
            [weak self] action -> Void in
            
            // process save presentation
            self?.processSavePresentationWithName("", shouldPopViewControllerWhenFinish: false)
            
            if isSendToCloud {
                // just go to cloud device list screen
                ControllerManager.goToCloudDeviceListScreen(currentDeviceListType: .presentation, controller: self!)
            } else {
                // just go to local device list screen
                ControllerManager.goToLocalDeviceListScreen(presentationId: (self?.presentation.id)!, folderName: (self?.folderName)!, controller: self!)
            }
        }
        alertVC.addAction(saveAction)
        
        // Present the actionsheet
        self.present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - Handle Send Presentation to Cloud

extension PresentationEditorViewController {
    
    fileprivate func processSendPresentationToCloud() {
        // process upload presentation
        let uploadHelper = UploadPresentationHelper.init(presentationId: self.presentation.id)
        uploadHelper.delegate = self
        uploadHelper.completionHandler = {
            (success, message) in
            
            weak var weakSelf = self
            
            SVProgressHUD.dismiss()
            
            if success {
                // after upload successful, we need to send design file to cloud -> cloud will send it to displayer
                weakSelf?.processSendDesignFileToCloud()
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: weakSelf!)
            }
        }
        SVProgressHUD.show(withStatus: localizedString(key: "common_sending"))
        uploadHelper.processUploadPresentation()
    }
    
    fileprivate func processSendDesignFileToCloud() {
        // call API Control Device to Play to show this presentation to those devices
        let designFileURL = DesignFileHelper.getDesignFileUrlByPresentationId(self.presentation.id)
        
        guard let presentation = DesignFileHelper.getPresentationFromDesignFile(fileURL: designFileURL),
            let contentData = DesignFileHelper.getDesignFileStringFromURL(designFileURL: designFileURL) else {
                
                dLog(message: "can't load design file at path \(designFileURL.path)")
                SVProgressHUD.dismiss()
                Utility.showAlertWithErrorMessage(message: localizedString(key: "common_error_message"), controller: self)
                return
        }
        
        NetworkManager.shared.controlDeviceToPlay(pinCodeList: self.pinCodeJsonString, contentId: presentation.id, contentType: ContentType.presentation.name(), contentName: presentation.name, contentData: contentData, token: Utility.getToken()) {
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

// MARK: - UIScrollViewDelegate + Process

extension PresentationEditorViewController: UIScrollViewDelegate {
    /*************************
     ** UIScrollViewDelegate *
     *************************/
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    /*************************
     ******** Process ********
     *************************/
    func configScrollViewToZoomInOut() {
        self.scrollView.minimumZoomScale = kMinimumZoomScale
        self.scrollView.maximumZoomScale = kMaximumZoomScale
        self.scrollView.delegate = self
        
        // handle double tap on scrollview to zoom
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap(gesture:)))
        gesture.numberOfTapsRequired = 2
        self.contentView.addGestureRecognizer(gesture)
    }
    
    func handleDoubleTap(gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            let location = gesture.location(in: self.contentView)
            let rect = zoomRectForScrollView(scrollView: scrollView, scale: kDoubleTapZoomScale, center: location)
            scrollView.zoom(to: rect, animated: true)
        }
        
    }
    
    func zoomRectForScrollView(scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = CGRect.init()
        
        // The zoom rect is in the content view's coordinates.
        // At a zoom scale of 1.0, it would be the size of the
        // imageScrollView's bounds.
        // As the zoom scale decreases, so more content is visible,
        // the size of the rect grows.
        zoomRect.size.height = scrollView.frame.size.height / scale
        zoomRect.size.width  = scrollView.frame.size.width  / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
}

// MARK: - SlideMenuControllerDelegate

extension PresentationEditorViewController: SlideMenuControllerDelegate {
    
    func leftWillOpen() {
//        dLog(message: "SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
//        dLog(message: "SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
//        dLog(message: "SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
//        dLog(message: "SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
//        dLog(message: "SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
//        dLog(message: "SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
//        dLog(message: "SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
//        dLog(message: "SlideMenuControllerDelegate: rightDidClose")
    }
}

// MARK: - PresentationEditorRightMenuViewControllerDelegate

extension PresentationEditorViewController: PresentationEditorRightMenuViewControllerDelegate {
    
    func handleChooseMediaWithRegion(region: Region) {
        // close right menu
        slideMenuController()?.toggleRight()
        
        guard let media = region.objects?[0] else {
            return
        }
        
        // zoom to region
        zoomAndDraw(x: media.x, y: media.y, width: media.width, height: media.height, region: region)
        
        selectedRegion = region
    }
    
    fileprivate func zoomAndDraw(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, region: Region) {
        let rect = CGRect.init(x: getValueMapWithDisplayRatio(value: x),
                               y: getValueMapWithDisplayRatio(value: y),
                               width: getValueMapWithDisplayRatio(value: width),
                               height: getValueMapWithDisplayRatio(value: height))
        // draw
        removePreviousRectangle()
        drawRectangle(rect: rect, region: region)
        
        // zoom
//        let location = CGPoint.init(x: getValueMapWithDisplayRatio(value:x), y: getValueMapWithDisplayRatio(value:y))
//        let rect = zoomRectForScrollView(scrollView: scrollView, scale: 4.0, center: location)
        scrollView.zoom(to: rect, animated: true)
    }
    
    fileprivate func drawRectangle(rect: CGRect, region: Region) {
//        let view = self.view.viewWithTag(tag)
//        view?.layer.borderColor = kRightMenuBorderColor.cgColor
//        view?.layer.borderWidth = kRightMenuBorderWidth
//        
//        previousViewDrawed = view
        
        guard let media = region.objects?[0] else {
            dLog(message: "can't get Media object from regionId = \(region.id)")
            return
        }
        
        let image = UIImage.makeRectangleImage(size: rect.size)
        let imageView = UIImageView.init(frame: rect)
        imageView.image = image
        
        // make rotation with root "top left"
        Utility.setAnchorPoint(anchorPoint: CGPoint.init(x: 0, y: 0), view: imageView)
        imageView.transform = imageView.transform.rotated(by: CGFloat(media.rotate.degreesToRadians))
        
        self.displayView.addSubview(imageView)
        
        selectedViewDrawed = imageView
    }
    
    fileprivate func removePreviousRectangle() {
        if selectedViewDrawed == nil {
            return
        }
        
        selectedViewDrawed?.removeFromSuperview()
        selectedViewDrawed = nil
        
        selectedRegion = nil
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PresentationEditorViewController: UIGestureRecognizerDelegate {
    
    @objc func gestureRecognizer(_: UIGestureRecognizer,  shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - EditImageViewControllerDelegate

extension PresentationEditorViewController: EditImageViewControllerDelegate {
    
    func handleUpdateLocalImage(newImage: UIImage, region: Region?, editImageType: EditImageType) {
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        // save new image to tmp folder
        guard let data = UIImagePNGRepresentation(newImage) else {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self)
            return
        }
        
        let newLocalImageId = UUID().uuidString
        let newLocalImageURL = getTmpFolderPath().appendingPathComponent(newLocalImageId + Dir.cameraRollImageExtension)
        
        do {
            try data.write(to: newLocalImageURL)
        } catch {
            dLog(message: error.localizedDescription)
            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self)
            return
        }
        
        switch editImageType {
            
        case .normal:
            // handle show new image on display view
            if let imageView = self.view.viewWithTag(Int((region?.id)!)!) as? UIImageView {
                imageView.image = newImage
            } else {
                Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self)
            }
            
            // update design file
            guard let newLocalImageMd5 = Data.md5File(url: newLocalImageURL)?.md5String() else {
                dLog(message: "Can't generate md5 for Local Image at path \(newLocalImageURL)")
                return
            }
            
            DesignFileHelper.updateLocalImageInfo(designFileUrl: getTmpDesignFile(),
                                                  newLocalImageId: newLocalImageId,
                                                  newLocalImageMd5: newLocalImageMd5,
                                                  region: region!)
            break
            
        case .background:
            // handle show new bgImage
            self.bgImageView.image = newImage
            
            // update design file
            guard let newLocalImageMd5 = Data.md5File(url: newLocalImageURL)?.md5String() else {
                dLog(message: "Can't generate md5 for Local Image at path \(newLocalImageURL)")
                return
            }
            
            DesignFileHelper.updateBgImageInfo(designFileUrl: getTmpDesignFile(),
                                               newLocalImageId: newLocalImageId,
                                               newLocalImageMd5: newLocalImageMd5)
            
            break
        }
    }
    
    func handleUpdateImageFromCloud(assetImage: AssetDetail, region: Region?) {
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        // download asset image from cloud to tmp folder
        let newLocalImageURL = getTmpFolderPath().appendingPathComponent(assetImage.id + assetImage.fileType)
        
        SVProgressHUD.show()
        
        NetworkManager.shared.downloadAssetFromAssetListInCloud(fileURL: newLocalImageURL, assetDetail: assetImage, token: Utility.getToken(), downloadProgress: {
            (progress) in
            
        }) { [weak self] (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                // handle show new image on display view
                if let imageView = self?.view.viewWithTag(Int((region?.id)!)!) as? UIImageView {
                    imageView.image = UIImage.init(contentsOfFile: newLocalImageURL.path)
                } else {
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self!)
                }
                
                // update design file
                guard let newLocalImageMd5 = Data.md5File(url: newLocalImageURL)?.md5String() else {
                    dLog(message: "Can't generate md5 for Local Image at path \(newLocalImageURL)")
                    return
                }
                
                DesignFileHelper.updateLocalImageInfo(designFileUrl: (self?.getTmpDesignFile())!,
                                                      newLocalImageId: assetImage.id,
                                                      newLocalImageMd5: newLocalImageMd5,
                                                      region: region!)
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
}

// MARK: - EditWebpageViewControllerDelegate

extension PresentationEditorViewController: EditWebpageViewControllerDelegate {
    
    func handleUpdateWebpageCompleted(newWebpageUrl: String, region: Region) {
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        // handle show new webpage on display view
        if let webView = self.view.viewWithTag(Int(region.id)!) as? UIWebView {
            webView.loadRequest(URLRequest.init(url: URL.init(string: newWebpageUrl)!))
        } else {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_webpage_error"), controller: self)
        }
        
        // update design file
        DesignFileHelper.updateWebpageInfo(designFileUrl: getTmpDesignFile(), newWebpageUrl: newWebpageUrl, region: region)
    }
}

// MARK: - EditVideoViewControllerDelegate

extension PresentationEditorViewController: EditVideoViewControllerDelegate {
    
    func handleUpdateVideoFromCloud(assetDetail: AssetDetail, region: Region) {
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        let saveVideoToPath = getTmpFolderPath().appendingPathComponent(assetDetail.id + assetDetail.fileType)
        
        SVProgressHUD.show()
        
        NetworkManager.shared.downloadAssetFromAssetListInCloud(fileURL: saveVideoToPath, assetDetail: assetDetail, token: Utility.getToken(), downloadProgress: {
            (progress) in
            
            dLog(message:"downloading video with progress = \(progress)")
            
        }) { [weak self] (success, message) in
            
            SVProgressHUD.dismiss()
            
            if success {
                // generate video thumbnail from downloaded video
                guard let image = DesignFileHelper.thumbnailForLocalVideoAtURL(url: saveVideoToPath) else {
                    dLog(message: "can't load video thumbnail with url: " + saveVideoToPath.path)
                    return
                }
                
                // update new local video thumbnail
                if let imageView = self?.view.viewWithTag(Int(region.id)!) as? UIImageView {
                    imageView.image = image
                } else {
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self!)
                    return
                }
                
                // update new local video icon
                if let iconImageView = self?.view.viewWithTag(Int(region.id)! + 1) as? UIImageView {
                    iconImageView.image = UIImage.init(named: "icon_video")
                } else {
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self!)
                    return
                }
                
                // update local video Info on Presentation Design File
                guard let newLocalVideoMd5String = Data.md5File(url: saveVideoToPath)?.md5String() else {
                    dLog(message: "Can't generate md5 for Local Video at path \(saveVideoToPath)")
                    return
                }
                
                DesignFileHelper.updateLocalVideoInfo(designFileUrl: (self?.getTmpDesignFile())!,
                                                      newLocalVideoId: assetDetail.id,
                                                      newLocalVideoMd5: newLocalVideoMd5String,
                                                      region: region)
            } else {
                Utility.showAlertWithErrorMessage(message: message, controller: self!)
            }
        }
    }
    
    func handleUpdateLocalVideo(newLocalVideoURL: URL, newLocalVideoThumbnail: UIImage, region: Region) {
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        // save new local video to tmp folder
        let newVideoId = UUID().uuidString
        let saveVideoToPath = getTmpFolderPath().appendingPathComponent(newVideoId + Dir.cameraRollVideoExtension)
        DesignFileHelper.saveVideoAtAssetURL(videoURL: newLocalVideoURL, toFileURL: saveVideoToPath) {
            (success) in
            weak var weakSelf = self
            
            if success {
                // update new local video thumbnail
                if let imageView = self.view.viewWithTag(Int(region.id)!) as? UIImageView {
                    imageView.image = newLocalVideoThumbnail
                } else {
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self)
                    return
                }
                
                // update new local video icon
                if let iconImageView = self.view.viewWithTag(Int(region.id)! + 1) as? UIImageView {
                    iconImageView.image = UIImage.init(named: "icon_video")
                } else {
                    Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self)
                    return
                }

                // update local video Info on Presentation Design File
                guard let newLocalVideoMd5String = Data.md5File(url: saveVideoToPath)?.md5String() else {
                    dLog(message: "Can't generate md5 for Local Video at path \(saveVideoToPath)")
                    return
                }
                
                DesignFileHelper.updateLocalVideoInfo(designFileUrl: (weakSelf?.getTmpDesignFile())!,
                                                newLocalVideoId: newVideoId,
                                                newLocalVideoMd5: newLocalVideoMd5String,
                                                region: region)
            } else {
                dLog(message: "save local video from camera roll failed!!")
            }
        }
    }
    
    func handleUpdateYoutube(newYoutubeUrl: String, newYoutubeThumbnail: UIImage, region: Region) {
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        // update youtube url on Presentation Design File
        DesignFileHelper.updateYoutubeVideoInfo(designFileUrl: getTmpDesignFile(), newYoutubeUrl: newYoutubeUrl, region: region)
        
        // update new youtube thumbnail
        if let imageView = self.view.viewWithTag(Int(region.id)!) as? UIImageView {
            imageView.image = newYoutubeThumbnail
        } else {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self)
            return
        }
        
        // update new youtube video icon
        if let iconImageView = self.view.viewWithTag(Int(region.id)! + 1) as? UIImageView {
            iconImageView.image = UIImage.init(named: "icon_youtube")
        } else {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_image_error"), controller: self)
            return
        }
    }
}

// MARK: - EditTextViewControllerDelegate

extension PresentationEditorViewController: EditTextViewControllerDelegate {
    
    func handleUpdateText(newText: Text, region: Region) {
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        // update design file
        DesignFileHelper.updateTextInfo(designFileUrl: getTmpDesignFile(), newText: newText, region: region)
        
        // update UI
        if let textLabel = self.view.viewWithTag(Int(region.id)!) as? UILabel {
            textLabel.text = newText.text
            textLabel.font = UIFont.init(name: newText.fontName, size: getValueMapWithDisplayRatio(value:newText.fontSize))
            textLabel.textColor = UIColor.init(hexString: newText.fontColor)
            
            // setup fontStyle
            setupFontStyle(textLabel: textLabel, text: newText)
        } else {
            Utility.showAlertWithErrorMessage(message: localizedString(key: "presentation_editor_message_update_text_error"), controller: self)
        }
        
        // update text for right menu
        delegate?.handleReloadRightMenu!()
    }
}

// MARK: - EditShapeViewControllerDelegate

extension PresentationEditorViewController: EditShapeViewControllerDelegate {
    
    func handleUpdateFrame(newFrame: Frame, region: Region) {
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        // update design file
        DesignFileHelper.updateFrameInfo(designFileUrl: getTmpDesignFile(), newFrame: newFrame, region: region)
        
        // #warning continue from here, bug when edit shape -> tap on presentation -> crash (because layer is removed)
        // update UI - remove old shape and add new one
        for layer in self.shapeList {
            if layer.zPosition == CGFloat(region.zOrder) {
                updateShapeLayer(layer, with: region)
                break
            }
        }
    }
}

// MARK: - UploadPresentationHelperDelegate

extension PresentationEditorViewController: UploadPresentationHelperDelegate {
    
    func handleAfterUpdatePresentationId(witOldPresentationId oldPresentationId: String, andNewPresentationId newPresentationId: String) {
        folderName = newPresentationId
        currentPresentationId = newPresentationId
        self.presentation.id = newPresentationId
        loadLocalPresentationData()
    }
}

// MARK: - CloudDeviceListViewControllerDelegate

extension PresentationEditorViewController: CloudDeviceListViewControllerDelegate {
    
    func handleSendPresentation(pinCodeJsonString: String) {
        self.pinCodeJsonString = pinCodeJsonString
        processSendPresentationToCloud()
    }
}

// MARK: CommonColorPickerViewControllerDelegate

extension PresentationEditorViewController: CommonColorPickerViewControllerDelegate {
    
    func handleChangeColor(color: UIColor, type: SelectColorType) {
        // update bg color
        // If tmpFolder not exist -> create & copy design file to tmp folder
        checkAndCreateTmpFolderUnlessExist()
        
        // update design file
        DesignFileHelper.updateBgImageInfo(designFileUrl: getTmpDesignFile(), newColor: color)
        
        // update Bg Color
        self.displayView.backgroundColor = color
    }
}
