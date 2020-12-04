//
//  HomeViewController.swift
//  Today
//

import UIKit
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController {
    
    var list = [NoteItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        title = "To Do Today"
        
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func getData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Database.database().reference()
            .child("Users")
            .child(userId)
            .child("firstName")
            .observeSingleEvent(of: .value) { [weak self] (snapshot) in
                guard let name = snapshot.value as? String else { return }
                self?.navigationItem.title = name + "'s To Do Today"
        }
        
        Database.database().reference()
            .child("Notes")
            .child(userId).observeSingleEvent(of: .value) { [weak self] (snapshot) in
                guard let dict = snapshot.value as? [String: AnyObject] else { return }
                let rawData = Array(dict.values)
                
                var notes = [NoteItem]()
                for item in rawData {
                    notes.append(NoteItem(rawData: item))
                }
                
                notes = notes.sorted(by: { $0.createdAt > $1.createdAt })
                self?.list = notes
                self?.tableView.reloadData()
        }
    }
    
    @IBAction func addNewNote(_ sender: UIBarButtonItem) {
        let newNote = NoteItem(title: "")
        newNote.id = "add_new_item"
        list.insert(newNote, at: 0)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource  {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (list.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListCell", for: indexPath) as! NoteListCell
        cell.setData(list[indexPath.row])
        cell.delegate = self
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let item = list[indexPath.row]
            deleteItemInDatabase(item: item)
            self.list.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
    }
    
    func deleteItemInDatabase(item: NoteItem) {
        guard let noteId = item.id else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Database.database().reference()
        .child("Notes")
        .child(userId)
        .child(noteId)
        .removeValue()
    }
    
}


extension HomeViewController: NoteListDelegate {
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

