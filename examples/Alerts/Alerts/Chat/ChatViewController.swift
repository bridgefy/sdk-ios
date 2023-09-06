//
//  ChatViewController.swift
//  Remote Control
//
//  Created by Danno on 8/15/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

let toolbarRightPadding: CGFloat = 10.0

class ChatViewController: JSQMessagesViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var bubbleFactory: JSQMessagesBubbleImageFactory!
    weak var transmissionManager: TransmissionManager? {
        didSet {
            self.transmissionManager?.chatDelegate = self
        }
    }
    fileprivate var fetchedResultController: NSFetchedResultsController<Message>!
    fileprivate var changeOperations: [BlockOperation]?

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 250
        }
        self.fetchedResultController = self.transmissionManager!.dataController.createChatFetchedResultController()
        self.fetchedResultController.delegate = self
        self.setupMessageViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.viewDidRotate), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    func setupMessageViewController() {
        self.bubbleFactory = JSQMessagesBubbleImageFactory()
        self.inputToolbar.contentView.textView.pasteDelegate = self
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.showLoadEarlierMessagesHeader = false
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.senderId = self.transmissionManager!.username
        self.senderDisplayName = self.transmissionManager!.username
        self.incomingCellIdentifier =  String(describing: ChatMessageCellIncoming.self)
        self.outgoingCellIdentifier = String(describing: ChatMessageCellOutgoing.self)
        self.collectionView.register(UINib.init(nibName: self.incomingCellIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: self.incomingCellIdentifier)
        self.collectionView.register(UINib.init(nibName: self.outgoingCellIdentifier, bundle: nil),
                                     forCellWithReuseIdentifier: self.outgoingCellIdentifier)
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor( #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1), for: .normal)
        self.inputToolbar.contentView.textView.tintColor = #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1)
        self.collectionView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "chatBackground"))
        if #available(iOS 11.0, *) {
            self.inputToolbar.contentView.leftContentPadding = self.view.safeAreaInsets.left
            self.inputToolbar.contentView.rightContentPadding = self.view.safeAreaInsets.right + toolbarRightPadding
        }
        self.topContentAdditionalInset = 20.0
    }
    
    @objc func viewDidRotate() {
        if #available(iOS 11.0, *) {
            self.inputToolbar.contentView.leftContentPadding = self.view.safeAreaInsets.left
            self.inputToolbar.contentView.rightContentPadding = self.view.safeAreaInsets.right + toolbarRightPadding
        }
    }

    override func didReceiveMenuWillShow(_ notification: Notification!) {
        print("Keyboard will be shown!")
        super.didReceiveMenuWillShow(notification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func hideButtonPressed(sender: Any) {
        self.view.endEditing(true)
        self.revealViewController().revealToggle(sender)
    }
    
    @IBAction func deleteAllMessages(_ sender: Any) {
        let alert = UIAlertController(title: "Confirmation",
                                      message: "Are you sure you want to delete all the messages?",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: UIAlertAction.Style.destructive,
                                      handler:{ (alert) in
                                        self.fetchedResultController.delegate = nil
                                        self.transmissionManager?.dataController.deleteAllMessages(completionBlock: { [weak self] (success) in
                                            guard let self = self else { return }
                                            if success {
                                                self.fetchedResultController = self.transmissionManager?.dataController.createChatFetchedResultController()
                                                self.collectionView.reloadData()
                                            }
                                            self.fetchedResultController.delegate = self
                                        })
        }))
        alert.addAction(UIAlertAction(title: "Not",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
}


// MARK: - JSQMessagesViewController method overrides

extension ChatViewController {
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.transmissionManager?.sendMessage(text: text)
        self.finishSendingMessage(animated: true)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        //TODO: Add code
    }
    
}

extension ChatViewController {
    
    override var senderId: String! {
        get {
            return super.senderId
        }
        set {
            super.senderId = newValue
        }
    }
    
    override var senderDisplayName: String! {
        get {
            return super.senderDisplayName
        }
        set {
            super.senderDisplayName = newValue
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let message = self.fetchedResultController.object(at: indexPath)
        if message.user == nil {
            return nil
        }
        let text = message.user!.blocked ? "BLOCKED CONTENT" : message.text
        let messageCellData = JSQMessage(senderId: message.user!.username!,
                                         senderDisplayName: message.user!.username!,
                                         date: Date.distantPast,
                                         text: text)
        return messageCellData
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        //self.messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.fetchedResultController.object(at: indexPath)
        if message.own {
            return self.bubbleFactory.outgoingMessagesBubbleImage(with: #colorLiteral(red: 0.9998916984, green: 1, blue: 0.9998809695, alpha: 1))
        } else {
            if message.user!.blocked {
                return self.bubbleFactory.incomingMessagesBubbleImage(with: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
            } else {
                return self.bubbleFactory.incomingMessagesBubbleImage(with: #colorLiteral(red: 1, green: 0.9819477201, blue: 0.8858447671, alpha: 1))
            }
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = self.fetchedResultController.object(at: indexPath)
        if (message.hasHeader) {
            let message = self.fetchedResultController.object(at: indexPath)
            let stringDate = message.date.stringDate()
            var attributes = JSQMessagesTimestampFormatter.shared().dateTextAttributes as! [NSAttributedString.Key: Any]
            attributes[NSAttributedString.Key.foregroundColor] = UIColor.darkGray
            return NSAttributedString.init(string: stringDate, attributes: attributes)
        } else {
            return nil
        }

    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = self.fetchedResultController.object(at: indexPath)
        if message.own {
            return nil
        }

        if (indexPath.row - 1 > 0) {
            let previousIndexPath = IndexPath.init(row: indexPath.row - 1, section: indexPath.section)
            let previousMessage = self.fetchedResultController.object(at: previousIndexPath)
            if previousMessage.user?.username == message.user?.username {
                return nil
            }
        }
        let color = #colorLiteral(red: 0.2784313725, green: 0.2784313725, blue: 0.2784313725, alpha: 1)
        let font = UIFont.boldSystemFont(ofSize: 15.0)
        let attributes = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font]
        return NSAttributedString.init(string: message.user!.username!, attributes: attributes)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = self.fetchedResultController.object(at: indexPath)
        if message.isDisclosed {
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
            return NSAttributedString.init(string: "  \(message.date.stringTime())  ", attributes: attributes)
        } else {
            return nil
        }
    }
}

// MARK: - UICollectionView Datasource

extension ChatViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return self.fetchedResultController.sections!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultController.sections![section].numberOfObjects
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        //let message = self.messages[indexPath.row]
        cell.textView.textColor = UIColor.black
        cell.textView.isUserInteractionEnabled = false
        return cell
    }
    
}

// MARK: - UICollectionView Delegate

extension ChatViewController {
    
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        let menuController = UIMenuController.shared
        let message = self.fetchedResultController.object(at: indexPath)
        if message.own {
            menuController.menuItems = []
            return true
        }
        let blockItem: UIMenuItem!
        if let blocked = message.user?.blocked, blocked {
            blockItem = UIMenuItem.init(title: "Unblock user", action: #selector(JSQMessagesCollectionViewCell.unblock))
        } else {
            blockItem = UIMenuItem.init(title: "Block user", action: #selector(JSQMessagesCollectionViewCell.block))
        }

        let reportItem = UIMenuItem.init(title: "Report", action: #selector(JSQMessagesCollectionViewCell.report))
        menuController.menuItems = [blockItem, reportItem]
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        switch action {
        case #selector(JSQMessagesCollectionViewCell.block(_:)),
             #selector(JSQMessagesCollectionViewCell.unblock(_:)):
            let message = self.fetchedResultController.object(at: indexPath)
            self.transmissionManager?.dataController.toggleBlockStatus(user: message.user!, completion: { [weak self] in
                self?.collectionView.reloadData()
            })
        case #selector(JSQMessagesCollectionViewCell.report(_:)):
            let message = self.fetchedResultController.object(at: indexPath)
            self.report(message: message)
        default:
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
}

// MARK: - Fetched Result Controller Delegate

extension ChatViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.changeOperations = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var operation: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            operation = BlockOperation { [unowned self] in
                self.collectionView?.insertItems(at: [newIndexPath])
            }
        case .delete:
            guard let indexPath = indexPath else { return }
            operation = BlockOperation { [unowned self] in
                self.collectionView?.deleteItems(at: [indexPath])
            }
        case .update:
            guard let newIndexPath = newIndexPath else { return }
            operation = BlockOperation { [unowned self] in
                self.collectionView?.reloadItems(at: [newIndexPath])
            }
        case .move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            operation = BlockOperation { [unowned self] in
                self.collectionView?.deleteItems(at: [indexPath])
                self.collectionView?.insertItems(at: [newIndexPath])
            }
        }
        changeOperations?.append(operation)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard var changeOperations = self.changeOperations else {
            return
        }
        self.collectionView?.performBatchUpdates({
            changeOperations.forEach { $0.start() }
        }, completion: { (success) in
            changeOperations.removeAll()
            self.changeOperations = nil
            self.scrollToBottom(animated: true)
        })
    }
}

// MARK: - JSQMessages collection view flow layout delegate

extension ChatViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = self.fetchedResultController.object(at: indexPath)
        if (message.hasHeader) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        } else {
            return 0.0
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let message = self.fetchedResultController.object(at: indexPath)
        if message.own {
            return 0.0
        }
        
        if (indexPath.row - 1 > 0) {
            let previousIndexPath = IndexPath.init(row: indexPath.row - 1, section: indexPath.section)
            let previousMessage = self.fetchedResultController.object(at: previousIndexPath)
            if previousMessage.user!.username == message.user!.username {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = self.fetchedResultController.object(at: indexPath)
        if message.isDisclosed {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
}

// MARK: - Responding to collection view tap events

extension ChatViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("Did tap load earlier")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        print("Did tap avatar")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("Did tap message bubble")
        let message = self.fetchedResultController.object(at: indexPath)
        message.isDisclosed = !message.isDisclosed
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        print("Did tap at point")
    }
}

// MARK: - JSQMessagesComposerTextViewPasteDelegate methods

extension ChatViewController: JSQMessagesComposerTextViewPasteDelegate {
    
    func composerTextView(_ textView: JSQMessagesComposerTextView!, shouldPasteWithSender sender: Any!) -> Bool {
        return true
    }

}

// MARK: - Transmission Manager Chat Delegate

extension ChatViewController: TransmissionManagerChatDelegate {
    func transmissionManager(_ manager: TransmissionManager, didReceiveMessage message: Message) {
        print("Message received")
    }
    
    func transmissionManager(_ manager: TransmissionManager, didSendMessage message: Message) {
        print("Message sent")
    }
}

// MARK: - Report

extension ChatViewController {
    func report(message: Message) {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Warning",
                                          message: "You need to configure a e-mail account in your phone before sending a report",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Accept",
                                           style: UIAlertAction.Style.default,
                                           handler: nil))
            self.present(alert, animated: true)
            return
        }
        let email = "report@bridgefy.me"
        let subject = "User report: \(message.user!.username!)"
        let body = "User to report: \(message.user!.username!) \nMessage: \(message.text!)\nExplanation:\nWrite your reasons."
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([email])
        composeVC.setSubject(subject)
        composeVC.setMessageBody(body, isHTML: false)
        composeVC.navigationBar.tintColor = #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1)
        composeVC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1)]
        self.present(composeVC, animated: true, completion: nil)
    }
}

// MARK: - Mail composer delegate

extension ChatViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

