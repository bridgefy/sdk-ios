//
//  DataController.swift
//  TwitterForwarder
//
//  Created by Danno on 7/14/17.
//  Copyright © 2017 Daniel Heredia. All rights reserved.
//

import UIKit
import CoreData

enum TweetStatus: Int {
    case onInternet = 0
    case offline = 1
}


class DataController: NSObject {
    var username: String?
    fileprivate var lastMessageDate: Date?
    fileprivate var lastUser: User?
    let persistentContainer: NSPersistentContainer
    let insertQueue: DispatchQueue
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "RemoteModel")
        insertQueue = DispatchQueue.init(label: "com.bridgefy.alerts.insert")
        super.init()
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("An error occurred loading persistent store \(error)")
            }
        }
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// MARK: - Util methods 

private extension DataController {
    
//    func findTweet(withId messageId: String, context: NSManagedObjectContext) -> Tweet? {
//        do {
//            let fetchRequest: NSFetchRequest<Tweet> = Tweet.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "messageId == %@", messageId)
//            let results = try context.fetch(fetchRequest)
//            return results.first
//        } catch {
//            print("Core Data error: \(error)")
//            return nil
//        }
//    }
    
    func checkLastMessageDate(context: NSManagedObjectContext) {
        if self.lastMessageDate == nil {
            if let lastMessage = self.findLastMessage(context: context) {
                self.lastMessageDate = lastMessage.date
            }
        }
    }
    
    func findLastMessage(context: NSManagedObjectContext) -> Message? {
        do {
            let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: #keyPath(Message.time), ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Core Data error: \(error)")
            return nil
        }
    }
    
    func findUser(withUsername username: String, context: NSManagedObjectContext) -> User? {
        do {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "username == %@", username)
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Core Data error: \(error)")
            return nil
        }
    }
    
    func createUser(withUsername username: String, context: NSManagedObjectContext) -> User {
        let user = NSEntityDescription.insertNewObject(forEntityName: String(describing: User.self), into: context) as! User
        user.username = username
        return user
    }
    
    func checkForUser(message: Message, username: String, context: NSManagedObjectContext) {
        var messageUser = self.lastUser
        if messageUser?.managedObjectContext != context {
            messageUser = nil
        }
        if messageUser == nil || messageUser?.username != username{
            let foundUser = self.findUser(withUsername: username, context: context)
            if foundUser == nil {
                messageUser = self.createUser(withUsername: username, context: context)
            } else {
                messageUser = foundUser
            }
            self.lastUser = messageUser
        }
        message.user = messageUser
    }
    
    func checkForheader(forMessage message: Message, context: NSManagedObjectContext) {
        if self.lastMessageDate == nil {
            if let lastMessage = self.findLastMessage(context: context), lastMessage != message {
                self.lastMessageDate = lastMessage.date
            } else {
                message.hasHeader = true
                self.lastMessageDate = message.date
                return
            }
        }
        guard let lastMessageDate = self.lastMessageDate else {
            return
        }
        let limitTimePassed = message.date.timeIntervalSince(lastMessageDate) > sectionTimeInterval
        let lastDay = Calendar.current.component(.day, from: lastMessageDate)
        let currentDay = Calendar.current.component(.day, from: message.date)
        if  limitTimePassed || lastDay != currentDay {
            message.hasHeader = true
            self.lastMessageDate = message.date
        }
        

        
    }
    
    func insertMessage(fromDictionary dictionary: [ String: Any ], context: NSManagedObjectContext) -> Message {
        self.checkLastMessageDate(context: context)
        let message = NSEntityDescription.insertNewObject(forEntityName: String(describing: Message.self), into: context) as! Message
        let time = dictionary[PacketKeys.date] as! UInt64
        let username = dictionary[PacketKeys.sender] as! String
        message.time = Double(time)
        message.text = dictionary[PacketKeys.text] as? String
        message.own = false
        if let messageId = dictionary[PacketKeys.id] as? String {
            message.messageId  = messageId
        } else {
            message.messageId = UUID().uuidString
        }
        self.checkForheader(forMessage: message, context: context)
        self.checkForUser(message: message, username: username, context: context)
        return message
    }
}

// MARK: - Client methods

extension DataController {
    
    func insertOwnMessage(withText text: String,
                          completion: @escaping (_ success: Bool, _ message: Message?) -> Void){
        persistentContainer.performBackgroundTask { context in
            context.automaticallyMergesChangesFromParent = true
            self.checkLastMessageDate(context: context)
            let username = self.username ?? ""
            let message = NSEntityDescription.insertNewObject(forEntityName: String(describing: Message.self), into: context) as! Message
            message.text = text
            message.time = Date().timeIntervalSince1970
            message.own = true
            message.messageId = UUID().uuidString
            self.checkForheader(forMessage: message, context: context)
            self.checkForUser(message: message, username: username, context: context)
            self.saveContext(context: context)
            self.persistentContainer.viewContext.perform {
                let mainMessage = self.persistentContainer.viewContext.object(with: message.objectID) as! Message
                completion(true, mainMessage)
            }
        }
    }

    func processReceivedMessage(withDictionary dictionary: [ String: Any ] ,
                                completion: @escaping (_ success: Bool, _ message: Message?) -> Void) {
        self.insertQueue.async {
            let context = self.persistentContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            let message = self.insertMessage(fromDictionary: dictionary, context: context)
            self.saveContext(context: context)
            self.persistentContainer.viewContext.perform {
                let mainMessage = self.persistentContainer.viewContext.object(with: message.objectID) as! Message
                completion(true, mainMessage)
            }
        }
    }
    
    func createChatFetchedResultController() -> NSFetchedResultsController<Message> {
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Message.time), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                 managedObjectContext: persistentContainer.viewContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        do {
            try fetchedResultController.performFetch()
        } catch let error {
            print("Error fetching blocked users: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }
    
    func toggleBlockStatus(user: User, completion: (() -> Void)? = nil ) {
        self.persistentContainer.performBackgroundTask { (context) in
            let cUser = context.object(with: user.objectID) as! User
            cUser.blocked = !cUser.blocked
            self.saveContext(context: context)
            self.persistentContainer.viewContext.perform{
                completion?()
            }
        }
    }
    
    func deleteAllMessages(completionBlock: ((_ success: Bool) -> Void)? = nil) {
        self.persistentContainer.performBackgroundTask { (context) in
            context.automaticallyMergesChangesFromParent = true
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            let userBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: userFetchRequest  as! NSFetchRequest<NSFetchRequestResult>)
            let messageFetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
            let messageBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: messageFetchRequest  as! NSFetchRequest<NSFetchRequestResult>)
            do {
                try context.execute(messageBatchDeleteRequest)
                try context.execute(userBatchDeleteRequest)
                self.persistentContainer.viewContext.reset()
                self.persistentContainer.viewContext.perform {
                    completionBlock?(true)
                }
            } catch {
                self.persistentContainer.viewContext.perform {
                    completionBlock?(false)
                }
            }
        }
    }
        
    func saveContext() {
        let context = persistentContainer.viewContext
        saveContext(context: context)
    }
    
    func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
}
