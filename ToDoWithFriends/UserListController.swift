//
//  UserListController.swift
//  Today
//

import UIKit
import FirebaseDatabase
import Firebase

class UserListController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var datasource = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Friends"
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    func getData() {
        guard let myId = Auth.auth().currentUser?.uid else { return }
        Database.database().reference()
            .child("Users")
            .observeSingleEvent(of: .value) { [weak self] (snapshot) in
                guard let snapshotValue = snapshot.value as? [String: AnyObject] else { return }
                let rawData = Array(snapshotValue.values)
                let users = rawData.compactMap({ item -> User? in
                    let id = item["userId"] as? String
                    if id == myId {
                        return nil
                    } else {
                        return User(raw: item)
                    }
                })
                self?.datasource = users
                self?.tableView.reloadData()
        }
    }
}

extension UserListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        cell.setData(datasource[indexPath.row])
        return cell
    }
}

class UserListCell: UITableViewCell {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var data: User?
    func setData(_ data: User) {
        self.data = data
        emailLabel.text = data.email
        
        if let myId = Auth.auth().currentUser?.uid {
            if data.invitationSenders.contains(myId) {
                addButton.isEnabled = false
                addButton.setTitle("Sent", for: .normal)
            } else {
                addButton.isEnabled = true
                addButton.setTitle("Add", for: .normal)
            }
        }
    }
    @IBAction func sendFriendRequest() {
        guard let sender = Auth.auth().currentUser?.uid else { return }
        guard let id = data?.id else { return }
        let values: [String: Any] = [
            "sender": sender,
            "createdAt": Date().timeIntervalSince1970
        ]
        Database.database().reference()
            .child("Users")
        .child(id)
        .child("Messages")
        .child(sender)
        .setValue(values)
        
        addButton.isEnabled = false
        addButton.setTitle("Sent", for: .normal)
    }
}


class User {
    var id: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var invitationSenders = [String]()
    var isFriend = false 
    init(raw: AnyObject) {
        id = raw["userId"] as? String
        email = raw["email"] as? String
        firstName = raw["firstName"] as? String
        lastName = raw["lastName"] as? String
        if let messages = raw["Messages"] as? [String: Any] {
            invitationSenders = Array(messages.keys)
        }
        
    }
}

