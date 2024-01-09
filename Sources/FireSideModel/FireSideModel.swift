import SkipFoundation
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

public actor FireSideStore {
    /// The global Firestore instance for the app, configured using the default
    /// `Android/app/google-services.json` and `Darwin/GoogleService-Info.plist` configuration files
    /// which can be downloaded for your project from https://console.firebase.google.com/project/
    private let firestore: Firestore

    public init(bundleURL: URL? = nil) throws {
        // TODO: use the bundleURL to load an offline bundle for testing
        FirebaseApp.configure()
        self.firestore = Firestore.firestore()
    }

    /// Create a custom Firestore with the given name
    public init(options: [String: String]) throws {
        guard let appId = options["GOOGLE_APP_ID"],
              let senderId = options["GCM_SENDER_ID"] else {
            throw InvalidConfigurationError(errorDescription: "configuration options are missing required attributes")
        }

        let opts = FirebaseOptions(googleAppID: appId, gcmSenderID: senderId)
        if let apiKey = options["API_KEY"] {
            opts.apiKey = apiKey
        }
        if let projectID = options["PROJECT_ID"] {
            opts.projectID = projectID
        }
        if let storageBucket = options["STORAGE_BUCKET"] {
            opts.storageBucket = storageBucket
        }

        FirebaseApp.configure(options: opts)
        self.firestore = Firestore.firestore()
    }

    @MainActor public func joinChat(chatKey: String) async throws {
        logger.info("joinChat: \(chatKey)")
    }

    @MainActor public func watchMessageList() async throws -> MessageList {
        MessageList(firestore.collection("messages"))
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

        let cref = firestore.collection("messages")
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

    //@MainActor public func runTask() async throws {
    //    //let dbname = "(default)"

    //    let cref = firestore.collection("messages")
    //    let snapshot = try await cref.getDocuments()
    //    for document in snapshot.documents {
    //        logger.log("read cref: \(document.documentID) => \(document.data())")
    //    }

    //    let id = UUID()
    //    let bos = cref.document("msg-\(id.uuidString)")

    //    try await bos.setData(Message(id: UUID(), message: "message", time: Date.now).data)
    //}

    public struct InvalidConfigurationError : LocalizedError {
        public var errorDescription: String?
    }
}

/// A live list of all the messages, updated using a Firestore snapshot listenr on the "messages" collection.
@Observable public class MessageList {
    private var listener: ListenerRegistration? = nil
    public var messages: [Message] = []

    fileprivate init(_ collection: CollectionReference) {
        let listener = collection.addSnapshotListener(includeMetadataChanges: true, listener: { [weak self] snap, err in
            logger.log("snapshot: \(snap) error=\(err)")
            var msgs: [Message] = []
            if let snap = snap {
                for doc in snap.documents {
                    if let msg = Message.from(id: doc.documentID, data: doc.data()) {
                        msgs.append(msg)
                    } else {
                        logger.warning("could not create message from data: \(doc.data())")
                    }
                }
            }
            msgs.sort {
                $0.time > $1.time
            }
            
            self?.messages = msgs
        })

        self.listener = listener
    }
}

/// An individual message
public struct Message: Hashable, Identifiable, Codable, CustomStringConvertible {
    public let id: String?
    public var message: String
    public var time: Date

    public var description: String {
        return "Message: id=\(id ?? "NONE") message=\(message) time=\(time.timeIntervalSince1970)"
    }

    static func from(id: String, data: [String: Any]) -> Message? {
        guard let message = data["m"] as? String else {
            return nil
        }
        guard let time = data["t"] as? TimeInterval else {
            return nil
        }
        return Message(id: id, message: message, time: Date(timeIntervalSince1970: time))
    }

    var data: [String: Any] {
        [
            "m": message,
            "t": time.timeIntervalSince1970,
        ]
    }
}
