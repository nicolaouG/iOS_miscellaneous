//
//  AvatarSelectorAlert.swift
//  Eshop
//
//  Created by george on 14/12/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//


import UIKit
import Photos
import PhotosUI


public protocol AvatarSelectorAlertDelegate {
    func avatarImageSelected(_ image: UIImage?)
    func avatarImageRemoved()
}


/**
 Present action sheet alert with options to choose image from camera or photo library. The selected image is saved in userDefaults.
 
 # Sample:
 ```
 let selectPhotoAlert = AvatarSelectorAlert(currentVC: self, sourceView: circularAvatarView, arrowDirection: .up)
 selectPhotoAlert.delegate = self
 present(selectPhotoAlert, animated: true, completion: nil)
 ```
 */
public class AvatarSelectorAlert: UIAlertController {
    public var delegate: AvatarSelectorAlertDelegate?
    private var isNewPhoto: Bool?
    
    enum AttachmentType: String {
        case camera, photoLibrary
    }
    
    public var userDefaultsAvatarKey: String = "MyAvatarKey_userId-ToBeUnique"
    
    var presentingVC: UIViewController?
    var sourceView: UIView?
    var arrowDirection: UIPopoverArrowDirection?
    
    
    public init(currentVC presentingVC: UIViewController, sourceView: UIView? = nil, arrowDirection: UIPopoverArrowDirection? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.presentingVC = presentingVC
        self.sourceView = sourceView
        self.arrowDirection = arrowDirection
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        ipadPopoverSetup()
        alertViewSetup()
    }

    
    private func ipadPopoverSetup() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            popoverPresentationController?.permittedArrowDirections = arrowDirection ?? []
            popoverPresentationController?.sourceView = sourceView ?? view
            if self.arrowDirection == .left {
                popoverPresentationController?.sourceRect = CGRect(x: (sourceView?.bounds.width ?? (view.bounds.midX - 8)) + 8, y: (sourceView?.bounds.height ?? view.bounds.height) / 2, width: 0, height: 0)
            } else if self.arrowDirection == .up {
                popoverPresentationController?.sourceRect = CGRect(x: (sourceView?.bounds.width ?? (view.bounds.midX)) / 2, y: (sourceView?.bounds.height ?? view.bounds.height) + 8, width: 0, height: 0)
            } else { // support .right, .down in the future
                popoverPresentationController?.sourceRect = CGRect(x: (sourceView?.bounds.width ?? (view.bounds.midX - 8)) + 8, y: (sourceView?.bounds.height ?? view.bounds.height) / 2, width: 0, height: 0)
            }
        }
    }
    
    private func alertViewSetup() {
        let cameraIV = #imageLiteral(resourceName: "camera_icon").resizedImageWithinRect(rectSize: CGSize(width: 24, height: 24))
        let photosIV = #imageLiteral(resourceName: "photoLibrary_icon").resizedImageWithinRect(rectSize: CGSize(width: 24, height: 24))

        let cameraAction = UIAlertAction.init(title: NSLocalizedString("Camera", comment: ""), style: UIAlertAction.Style.default, handler: { _ in
            self.authorisationStatus(attachmentTypeEnum: .camera)
        })
        let photosAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: UIAlertAction.Style.default, handler: { response in
            self.authorisationStatus(attachmentTypeEnum: .photoLibrary)
        })
        cameraAction.setValue(cameraIV, forKey: "image")
        photosAction.setValue(photosIV, forKey: "image")
        
        title = NSLocalizedString("Select image from:", comment: "")
        addAction(cameraAction)
        addAction(photosAction)

        /// if an avatar img exists, add option to remove it
        if (UserDefaults.standard.object(forKey: userDefaultsAvatarKey) != nil) {
            let clearAction = UIAlertAction.init(title: NSLocalizedString("Clear", comment: ""), style: .destructive, handler: { _ in
                self.removeAvatar()
            })
            let deleteIV = #imageLiteral(resourceName: "delete_icon").resizedImageWithinRect(rectSize: CGSize(width: 24, height: 22))
            clearAction.setValue(deleteIV, forKey: "image")
            addAction(clearAction)
        }
        
        addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        }))
    }
    
    
    private func showDeniedRestrictedAlert(){
        let alert = UIAlertController(title: "Permission denied or restricted", message: "Enable access manually from settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)}))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            self.goToSettings()}))
        presentingVC?.present(alert, animated: true, completion: nil)
    }
    
    private func authorisationStatus(attachmentTypeEnum: AttachmentType) {
        switch attachmentTypeEnum {
        case .camera:
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch cameraStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
                    guard accessGranted == true else { return }
                    self.presentForSelection(.camera)
                })
            case .restricted, .denied: showDeniedRestrictedAlert()
            case .authorized: presentForSelection(.camera)
            @unknown default: break
            }
            
        case .photoLibrary:
            let photosStatus = PHPhotoLibrary.authorizationStatus()
            switch photosStatus {
            case .notDetermined: // request permission
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized {
                        self.presentForSelection(.photoLibrary)
                    } else {
                        self.showDeniedRestrictedAlert()
                    }
                })
            case .authorized, .limited: presentForSelection(.photoLibrary)
            case .denied, .restricted: showDeniedRestrictedAlert()
            default: break
            }
        }
    }
    
    
    private func goToSettings(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
    
    private func presentForSelection(_ attachmentTypeEnum: AttachmentType) {
        let isCamera = attachmentTypeEnum == .camera
        let source: UIImagePickerController.SourceType = isCamera ? .camera : .photoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            print("\(isCamera ? "Camera" : "Photo library") source is not available")
            return
        }
        
        DispatchQueue.main.async {
            if #available(iOS 14, *), !isCamera {
                var config = PHPickerConfiguration()
                config.filter = PHPickerFilter.images
                config.selectionLimit = 1
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                self.presentingVC?.present(picker, animated: true)
            } else {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = source
                imagePicker.allowsEditing = false
                self.presentingVC?.present(imagePicker, animated: true, completion: nil)
                self.isNewPhoto = isCamera
            }
        }
    }
        
    private func removeAvatar() {
        guard UserDefaults.standard.object(forKey: userDefaultsAvatarKey) != nil else { return }
        UserDefaults.standard.removeObject(forKey: userDefaultsAvatarKey)
        UserDefaults.standard.synchronize()
        delegate?.avatarImageRemoved()
    }
}


// MARK: - PHPickerViewControllerDelegate

@available(iOS 14, *)
extension AvatarSelectorAlert: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        presentingVC?.dismiss(animated: true, completion: nil)
        
        let itemProviders = results.map(\.itemProvider)
        itemProviders.forEach { (itemProvider) in
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let self = self, let image = image as? UIImage {
                            self.saveImageToUserDefaults(image)
                            self.delegate?.avatarImageSelected(image)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - UIImagePickerControllerDelegate

extension AvatarSelectorAlert: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // handle image
        let img = info[.originalImage] as? UIImage ?? info[.editedImage] as? UIImage
        if let image = img {
            saveImageToUserDefaults(image)
        }
        picker.dismiss(animated: true, completion: {
            self.delegate?.avatarImageSelected(img)
            // ask to save it when taken from camera
            if self.isNewPhoto ?? false {
                self.askToSaveCapturedImage(img)
            }
        })
    }
    
    private func saveImageToUserDefaults(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return}
        UserDefaults.standard.set(imageData, forKey: userDefaultsAvatarKey)
    }
    
    // notify when saving failed
    @objc private func imageError(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer){
        if error != nil {
            let alert = UIAlertController(title: NSLocalizedString("Save failed", comment: ""), message: NSLocalizedString("Failed to save image", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            presentingVC?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func askToSaveCapturedImage(_ image: UIImage?) {
        guard let img = image else { return }
        let alert = UIAlertController(title: "Save image", message: "Do you want to save the captured image in your photos album?", preferredStyle: .alert)
        let save = UIAlertAction(title: "Save", style: .default) { _ in
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.imageError), nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        [save, cancel].forEach({ alert.addAction($0) })
        
        presentingVC?.present(alert, animated: true, completion: nil)
    }
}
