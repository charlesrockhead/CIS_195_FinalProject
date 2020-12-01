//
//  Friends.swift
//  Today
//

import UIKit
import FirebaseDatabase
import Firebase

class FriendsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var pendingFriends = [User]()
    var friends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Friends"
        
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
            .child(myId)
            .child("Messages")
            .observe(.value, with: {(snapshot) in
                guard let snapshotValue = snapshot.value as? [String: AnyObject] else { return }
                var pendingFriends = [User]()
                let invitationSenders = Array(snapshotValue.keys)
                for sender in invitationSenders {
                    self.getUserDetail(userId: sender, completion: { user in
                        pendingFriends.append(user)
                        user.isFriend = false
                        
                        if pendingFriends.count == invitationSenders.count {
                            self.pendingFriends = pendingFriends
                            self.tableView.reloadData()
                        }
                    })
                }
            })
        
        Database.database().reference()
            .child("Users")
            .child(myId)
            .child("Friends")
            .observe(.value, with: {(snapshot) in
                guard let snapshotValue = snapshot.value as? [String: AnyObject] else { return }
                let invitationSenders = Array(snapshotValue.keys)
                var friends = [User]()
                for sender in invitationSenders {
                    self.getUserDetail(userId: sender, completion: { user in
                        friends.append(user)
                        user.isFriend = true
                        
                        if friends.count == invitationSenders.count {
                            self.friends = friends
                            self.tableView.reloadData()
                        }
                    })
                }
            })
    }
    
    
    func getUserDetail(userId: String, completion: @escaping((User) -> Void)) {
        Database.database().reference()
            .child("Users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
                guard let snapshotValue = snapshot.value as AnyObject? else { return }
                let user = User(raw: snapshotValue)
                completion(user)
        }
    }
    
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pendingFriends.count
        }
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Pending Invitations"
        }
        
        return "Friends"
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFriendCell", for: indexPath) as! PendingFriendCell
        cell.delegate = self
        if indexPath.section == 0 {
            cell.setData(pendingFriends[indexPath.row])
            cell.accessoryType = .none
        } else {
            cell.setData(friends[indexPath.row])
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    //send selected friend user to Detail View
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.friendId = friends[indexPath.row].id
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension FriendsViewController: FriendCellDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    
    func didAccept(user: User) {
        guard let index = pendingFriends.firstIndex(where: { return $0.id == user.id }) else { return }
        pendingFriends.remove(at: index)
        tableView.reloadData()
    }
}
