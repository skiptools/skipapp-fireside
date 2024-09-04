import Foundation
import Observation

#if !SKIP
import FirebaseCore
import FirebaseFirestore
#else
import SkipFirebaseCore
import SkipFirebaseFirestore
#endif

/// A live list of all the messages, updated using a Firestore snapshot listenr on the "messages" collection.
@Observable public class MessageList {
    private var listener: ListenerRegistration? = nil
    public var messages: [Message] = []

    init(_ collection: CollectionReference) {
        let listener = collection.addSnapshotListener(includeMetadataChanges: true, listener: { [weak self] snap, err in
            //logger.log("snapshot: \(snap) error=\(err)")
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
