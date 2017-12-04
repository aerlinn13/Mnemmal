//
//  MnemmalOverlookTVC.swift
//  mnemmal
//
//  Created by Danil on 06/11/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import ALTextInputBar
import Firebase
import SwipeCellKit

class MnemmalOverlookTVC: UITableViewController, UITextViewDelegate, SwipeTableViewCellDelegate {


    // - MARK: Variables
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let textInputBar = ALTextInputBar()
    
    // The magic sauce
    // This is how we attach the input bar to the keyboard
    override var inputAccessoryView: UIView? {
        get {
            return textInputBar
        }
    }
    
    // Another ingredient in the magic sauce
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var mnemmal: Mnemmal?
    var user: User?
    let button = UIButton()
    var commentsDelegate: CommentsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib0 = UINib(nibName: "MnemmalOverlookHeaderTableViewCell", bundle: nil)
        tableView.register(nib0, forCellReuseIdentifier: "MnemmalOverlookHeaderTableViewCell")
        let nib1 = UINib(nibName: "MnemmalOverlookContentTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "MnemmalOverlookContentTableViewCell")
        let nib2 = UINib(nibName: "MnemmalOverlookNewCommentTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "MnemmalOverlookNewCommentTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
        tableView.separatorStyle = .none
        tableView.bounces = false
        textInputBar.backgroundColor = .white
        textInputBar.textView.placeholder = "Your comment..."
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(#imageLiteral(resourceName: "sendButton"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        textInputBar.rightView = button
        textInputBar.alwaysShowRightButton = true
        print("MnemmalOverlookTVC: userName is " + (self.user?.name)! + ". And FbId is " + (self.user?.fbId)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textInputBar.textView.becomeFirstResponder()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let commentsCount = mnemmal?.comments.count ?? Int("0")
    
        switch section {
        case 0: return 1
        case 1: return commentsCount!
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell0 = tableView.dequeueReusableCell(withIdentifier: "MnemmalOverlookHeaderTableViewCell") as! MnemmalOverlookHeaderTableViewCell
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "MnemmalOverlookContentTableViewCell") as! MnemmalOverlookContentTableViewCell
    
        switch (indexPath.section) {
        case 0:
            cell0.delegate = self as! SwipeTableViewCellDelegate
            cell0.selectionStyle = .none
            cell0.authorName.text = mnemmal?.userName
            cell0.mnemmalDate.text = mnemmal?.time
            cell0.authorAvatar.round(corners: .allCorners, radius: cell0.authorAvatar.bounds.width / 2)
            // Setting mnemmal image
            if mnemmal!.fbId != "none" {
                let url = URL(string: "http://graph.facebook.com/\(mnemmal!.fbId)/picture?type=large")
                print("MnemmalOverlook(): cellforRowAt: " + String(describing: url!))
                cell0.authorAvatar.sd_setImage(with: url!, placeholderImage: UIImage(named: "Anon"), options: .continueInBackground, completed: nil)
            } else {
                cell0.authorAvatar.image = UIImage(named: "Anon")
            }
            cell0.mnemmalTextView.text = mnemmal!.content
            cell0.heroID = "mnemmal"
            cell0.closeButton.addTarget(self, action: #selector(dismissal), for: .touchUpInside)
            cell0.copyButton.addTarget(self, action: #selector(copyText), for: .touchUpInside)
            return cell0
        case 1:
            cell1.delegate = self as! SwipeTableViewCellDelegate
            cell1.selectionStyle = .none
            cell1.commentorAvatar.image = UIImage(named: "Anon")
            cell1.commentorAvatar.round(corners: .allCorners, radius: cell0.authorAvatar.bounds.width / 2)
            if let comment = mnemmal?.comments[indexPath.row] {
                print("MnemmalOverlook(): cellforRowAt: successfully got comment")
                cell1.commentorName.text = comment.userName
                cell1.commentDate.text = comment.time
                cell1.commentText.text = comment.content
                // Setting mnemmal image
                if comment.fbId != "none" {
                    let url = URL(string: "http://graph.facebook.com/\(comment.fbId)/picture?type=large")
                    print("MnemmalOverlook(): cellforRowAt: " + String(describing: url))
                    cell1.commentorAvatar.sd_setImage(with: url!, placeholderImage: UIImage(named: "Anon"), options: .continueInBackground, completed: nil)
                } else {
                    cell1.commentorAvatar.image = UIImage(named: "Anon")
                }
            }
            return cell1
        default:
            return cell1
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        let options = SwipeTableOptions()
        return options
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
            self.deleteComment(indexPath: indexPath)
            self.mnemmal?.comments.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.tableView.endUpdates()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "deleteMnemmal")
        deleteAction.backgroundColor = .white
        deleteAction.textColor = .lightGray
        
        
        
        if self.mnemmal!.comments[indexPath.row].userId == self.user!.id! {
            print(self.mnemmal!.comments[indexPath.row].userId + "  swipe  " + self.user!.id!)
            return [deleteAction]
        } else { return [] }
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textInputBar.textView.resignFirstResponder()
    }

    @objc func dismissal() {
        print("dismissal(): invoked")
        commentsDelegate.updateMnemmalComments()
        // textInputBar.textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func copyText() {
        print("copyText(): invoked")
        textInputBar.text.append(" " + (mnemmal?.content)!)
    }
    
    @objc func sendComment() {
        print("sendComment(): invoked")
        let text = textInputBar.text
        let id = (mnemmal?.id)! + (user?.id)! + String(arc4random_uniform(100000))
        let comment = MnemmalComment(id: id, userId: (self.user?.id)!, fbId: (self.user?.fbId)!, userName: (self.user?.name)!, mnemmalId: (mnemmal?.id)!, time: getCurrentDate(), content: text!)
        mnemmal?.comments.append(comment)
        textInputBar.textView.text = nil
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(item: self.mnemmal!.comments.count - 1, section: 1)], with: .bottom)
        tableView.endUpdates()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.tableView.scrollToRow(at: IndexPath(item: self.mnemmal!.comments.count - 1, section: 1), at: .none, animated: true)
        })
        postComment(comment: comment)
        
    }

    func postComment(comment: MnemmalComment) {
        print("postComment(): invoked")
        let commentsRef = Database.database().reference().child("comments/\(mnemmal!.storyId)/\(mnemmal!.storyTrack)/\(mnemmal!.id)").childByAutoId()
        commentsRef.keepSynced(true)
        commentsRef.child("ID").setValue(comment.id)
        commentsRef.child("userID").setValue(comment.userId)
        commentsRef.child("fbID").setValue(comment.fbId)
        commentsRef.child("userName").setValue(comment.userName)
        commentsRef.child("mnemmalId").setValue(comment.mnemmalId)
        commentsRef.child("time").setValue(comment.time)
        commentsRef.child("content").setValue(comment.content)
    }
    
    func deleteComment(indexPath: IndexPath) {
        print("deleteComment(): invoked" + String(describing: indexPath))
        let comment = self.mnemmal!.comments[indexPath.row]
        let commentsRef = Database.database().reference().child("comments/\(mnemmal!.storyId)/\(mnemmal!.storyTrack)/\(mnemmal!.id)")
        commentsRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    print("deleteComment(): snap.key is " + snap.key)
                    let id = snap.childSnapshot(forPath: "ID").value as! String
                    print("deleteComment(): firebase id is " + id)
                    print("deleteComment(): comment.id is " + comment.id)
                    
                    if id == comment.id {
                        commentsRef.child(snap.key).removeValue()
                        print("deleteComment(): value removed.")
                    }
            }
            self.commentsDelegate.updateMnemmalComments()
        }
        })
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "MMM dd, yyyy hh:mm"
        let stringDate: String = formatter.string(from: date)
        return stringDate
    }
}
