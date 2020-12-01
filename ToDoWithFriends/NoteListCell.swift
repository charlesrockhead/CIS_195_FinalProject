//
//  NoteListCell.swift
//  Today
//


import UIKit
import Firebase
import FirebaseDatabase

protocol NoteListDelegate: class {
    func didAddItem(title: String)
}

class NoteListCell: UITableViewCell {
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var noteLabel: UITextField!
    
    var delegate: NoteListDelegate?
    var data: NoteItem?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleChecked)))
        checkImageView.isUserInteractionEnabled = true
        noteLabel.isEnabled = true
    }
    
    @objc func toggleChecked() {
        if data?.done == true {
            data?.done = false
            checkImageView.image = UIImage(named: "unchecked")
        } else {
            data?.done = true
            checkImageView.image = UIImage(named: "checked")
        }
        
        
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let noteId = data?.id else { return }
        Database.database().reference()
            .child("Notes")
            .child(userId)
            .child(noteId)
            .child("done").setValue(data?.done ?? false)
    }
    
    func setData(_ data: NoteItem) {
        self.data = data
        if data.id == "add_new_item" {
            noteLabel.isEnabled = true
            noteLabel.placeholder = "New note"
            noteLabel.becomeFirstResponder()
            noteLabel.delegate = self
        } else {
            noteLabel.isEnabled = false
        }
        if data.done {
            checkImageView.image = UIImage(named: "checked")
        } else {
            checkImageView.image = UIImage(named: "unchecked")
        }
        noteLabel.text = data.title
    }
}


extension NoteListCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // end input new note titel
        delegate?.didAddItem(title: textField.text!)
        return false
    }
}



class NoteItem {
    var id: String?
    var done = false
    var title: String?
    var createdAt: Double = 0
    
    init(title: String) {
        self.title = title
    }
    init(rawData: AnyObject) {
        id = rawData["id"] as? String
        done = rawData["done"] as? Bool ?? false
        title = rawData["title"] as? String
        createdAt = rawData["createdAt"] as? Double ?? 0
    }
}
