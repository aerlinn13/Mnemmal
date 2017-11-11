//
//  SubmissionFooterTableViewCell.swift
//  mnemmal
//
//  Created by Danil on 30/10/2017.
//  Copyright © 2017 Danil Chernyshev. All rights reserved.
//

import UIKit
import BouncyLayout
import FirebaseStorageUI
import Firebase

class SubmissionFooterTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var myView: UIView!
    var mnemmals = [Mnemmal]()
    var mnemmalOverlookDelegate: MnemmalOverlookDelegate!
    var shareDelegate: ShareDelegate!
    
    
    // CollectionView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("mnemmals.count is: " + String(describing: mnemmals.count))
        return mnemmals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("CellForRowAt(): invoked")
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissionFooterComTableViewCell", for: indexPath) as! SubmissionFooterComTableViewCell
        cell.selectionStyle = .none
        cell.commentorNameLabel.text = self.mnemmals[indexPath.row].userName
        cell.commentDateTime.text = self.mnemmals[indexPath.row].time
        cell.commentsAmountLabel.text = "Comments: " + String(describing: self.mnemmals[indexPath.row].comments.count)
        cell.likesAmountLabel.text = "Likes: " + self.mnemmals[indexPath.row].likesAmount
        cell.commentTextView.text = self.mnemmals[indexPath.row].content
        cell.commentView.layer.cornerRadius = 10.0
        cell.commentTextView.textContainer.lineFragmentPadding = 0
        cell.commentTextView.textContainerInset = .zero
        
        if self.mnemmals[indexPath.row].fbId != "none" {
            let url = URL(string: "http://graph.facebook.com/\(self.mnemmals[indexPath.row].fbId)/picture?type=large")
            print(url!)
            cell.commentorAvatar.sd_setImage(with: url!, placeholderImage: UIImage(named: "Anon"), options: .continueInBackground, completed: nil)
        } else {
            cell.commentorAvatar.image = UIImage(named: "Anon")
        }
        
        if self.mnemmals[indexPath.row].liked {
            cell.likeButtonOutlet.setTitleColor(UIColor.darkText, for: .normal)
            cell.likeButtonOutlet.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.likeButtonOutlet.setImage(UIImage(imageLiteralResourceName: "LikePressed"), for: .normal)
        } else {
            cell.likeButtonOutlet.setTitleColor(UIColor.darkGray, for: .normal)
            cell.likeButtonOutlet.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.likeButtonOutlet.setImage(UIImage(imageLiteralResourceName: "Like"), for: .normal)
        }
        
        cell.commentButtonOutlet.setImage(UIImage(imageLiteralResourceName: "Comment"), for: .normal)
        cell.shareButtonOutlet.setImage(UIImage(imageLiteralResourceName: "Share"), for: .normal)
        cell.commentorAvatar.round(corners: .allCorners, radius: cell.commentorAvatar.bounds.width / 2)
        cell.myView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60.0).isActive = true
        cell.likeButtonOutlet.addTarget(self, action: #selector(likeButtonAct(sender:)), for: .touchUpInside)
        cell.commentButtonOutlet.addTarget(self, action: #selector(commentButtonAct(sender:)), for: .touchUpInside)
        cell.shareButtonOutlet.addTarget(self, action: #selector(shareButtonAct(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 80))
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    
    func likeButtonAct(sender: UIButton!) {
        print("likeButtonAct(): invoked")
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        print("likeButtonAct(): indexPath is: " + String(describing: indexPath))
        let likeInt = Int(self.mnemmals[indexPath!.row].likesAmount)!
        
        // actions on Like and Unlike
        
        if !self.mnemmals[indexPath!.row].liked { // comment not liked - like action
        self.mnemmals[indexPath!.row].likesAmount = String(describing: likeInt + 1)
        print("likeButtonAct(): likesAmount increased by 1 and now = " + self.mnemmals[indexPath!.row].likesAmount)

        if let cell = self.tableView.cellForRow(at: indexPath!) as? SubmissionFooterComTableViewCell {
            self.mnemmals[indexPath!.row].liked = true
            cell.likesAmountLabel.text = "Likes: " + self.mnemmals[indexPath!.row].likesAmount
            cell.likeButtonOutlet.setTitleColor(UIColor.darkText, for: .normal)
            cell.likeButtonOutlet.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            cell.likeButtonOutlet.setImage(UIImage(imageLiteralResourceName: "LikePressed"), for: .normal)
        }
            submitCommentAsLiked(indexPath: indexPath!, liked: false)
        }
        else { // comment  liked - unlike action
            self.mnemmals[indexPath!.row].likesAmount = String(describing: likeInt - 1)
            print("likeButtonAct(): likesAmount decreased by 1 and now = " + self.mnemmals[indexPath!.row].likesAmount)
            if let cell = self.tableView.cellForRow(at: indexPath!) as? SubmissionFooterComTableViewCell {
                self.mnemmals[indexPath!.row].liked = false
                cell.likesAmountLabel.text = "Likes: " + self.mnemmals[indexPath!.row].likesAmount
                cell.likeButtonOutlet.setTitleColor(UIColor.darkGray, for: .normal)
                cell.likeButtonOutlet.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                cell.likeButtonOutlet.setImage(UIImage(imageLiteralResourceName: "Like"), for: .normal)
        }
            submitCommentAsLiked(indexPath: indexPath!, liked: true)
    }
    }

    func submitCommentAsLiked(indexPath: IndexPath, liked: Bool) {
        print("submitCommentAsLiked(): invoked")
        let mnemmal = self.mnemmals[indexPath.row]
        let mnemmalRef = Database.database().reference().child("likes/\(mnemmal.storyId)/\(mnemmal.storyTrack)/\(mnemmal.id)")
        if liked {
            mnemmalRef.observeSingleEvent(of: .value, with: {snapshot in
                if let likesAmount = snapshot.value as? String {
                    var likes = Int(likesAmount)
                    likes = likes! - 1
                    mnemmalRef.setValue("\(likes!)")
                    print("submitCommentAsLiked(): mnemmal is liked")
                }
                        })
        } else {
            mnemmalRef.observeSingleEvent(of: .value, with: {snapshot in
                if let likesAmount = snapshot.value as? String {
                    var likes = Int(likesAmount)
                    likes = likes! + 1
                    mnemmalRef.setValue("\(likes!)")
                    print("submitCommentAsLiked(): mnemmal is unliked")
                } else {
                    mnemmalRef.setValue("1")
                }
            })
        }
    }
    
    func commentButtonAct(sender: UIButton!) {
        print("commentButtonAct(): invoked")
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        print("commentButtonAct(): indexPath is: " + String(describing: indexPath))
        if let mnemmal = self.mnemmals[indexPath!.row] as? Mnemmal {
            mnemmalOverlookDelegate.perform(mnemmal: mnemmal) } else {print("commentButtonAct(): error with subscripting object from mnemmal.array")}
        tableView.visibleCells.forEach({ $0.heroID = "" })
        tableView.cellForRow(at: indexPath!)?.heroID = "mnemmal"
    }
    
    
    func shareButtonAct(sender: UIButton!) {
        print("shareButtonAct(): invoked")
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        print("shareButtonAct(): indexPath is: " + String(describing: indexPath))
        let content = self.mnemmals[indexPath!.row].userName + " wrote a text in Mnemmal app: \"" + self.mnemmals[indexPath!.row].content + "\""
        shareDelegate.shareContent(content: content)
        }

    override func awakeFromNib() {
        super.awakeFromNib()
        let nib = UINib(nibName: "SubmissionFooterComTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SubmissionFooterComTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
