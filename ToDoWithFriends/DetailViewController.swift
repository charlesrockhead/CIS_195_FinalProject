//
//  HomeViewController.swift
//  Today
//

import UIKit
import Firebase
import FirebaseDatabase

class DetailViewController: UIViewController {
    
    var friendId: String?  //passed friend's user id from firend's view controller
    
    var list = [FriendsNoteItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        title = "Your Friend's To Do List"
        
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func getData() {
        //guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let userId = friendId else { return }
        Database.database().reference()
            .child("Notes")
            .child(userId).observe(.value, with: {[weak self] (snapshot) in
                guard let dict = snapshot.value as? [String: AnyObject] else { return }
                let rawData = Array(dict.values)
                
                var notes = [FriendsNoteItem]()
                for item in rawData {
                    notes.append(FriendsNoteItem(rawData: item))
                }
                
                notes = notes.sorted(by: { $0.createdAt > $1.createdAt })
                self?.list = notes
                self?.tableView.reloadData()
            })
    }
    //don't need adding for detail view controller
    
//    @IBAction  func addNewNote() {
//        let newNote = NoteItem(title: "")
//        newNote.id = "add_new_item"
//        list.insert(newNote, at: 0)
//        tableView.reloadData()
//        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource  {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (list.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListCell", for: indexPath) as! FriendNoteListCell
        cell.setData(list[indexPath.row])
        cell.delegate = self
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}


extension DetailViewController: NoteListDelegate {
    func didAddItem(title: String) {

        let noteId = UUID().uuidString
        let note = list[0]
        note.title = title
        note.id = noteId
        view.endEditing(true)
        tableView.reloadData()

        guard let userId = Auth.auth().currentUser?.uid else { return }

        let noteValue: [String: Any] = [
            "id": noteId,
            "title": title,
            "done": false,
            "owner": userId,
            "createdAt": Date().timeIntervalSince1970
        ]

        // save item into firebase

        Database.database().reference()
            .child("Notes")
            .child(userId)
            .child(noteId)
            .setValue(noteValue)
    }
}


