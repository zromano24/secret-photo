//
//  AlbumSelectionController.swift
//  secret-photo
//
//  Created by Zach Romano on 11/22/19.
//  Copyright © 2019 Zach Romano. All rights reserved.
//

import UIKit

class AlbumSelectionController: UITableViewController {
    
    var albumNames : [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        albumNames = AlbumRepository.getAllAlbumNames()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete folder
            _ = MediaHandler.deleteFolder(albumName: self.albumNames[indexPath.row])
            self.albumNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editButton = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            // edit folder
            self.performSegue(withIdentifier: "showAlbumSettingsSegue", sender: self.albumNames[indexPath.row])
            
        }
        editButton.backgroundColor = UIColor.lightGray
        
        return [delete, editButton]
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumTableCellReuseIdentifier", for: indexPath)
        
        let albumName = albumNames[indexPath.row]
        let numImagesInAlbum: Int = ImageNameRepository.getNumberOfImagesByAlbum(albumName: albumName)
        
        cell.textLabel?.text = albumName + " (" + String(numImagesInAlbum) + ")"
        
        // set the thumbnail image to the first image in album, or default image
        if (numImagesInAlbum > 0) {
            let thumbnailImageName: String? = ImageNameRepository.getFirstPhotoInAlbum(albumName: albumName)
            let thumbnailImage: UIImage
            if (thumbnailImageName != nil) {
                thumbnailImage = MediaHandler.loadImageFromDiskWith(fileName: thumbnailImageName!)!
            } else {
                thumbnailImage = UIImage(named: "default")!
            }
            cell.imageView?.image = thumbnailImage
        } else {
            cell.imageView?.image = UIImage(named: "default")
        }
        
        // format image
        let itemSize = CGSize.init(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell.imageView?.image!.draw(in: imageRect)
        cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showAlbumSegue") {
            let albumView: AlbumController = segue.destination as! AlbumController
            let indexPath: NSIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
            albumView.albumName = albumNames[indexPath.row]
            
        } else if (segue.identifier == "showAlbumSettingsSegue") {
            let albumName = sender as! String
            let albumSettingsView: AlbumSettingsController = segue.destination as! AlbumSettingsController
            albumSettingsView.albumName = albumName
            
        }
    }
    
    
    @IBAction func createNewAlbumPressed(_ sender: Any) {
        let albumNameInputAlert = UIAlertController(title: "Album Title", message: "Enter a name for your album.", preferredStyle: .alert)
        
        albumNameInputAlert.addTextField { (textField) in
            textField.text = ""
        }
        
        albumNameInputAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak albumNameInputAlert] (_) in
            let textField = albumNameInputAlert?.textFields![0]
        
            if (textField?.text != nil && textField?.text != "") {
                // album name already in use
                if (self.albumNames.contains(textField!.text!)) {
                    let sameNamealert = UIAlertController(title: "Album name already in use!", message: nil, preferredStyle: .alert)
                    sameNamealert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in })
                    self.present(sameNamealert, animated: true)
                    return
                }
                // happy path
                AlbumRepository.saveAlbum(albumName: textField!.text!)
                self.albumNames.append(textField!.text!)
                self.tableView.reloadData()
            } else {
                // album name blank
                let badNamealert = UIAlertController(title: "Album name cannot be blank!", message: nil, preferredStyle: .alert)
                badNamealert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in })
                self.present(badNamealert, animated: true)
            }
            
        }))
        
        self.present(albumNameInputAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumNames.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0;
    }
}
