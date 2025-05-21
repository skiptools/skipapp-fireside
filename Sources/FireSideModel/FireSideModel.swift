import Foundation
import OSLog
import Observation

#if !SKIP
import FirebaseCore
import FirebaseFirestore
#else
import SkipFirebaseCore
import SkipFirebaseFirestore
#endif

let logger: Logger = Logger(subsystem: "fire.side", category: "FireSideModel")

public actor FireSideModel {
    /// The global Firestore instance for the app, configured using the default
    /// `Android/app/google-services.json` and `Darwin/GoogleService-Info.plist` configuration files
    /// which can be downloaded for your project from https://console.firebase.google.com/project/
    private let firestore: Firestore

    /// Set the application's shared model to a configured instance before use.
    public static var shared = FireSideModel()

    public init() {
        self.firestore = Firestore.firestore()
    }

    @MainActor public func joinChat(chatKey: String) async throws {
        logger.info("joinChat: \(chatKey)")
    }

    @MainActor public func watchMessageList() async throws -> MessageList {
        return MessageList(firestore.collection("messages"))
    }

    /// "Sends" a message by adding it to the document
    @MainActor public func sendMessage(_ message: String) async throws -> Message {
        logger.info("sendMessage: \(message)")
        let msg = Message(id: nil, message: message, time: Date.now)
        let _ = try await firestore.collection("messages").addDocument(data: msg.data)
        return msg
    }

    @MainActor public func deleteMessages(_ ids: [String]) async throws {
        for doc in try await firestore.collection("messages")
            .whereField(FieldPath.documentID(), in: ids.map({ $0 as Any }))
            .getDocuments()
            .documents {
            try await doc.reference.delete()
        }
    }

    @MainActor public func startNewChat() async throws -> String {
        logger.info("startNewChat")

        //let cref = firestore.collection("messages")
        //let q = cref.whereField("t", isGreaterThan: 100.0).limit(to: 4)

        //let snapshot = try await cref.getDocuments()
        //logger.log("cref document: \(snapshot)")
        //for document in snapshot.documents {
        //    logger.log("read cref: \(document.documentID) => \(document.data())")
        //}

        //var changeCount = 0
        //let lreg = cref.addSnapshotListener { q, e in
        //    if let q = q {
        //        logger.log("  addSnapshotListener: \(q) count: \(q.documentChanges.count)")
        //        for change in q.documentChanges {
        //            changeCount += 1
        //            let t = change.type
        //            logger.log("    - change: \(String(describing: t)) \(change.document) \(change)")
        //            let data = change.document.data()
        //            logger.log("      - change data: \(data)")
        //        }
        //    } else {
        //        logger.log("  addSnapshotListener: NO QUERY error=\(e)")
        //    }
        //}

        //logger.log("added snapshot listener")

        //let dref = try await cref.addDocument(data: [
        //    "m": "some message",
        //    "t": Date.now.timeIntervalSince1970,
        //])

        //logger.log("created document: \(dref.documentID)")

        //print("changeCount: \(changeCount) listener: \(lreg)")
        //lreg.remove()

        //return dref.documentID

        return "ABCDEF"
    }

    public struct InvalidConfigurationError : LocalizedError {
        public var errorDescription: String?
    }
}
