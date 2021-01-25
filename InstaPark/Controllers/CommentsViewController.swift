//
//  CommentsViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/21/21.
//

import UIKit

class CommentsViewController: UIViewController, UITextViewDelegate{
    
    @IBOutlet var comments: UITextView!
    //Comment can be retrieved using comments.text
    @IBOutlet var wordCount: UILabel!
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = textView.text.count + (text.count - range.length)
        guard count <= 140 else {return false}
        wordCount.text = "\(count)/140"
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if comments.textColor == UIColor.lightGray {
            comments.text = nil
            comments.textColor = UIColor.black
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        comments.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comments.delegate = self
        comments.text = "Start typing here..."
        comments.textColor = UIColor.lightGray
        comments.textContainerInset.left = 10
        comments.textContainerInset.right = 10
    }
    


}
