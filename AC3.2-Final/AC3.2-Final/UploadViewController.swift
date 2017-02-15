//
//  uploadViewController.swift
//  AC3.2-Final
//
//  Created by Marcel Chaucer on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    @IBOutlet weak var navigationTitle: UINavigationBar!
    
    @IBOutlet weak var imageToUpload: UIImageView!
    @IBOutlet weak var commentSection: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Tapping the imageview will bring up an image picker
        self.imageToUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImage)))
        
        //Thin border around textview
        self.commentSection.layer.borderWidth = 1.0
        self.commentSection.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    // Handler Function for picking profile pic
    func pickImage() {
        let picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
        picker.delegate = self
    }
    
    // MARK: - Image Picker Delegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imageToUpload.contentMode = .scaleAspectFit
        self.imageToUpload.image = info["UIImagePickerControllerOriginalImage"] as! UIImage?
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        //Must pick an image if you want to upload
        if self.imageToUpload.image == #imageLiteral(resourceName: "camera_icon") {
            let alert = UIAlertController(title: "Oh no", message: "Please Pick An Image To Upload", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        //Our references
        let storageRef = FIRStorage.storage().reference()
        let databaseRef = FIRDatabase.database().reference()
        let linkRef = databaseRef.childByAutoId()
        
        let spaceRef = storageRef.child("images/\(linkRef.key)")
        let image = imageToUpload.image
        let jpeg = UIImageJPEGRepresentation(image!, 0.5)
        
        //This will allow us to see preview of image in storage
        let metadata = FIRStorageMetadata()
        metadata.cacheControl = "public, max-age=300"
        metadata.contentType = "image/jpeg"
        
        let task = spaceRef.put(jpeg!, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                print("put error")
                return
            }
        }
        //Information being sent up to Database
        let values = ["comment" : self.commentSection.text,
                      "userId": FIRAuth.auth()?.currentUser?.uid
        ]
        databaseRef.child("posts/\(linkRef.key)").setValue(values)
        
        let _ = task.observe(.progress) { (snapshot) in
            let progress = Float((snapshot.progress?.fractionCompleted)!)
            if progress == 1.0 {
                let alert = UIAlertController(title: "Complete!", message: "Upload Complete!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
