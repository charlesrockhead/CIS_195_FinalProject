//
//  PendingFriendCell.swift
//  Today
//

import UIKit
import Firebase
import FirebaseDatabase

protocol FriendCellDelegate: class {
    func reloadData()
    func didAccept(user: User)
}

class PendingFriendCell: UITableViewCell {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var accepButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    weak var delegate: FriendCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accepButton.addTarget(self, action: #selector(acceptRequest), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declineRequest), for: .touchUpInside)
    }
    @objc func acceptRequest() {
        guard let myId = Auth.auth().currentUser?.uid else { return }
        guard let sender = data?.id else { return }
        Database.database().reference()
            .child("Users")
            .child(myId)
            .child("Friends")
            .child(sender)
            .setValue(true)
        Database.database().reference()
            .child("Users")
            .child(sender)
            .child("Friends")
            .child(myId)
            .setValue(true)
        
        Database.database().reference()
            .child("Users")
            .child(myId)
            .child("Messages")
            .child(sender)
            .removeValue()
        if let user = data {
            delegate?.didAccept(user: user)
        }
    }
    
    @objc func declineRequest() {
        guard let myId = Auth.auth().currentUser?.uid else { return }
        guard let sender = data?.id else { return }
        Database.database().reference()
            .child("Users")
            .child(myId)
            .child("Messages")
            .child(sender)
            .removeValue()
        delegate?.reloadData()
    }
    
    var data: User?
    func setData(_ data: User) {
        self.data = data
        emailLabel.text = data.email
        
        if data.isFriend {
            accepButton.isHidden = true
            declineButton.isHidden = true
        } else {
            accepButton.isHidden = false
            declineButton.isHidden = false
        }
    }
    
    
}
