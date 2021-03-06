//
//  CommentViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/20/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var brewery:Brewery!
    var beer:Beer!
    var commmentsArray:NSArray = []
    let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var textFieldViewBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var textFieldComment: UITextField!

    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.loadComments()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        self.commentsTableView.userInteractionEnabled = false
        self.view.userInteractionEnabled = true
        self.view.layoutIfNeeded()
        
        if self.beer == nil
        {
            self.navigationItem.title = self.brewery.name
        }
        else
        {
            self.navigationItem.title = self.beer.beerName
        }

    }
    
    
    func loadComments()
    {
        let commentRef:Firebase!
        
        if self.beer == nil
        {
            commentRef =  FirebaseConnection.firebaseConnection.COMMENT_REF.childByAppendingPath(brewery.firebaseID)
        }
        else
        {
            commentRef = FirebaseConnection.firebaseConnection.COMMENT_REF.childByAppendingPath(beer.firebaseID)
        }
        
        
       commentRef.observeEventType(.Value, withBlock: { snapshot in
            
            if(snapshot.value is NSNull)
            {
                self.commmentsArray = []
            }
            else
            {
                self.commmentsArray = snapshot.value.allObjects
            }
            
            self.commentsTableView.reloadData()
        
        })
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commmentsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell")
        let comment = self.commmentsArray[indexPath.row] as? NSDictionary
        cell?.textLabel?.text = comment?.valueForKey("text") as? String
        cell?.detailTextLabel?.text = comment?.valueForKey("username") as? String
       
        
        return cell!
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if (textField.text != "")
        {
            let commentRef:Firebase!
            
            if self.beer == nil
            {
                commentRef =  FirebaseConnection.firebaseConnection.COMMENT_REF.childByAppendingPath(brewery.firebaseID)
            }
            else
            {
                commentRef = FirebaseConnection.firebaseConnection.COMMENT_REF.childByAppendingPath(beer.firebaseID)
            }
            
            commentRef.childByAutoId().setValue(["text":textField.text!, "username":username!])
            
            textField.text = ""
            
            self.loadComments()
        }
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            
            self.textFieldViewBottomLayout.constant = keyboardSize.height - 49
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.textFieldViewBottomLayout.constant = 0
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    
    
}
