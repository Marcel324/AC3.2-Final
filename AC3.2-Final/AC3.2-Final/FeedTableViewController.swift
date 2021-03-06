//
//  feedTableTableViewController.swift
//  AC3.2-Final
//
//  Created by Marcel Chaucer on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class FeedTableViewController: UITableViewController {
    var uploads = [Upload]()
    var databaseRef: FIRDatabaseReference!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Where all our data lives
        self.databaseRef = FIRDatabase.database().reference().child("posts")
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Presenting view controller in viewDidLoad was sort of buggy. So doing it here seems to work more consistently.
        if FIRAuth.auth()?.currentUser == nil {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "loginView")
        self.present(controller, animated: false, completion: nil)
        } else {
            
        getUploads()
        }
    }
    
   
    func getUploads() {
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var newUploads: [Upload] = []
            for child in snapshot.children {
                if let snap = child as? FIRDataSnapshot,
                    let valueDict = snap.value as? [String: String] {
                    let upload = Upload(comment: valueDict["comment"]!,
                                        imageURL: snap.key)
                    newUploads.append(upload)
                }
            }
            self.uploads = newUploads
            self.tableView.reloadData()
        })
    }
    
   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uploads.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        let anUpload = uploads[indexPath.row]
        
        //No reusing
        cell.commentLabel.text = nil
        cell.uploadImage.image = nil
        
        //Set cell's properties
        cell.commentLabel.text = anUpload.comment
        
        let storageRef = FIRStorage.storage().reference().child("images/\(anUpload.imageURL!)")
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                // Data for "images/(childautoid)" is returned
                let image = UIImage(data: data!)
                cell.uploadImage.image = image
            }
        }
        
        return cell
    }
}
