//
//  ControllerManager.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 24/04/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

class ControllerManager: NSObject {
    // go to Dashboard screen
    static func goToDashboardScreen(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardViewController")
        controller.present(dashboardVC, animated: true, completion: nil)
    }

    // go to Login screen
    static func goToLoginScreen(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        controller.present(loginVC, animated: true, completion: nil)
    }
    
    // go to Common Selection screen
    static func goToCommonSelectionScreen(selectionList: NSArray, currentSelection: Int, currentType: SelectionType, title: String, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectionVC = storyboard.instantiateViewController(withIdentifier: "CommonSelectionViewController") as? CommonSelectionViewController
        selectionVC?.selectionList = selectionList as NSArray
        selectionVC?.currentSelection = currentSelection
        selectionVC?.currentType = currentType
        selectionVC?.title = title
        selectionVC?.delegate = controller as? CommonSelectionViewControllerDelegate
        controller.navigationController?.pushViewController(selectionVC!, animated: true)
    }
    
    // go to Color Picker screen
    static func goToColorPickerScreen(currentColor: UIColor, type: SelectColorType, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let colorPickerVC = storyboard.instantiateViewController(withIdentifier: "CommonColorPickerViewController") as? CommonColorPickerViewController
        colorPickerVC?.currentColor = currentColor
        colorPickerVC?.currentSelectColorType = type
        colorPickerVC?.delegate = controller as? CommonColorPickerViewControllerDelegate
        controller.navigationController?.pushViewController(colorPickerVC!, animated: true)
    }
    
    // go to Choose Alignment screen
    static func goToChooseAlignmentScreen(currentSelectedButtonTag: Int, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alignmentVC = storyboard.instantiateViewController(withIdentifier: "ChooseAlignmentController") as? ChooseAlignmentController
        alignmentVC?.currentSelectedButtonTag = currentSelectedButtonTag
        alignmentVC?.delegate = controller as? ChooseAlignmentControllerDelegate
        controller.navigationController?.pushViewController(alignmentVC!, animated: true)
    }
    
    // go to Cloud Device List screen with instantMessage
    static func goToCloudDeviceListScreen(currentDeviceListType: DeviceListType, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cloudDeviceVC = storyboard.instantiateViewController(withIdentifier: "CloudDeviceListViewController") as? CloudDeviceListViewController
        cloudDeviceVC?.currentDeviceListType = currentDeviceListType
        cloudDeviceVC?.delegate = controller as? CloudDeviceListViewControllerDelegate
        controller.navigationController?.pushViewController(cloudDeviceVC!, animated: true)
    }
    
    // go to Local Device List screen with instantMessage
    static func goToLocalDeviceListScreen(instantMessage: InstantMessage, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let localDeviceVC = storyboard.instantiateViewController(withIdentifier: "LocalDeviceListViewController") as? LocalDeviceListViewController
        localDeviceVC?.instantMessage = instantMessage
        localDeviceVC?.currentDeviceListType = .instantMessage
        controller.navigationController?.pushViewController(localDeviceVC!, animated: true)
    }
    
    // go to local Device List screen with presentation
    static func goToLocalDeviceListScreen(presentationId: String, folderName: String, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let localDeviceVC = storyboard.instantiateViewController(withIdentifier: "LocalDeviceListViewController") as? LocalDeviceListViewController
        localDeviceVC?.presentationId = presentationId
        localDeviceVC?.folderName = folderName
        localDeviceVC?.currentDeviceListType = .presentation
        controller.navigationController?.pushViewController(localDeviceVC!, animated: true)
    }
    
    // go to local Device List screen with PlayList
    static func goToLocalDeviceListScreen(playList: PlayList, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let localDeviceVC = storyboard.instantiateViewController(withIdentifier: "LocalDeviceListViewController") as? LocalDeviceListViewController
        localDeviceVC?.playList = playList
        localDeviceVC?.currentDeviceListType = .playList
        controller.navigationController?.pushViewController(localDeviceVC!, animated: true)
    }
    
    // go to local Device List screen with RealTimeSchedule
    static func goToLocalDeviceListScreen(realTimeSchedule: RealTimeSchedule, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let localDeviceVC = storyboard.instantiateViewController(withIdentifier: "LocalDeviceListViewController") as? LocalDeviceListViewController
        localDeviceVC?.realTimeSchedule = realTimeSchedule
        localDeviceVC?.currentDeviceListType = .realTimeSchedule
        controller.navigationController?.pushViewController(localDeviceVC!, animated: true)
    }
    
    // go to local Device List screen with WeeklySchedule
    static func goToLocalDeviceListScreen(weeklySchedule: WeeklySchedule, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let localDeviceVC = storyboard.instantiateViewController(withIdentifier: "LocalDeviceListViewController") as? LocalDeviceListViewController
        localDeviceVC?.weeklySchedule = weeklySchedule
        localDeviceVC?.currentDeviceListType = .weeklySchedule
        controller.navigationController?.pushViewController(localDeviceVC!, animated: true)
    }
    
    // go to Presentation Editor screen
    static func goToPresentationEditorScreen(presentationId: String, presentationFolderName: String, isComeFromTemplate: Bool, isComeFromPresentationListScreen: Bool, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // create PresentationEditorViewController
        let presentationEditorVC = storyboard.instantiateViewController(withIdentifier: "PresentationEditorViewController") as? PresentationEditorViewController
        presentationEditorVC?.currentPresentationId = presentationId
        presentationEditorVC?.isComeFromTemplate = isComeFromTemplate
        presentationEditorVC?.folderName = presentationFolderName
        presentationEditorVC?.isComeFromPresentationListScreen = isComeFromPresentationListScreen
        
        // create PresentationEditorRightMenuViewController
        let rightMenuVC = storyboard.instantiateViewController(withIdentifier: "PresentationEditorRightMenuViewController") as? PresentationEditorRightMenuViewController
        rightMenuVC?.delegate = presentationEditorVC
        rightMenuVC?.currentPresentationId = presentationId
        rightMenuVC?.folderName = presentationFolderName
        rightMenuVC?.isComeFromTemplate = isComeFromTemplate
        
        presentationEditorVC?.delegate = rightMenuVC
        
        // create slide menu controller
        let slideMenuController = SlideMenuController(mainViewController: presentationEditorVC!, rightMenuViewController: rightMenuVC!)
        slideMenuController.delegate = presentationEditorVC
        
        presentationEditorVC?.slideMenuDelegate = slideMenuController
        
        controller.navigationController?.pushViewController(slideMenuController, animated: true)
    }
    
    // go to edit image screen
    static func goToEditImageScreen(region: Region?, image: UIImage, editImageType: EditImageType, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editImageVC = storyboard.instantiateViewController(withIdentifier: "EditImageViewController") as? EditImageViewController
        editImageVC?.region = region
        editImageVC?.image = image
        editImageVC?.currentEditImageType = editImageType
        editImageVC?.delegate = controller as? EditImageViewControllerDelegate
        controller.navigationController?.pushViewController(editImageVC!, animated: true)
    }
    
    // go to edit webpage screen
    static func goToEditWebpageScreen(region: Region, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editWebpageVC = storyboard.instantiateViewController(withIdentifier: "EditWebpageViewController") as? EditWebpageViewController
        editWebpageVC?.region = region
        editWebpageVC?.delegate = controller as? EditWebpageViewControllerDelegate
        controller.navigationController?.pushViewController(editWebpageVC!, animated: true)
    }
    
    // go to edit video screen
    static func goToEditVideoScreen(region: Region, image: UIImage, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVideoVC = storyboard.instantiateViewController(withIdentifier: "EditVideoViewController") as? EditVideoViewController
        editVideoVC?.region = region
        editVideoVC?.image = image
        editVideoVC?.delegate = controller as? EditVideoViewControllerDelegate
        controller.navigationController?.pushViewController(editVideoVC!, animated: true)
    }
    
    // go to edit text screen
    static func goToEditTextScreen(region: Region, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editTextVC = storyboard.instantiateViewController(withIdentifier: "EditTextViewController") as? EditTextViewController
        editTextVC?.region = region
        editTextVC?.delegate = controller as? EditTextViewControllerDelegate
        controller.navigationController?.pushViewController(editTextVC!, animated: true)
    }
    
    // go to edit shape screen
    static func goToEditShapeScreen(region: Region, frame: Frame, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editShapeVC = storyboard.instantiateViewController(withIdentifier: "EditShapeViewController") as? EditShapeViewController
        editShapeVC?.region = region
        editShapeVC?.frame = frame
        editShapeVC?.delegate = controller as? EditShapeViewControllerDelegate
        controller.navigationController?.pushViewController(editShapeVC!, animated: true)
    }
    
    // go to Template screen
    static func goToTemplateScreen(isComeFromPresentationListScreen: Bool, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let templateVC = storyboard.instantiateViewController(withIdentifier: "TemplateCollectionViewController") as? TemplateCollectionViewController
//        templateVC?.isComeFromPresentationListScreen = isComeFromPresentationListScreen
        controller.navigationController?.pushViewController(templateVC!, animated: true)
    }
    
    // go to Template screen
    static func goToPlayListDetailScreen(playList: PlayList, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playListDetailVC = storyboard.instantiateViewController(withIdentifier: "PlayListDetailViewController") as? PlayListDetailViewController
        playListDetailVC?.playList = playList
        controller.navigationController?.pushViewController(playListDetailVC!, animated: true)
    }
    
    // go to Presentation List screen
    static func goToPresentationListScreen(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let presentationListVC = storyboard.instantiateViewController(withIdentifier: "PresentationListViewController") as? PresentationListViewController
        presentationListVC?.shouldHandleAddPresentation = true
        presentationListVC?.delegate = controller as? PresentationListViewControllerDelegate
        controller.navigationController?.pushViewController(presentationListVC!, animated: true)
    }
    
    // go to RealTime Schedule Detail screen
    static func goToRealTimeDetailScreen(realTimeSchedule: RealTimeSchedule, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let realTimeDetailVC = storyboard.instantiateViewController(withIdentifier: "ScheduleRealTimeDetailViewController") as? ScheduleRealTimeDetailViewController
        realTimeDetailVC?.realTimeSchedule = realTimeSchedule
        controller.navigationController?.pushViewController(realTimeDetailVC!, animated: true)
    }
    
    // go to Weekly Schedule Detail screen
    static func goToWeeklyDetailScreen(weeklySchedule: WeeklySchedule, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let weeklyDetailVC = storyboard.instantiateViewController(withIdentifier: "ScheduleWeeklyDetailViewController") as? ScheduleWeeklyDetailViewController
        weeklyDetailVC?.weeklySchedule = weeklySchedule
        controller.navigationController?.pushViewController(weeklyDetailVC!, animated: true)
    }
    
    // show RealTime Event screen
    static func showRealTimeEventScreen(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let realTimeEventVC = storyboard.instantiateViewController(withIdentifier: "ScheduleRealTimeEventViewController") as? ScheduleRealTimeEventViewController
        realTimeEventVC?.delegate = controller as? ScheduleRealTimeEventViewControllerDelegate
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: realTimeEventVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            realTimeEventVC?.initController()
        })
    }
    
    // show RealTime Event screen
    static func showRealTimeEventScreen(startTime: Date, endTime: Date, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let realTimeEventVC = storyboard.instantiateViewController(withIdentifier: "ScheduleRealTimeEventViewController") as? ScheduleRealTimeEventViewController
        realTimeEventVC?.delegate = controller as? ScheduleRealTimeEventViewControllerDelegate

        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: realTimeEventVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            realTimeEventVC?.initControllerWithStartDate(startTime, endDate: endTime)
        })
    }
    
    // show RealTime Event screen
    static func showRealTimeEventScreen(realTimeEvent: RealTimeSchedulePresentation, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let realTimeEventVC = storyboard.instantiateViewController(withIdentifier: "ScheduleRealTimeEventViewController") as? ScheduleRealTimeEventViewController
        realTimeEventVC?.delegate = controller as? ScheduleRealTimeEventViewControllerDelegate

        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: realTimeEventVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            realTimeEventVC?.initControllerWithRealTimeEvent(realTimeEvent)
        })
        
    }

    // show Weekly Event screen
    static func showWeeklyEventScreen(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let weeklyEventVC = storyboard.instantiateViewController(withIdentifier: "ScheduleWeeklyEventViewController") as? ScheduleWeeklyEventViewController
        weeklyEventVC?.delegate = controller as? ScheduleWeeklyEventViewControllerDelegate
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: weeklyEventVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            weeklyEventVC?.initController()
        })
    }
    
    // show Weekly Event screen
    static func showWeeklyEventScreen(startTime: Date, endTime: Date, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let weeklyEventVC = storyboard.instantiateViewController(withIdentifier: "ScheduleWeeklyEventViewController") as? ScheduleWeeklyEventViewController
        weeklyEventVC?.delegate = controller as? ScheduleWeeklyEventViewControllerDelegate
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: weeklyEventVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            weeklyEventVC?.initControllerWithStartDate(startTime, endDate: endTime)
        })
    }

    // show Weekly Event screen
    static func showWeeklyEventScreen(weeklyEvent: WeeklySchedulePresentation, controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let weeklyEventVC = storyboard.instantiateViewController(withIdentifier: "ScheduleWeeklyEventViewController") as? ScheduleWeeklyEventViewController
        weeklyEventVC?.delegate = controller as? ScheduleWeeklyEventViewControllerDelegate
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: weeklyEventVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            weeklyEventVC?.initControllerWithWeeklyEvent(weeklyEvent)
        })
        
    }
    
    // go to Asset List screen
    static func goToAssetListScreen(controller: UIViewController, assetType: AssetType) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let assetSelectionVC = storyboard.instantiateViewController(withIdentifier: "AssetSelectionCollectionViewController") as? AssetSelectionCollectionViewController
        assetSelectionVC?.delegate = controller as? AssetSelectionCollectionViewControllerDelegate
        assetSelectionVC?.assetType = assetType
        controller.navigationController?.pushViewController(assetSelectionVC!, animated: true)
    }

    // show Template Filter screen
    static func showTemplateFilterScreen(controller: UIViewController, currentTemplateFilter : TemplateFilter) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let templateFilterVC = storyboard.instantiateViewController(withIdentifier: "TemplateFilterViewController") as? TemplateFilterViewController
        templateFilterVC?.delegate = controller as? TemplateFilterViewControllerDelegate
        templateFilterVC?.templateFilter = currentTemplateFilter
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: templateFilterVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            templateFilterVC?.initController()
        })
    }
    
    // show CommonGroupList screen
    static func showCommonGroupListScreen(controller: UIViewController, selectedGroup: Group) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commonGroupListVC = storyboard.instantiateViewController(withIdentifier: "CommonGroupListViewController") as? CommonGroupListViewController
        commonGroupListVC?.delegate = controller as? CommonGroupListViewControllerDelegate
        commonGroupListVC?.currentGroup = selectedGroup
        
        controller.navigationController?.pushViewController(commonGroupListVC!, animated: true)
    }
    
    // show CommonTagList screen
    static func showCommonTagListScreen(controller: UIViewController, selectedTagIdList: [String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commonTagListVC = storyboard.instantiateViewController(withIdentifier: "CommonTagListViewController") as? CommonTagListViewController
        commonTagListVC?.delegate = controller as? CommonTagListViewControllerDelegate
        commonTagListVC?.currentSelectedTagIdList = selectedTagIdList
        
        controller.navigationController?.pushViewController(commonTagListVC!, animated: true)
    }
    
    // show DatasetAddEdit screen
    static func showDatasetAddEditScreen(controller: UIViewController, dataset: Dataset?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let datasetAddEditVC = storyboard.instantiateViewController(withIdentifier: "DatasetAddEditViewController") as? DatasetAddEditViewController
        datasetAddEditVC?.delegate = controller as? DatasetAddEditViewControllerDelegate
        
        if dataset == nil {
            datasetAddEditVC?.isEditMode = false
        } else {
            datasetAddEditVC?.isEditMode = true
        }
        
        datasetAddEditVC?.dataset = dataset
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: datasetAddEditVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            
        })
    }
    
    // show DatasetRowUpdate screen
    static func showDatasetRowUpdateScreen(controller: UIViewController, dataset: Dataset) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let datasetRowUpdateVC = storyboard.instantiateViewController(withIdentifier: "DatasetRowUpdateViewController") as? DatasetRowUpdateViewController
//        datasetRowUpdateVC?.delegate = controller as? CommonTagListViewControllerDelegate
        datasetRowUpdateVC?.dataset = dataset
        
        controller.navigationController?.pushViewController(datasetRowUpdateVC!, animated: true)
    }
    
    // show AssetList screen
    static func showAssetListScreen(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let assetListVC = storyboard.instantiateViewController(withIdentifier: "AssetCollectionViewController") as? AssetCollectionViewController
        controller.navigationController?.pushViewController(assetListVC!, animated: true)
    }
    
    // show Asset Edit screen
    static func showAssetEditScreen(controller: UIViewController, assetDetail : AssetDetail) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let assetEditVC = storyboard.instantiateViewController(withIdentifier: "AssetEditViewController") as? AssetEditViewController
        assetEditVC?.delegate = controller as? AssetEditViewControllerDelegate
        assetEditVC?.assetDetail = assetDetail
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: assetEditVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            assetEditVC?.initController()
        })
    }
    
    // show Asset Filter screen
    static func showAssetFilterScreen(controller: UIViewController, currentAssetFilter : AssetFilter) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let assetFilterVC = storyboard.instantiateViewController(withIdentifier: "AssetFilterViewController") as? AssetFilterViewController
        assetFilterVC?.delegate = controller as? AssetFilterViewControllerDelegate
        assetFilterVC?.assetFilter = currentAssetFilter
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: assetFilterVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            assetFilterVC?.initController()
        })
    }
    
    // show CommonTypeList screen
    static func showCommonTypeListScreen(controller: UIViewController, selectedTypeList: [String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commonTypeListVC = storyboard.instantiateViewController(withIdentifier: "CommonTypeListViewController") as? CommonTypeListViewController
        commonTypeListVC?.delegate = controller as? CommonTypeListViewControllerDelegate
        commonTypeListVC?.currentSelectedTypeList = selectedTypeList
        
        controller.navigationController?.pushViewController(commonTypeListVC!, animated: true)
    }
    
    // show InstantMessage screen
    static func showInstantMessageScreen(controller: UIViewController, displayEvent: DisplayEvent?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instantMessageVC = storyboard.instantiateViewController(withIdentifier: "InstanceMessageViewController") as? InstanceMessageViewController
//        instantMessageVC?.delegate = controller as? CommonTypeListViewControllerDelegate
        if displayEvent == nil {
            instantMessageVC?.displayEvent = DisplayEvent()
            instantMessageVC?.isEditMode = false
        } else {
            instantMessageVC?.displayEvent = displayEvent!
            instantMessageVC?.isEditMode = true
        }
        
        controller.navigationController?.pushViewController(instantMessageVC!, animated: true)
    }
    
    // show DeviceCurrentPlaying screen
    static func showDeviceCurrentPlayingScreen(controller: UIViewController, device: Device) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deviceCurrentPlayingVC = storyboard.instantiateViewController(withIdentifier: "DeviceCurrentPlayingViewController") as? DeviceCurrentPlayingViewController
        deviceCurrentPlayingVC?.device = device
        
        controller.navigationController?.pushViewController(deviceCurrentPlayingVC!, animated: true)
    }
    
    // show DeviceControl screen
    static func showDeviceControlScreen(controller: UIViewController, device: Device) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deviceControlVC = storyboard.instantiateViewController(withIdentifier: "DeviceControlViewController") as? DeviceControlViewController
        deviceControlVC?.device = device
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: deviceControlVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            deviceControlVC?.initController()
        })
    }
    
    // show CategoryList screen
    static func showCategoryListScreen(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let categoryListVC = storyboard.instantiateViewController(withIdentifier: "GroupViewController") as? GroupViewController
        
        controller.navigationController?.pushViewController(categoryListVC!, animated: true)
    }
    
    // show BarCodeScanner screen
    static func showBarCodeScannerScreen(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let barCodeScannerVC = storyboard.instantiateViewController(withIdentifier: "BarCodeScannerViewController") as? BarCodeScannerViewController
        
        controller.navigationController?.pushViewController(barCodeScannerVC!, animated: true)
    }
    
    // show WifiSetting screen
    static func showWifiSettingScreen(controller: UIViewController, qrCodeString: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let wifiSettingVC = storyboard.instantiateViewController(withIdentifier: "DeviceWifiSettingViewController") as? DeviceWifiSettingViewController
        wifiSettingVC?.qrCodeString = qrCodeString
        
        controller.navigationController?.pushViewController(wifiSettingVC!, animated: true)
    }
    
    // show Device Filter screen
    static func showDeviceFilterScreen(controller: UIViewController, currentDeviceFilter : DeviceFilter) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deviceFilterVC = storyboard.instantiateViewController(withIdentifier: "DeviceFilterViewController") as? DeviceFilterViewController
        deviceFilterVC?.delegate = controller as? DeviceFilterViewControllerDelegate
        deviceFilterVC?.deviceFilter = currentDeviceFilter
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: deviceFilterVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            deviceFilterVC?.initController()
        })
    }
    
    // show Device Setting screen
    static func showDeviceSettingScreen(controller: UIViewController, currentDevice : Device) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let deviceSettingVC = storyboard.instantiateViewController(withIdentifier: "DeviceSettingViewController") as? DeviceSettingViewController
        deviceSettingVC?.delegate = controller as? DeviceSettingViewControllerDelegate
        deviceSettingVC?.device = currentDevice
        
        // create navigation controller
        let navigationVC = UINavigationController.init(rootViewController: deviceSettingVC!)
        
        controller.navigationController?.present(navigationVC, animated: true, completion: {
            deviceSettingVC?.initController()
        })
    }
}
