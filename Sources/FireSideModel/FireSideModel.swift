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
        //let options = FirebaseOptions(googleAppID: "", gcmSenderID: "")
        FirebaseApp.configure()
        self.firestore = Firestore.firestore()
    }

    @MainActor public func joinChat(chatKey: String) async throws {
        logger.info("joinChat: \(chatKey)")
    }

    @MainActor public func startNewChat() async throws -> String {
        logger.info("startNewChat")
        return "12345678"
    }

    @MainActor public func runTask() async throws {
        let dbname = "(default)"

        let cref = firestore.collection("messages")

        let snapshot = try await cref.getDocuments()
        for document in snapshot.documents {
            logger.log("read cref: \(document.documentID) => \(document.data())")
        }

        let id = UUID()
        let bos = cref.document("msg-\(id.uuidString)")

        try await bos.setData([
            "k": "message",
            "t": Date.now.timeIntervalSince1970,
            "c": "message content"
        ])
    }
}
