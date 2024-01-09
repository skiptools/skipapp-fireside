import SwiftUI
import FireSideModel

let firestore = try! FireSideStore()

public struct ContentView: View {
    @AppStorage("setting") var setting = true
    @AppStorage("selectedTab") var selectedTab = 0

    public init() {
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            JoinChatView()
                .tag(0)
                .tabItem { Label("Join", systemImage: "star") }
                .task {
                    //do {
                    //    try await fireSide.runTask()
                    //} catch {
                    //    logger.error("error running fireSide task: \(error)")
                    //}
                }

            NavigationStack {
                MessagesListView()
            }
            .tag(1)
            .tabItem { Label("Messages", systemImage: "list.bullet") }

            Form {
                Text("Settings")
                    .font(.largeTitle)
                Toggle("Option", isOn: $setting)
            }
            .tag(2)
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

let fmt: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .short
    f.timeStyle = .short
    return f
}()

let fmt2: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .long
    f.timeStyle = .long
    return f
}()

struct MessagesListView : View {
    @State var messageList: MessageList? = nil

    var body: some View {
        VStack(spacing: 0.0) {
            List {
                if let messageList = messageList {
                    ForEach(messageList.messages) { m in
                        NavigationLink(value: m) {
                            HStack {
                                Text(m.message)
                                    .font(.title2)

                                Text(fmt.string(from: m.time))
                                    .font(Font.callout)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .lineLimit(1)
                        }
                    }
                    .onDelete { indices in
                        Task.detached {
                            await deleteMessages(indices)
                        }
                    }
                }
            }
            #if !SKIP
            // the Observable is in FireSideModel, which doesn't know about SwiftUI and so cannot perform the update in a `withAnimation`
            .animation(.default, value: messageList?.messages)
            #endif
            .navigationTitle("Messages: \(messageList?.messages.count ?? 0)")
            .navigationDestination(for: Message.self) { msg in
                Form {
                    HStack {
                        Text("ID")
                        Text(msg.id ?? "NO ID")
                    }

                    HStack {
                        Text("Message")
                        Text(msg.message)
                    }

                    HStack {
                        Text("Date")
                        Text(fmt2.string(from: msg.time))
                            .font(Font.subheadline)
                    }

                }
                .navigationTitle("Message")
            }

            Divider()

            HStack {
                ForEach(["♥️", "💙", "💛", "💚"], id: \.self) { emoji in
                    Button(emoji) {
                        Task.detached {
                            let isJava = ProcessInfo.processInfo.environment["java.io.tmpdir"] != nil
                            let msg = emoji + " from " + (isJava ? "Android" : "iOS")
                            await sendMessage(msg)
                        }
                    }
                    .font(.largeTitle)
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .task {
            do {
                let messageList = try await firestore.watchMessageList()
                self.messageList = messageList
            } catch {
                logger.error("error getting message list: \(error)")
            }
        }
    }

    func sendMessage(_ message: String) async {
        logger.log("sendMessage: \(message)")
        do {
            let msg = try await firestore.sendMessage(message)
            logger.error("sent message: \(msg)")
        } catch {
            logger.error("error sending message: \(error)")
        }

    }

    func deleteMessages(_ indices: IndexSet) async {
        logger.log("deleteMessages: \(indices)")
        do {
            if let messages = self.messageList?.messages {
                let ids = indices.compactMap({ messages[$0].id })
                self.messageList?.messages.removeAll(where: {
                    ids.contains($0.id ?? "")
                })
                try await firestore.deleteMessages(ids)
                logger.error("deleted ids: \(ids)")
            }
        } catch {
            logger.error("error deleteMessages: \(error)")
        }

    }
}

let chatKeyCount = 8

struct JoinChatView : View {
    @AppStorage("chatKey") var chatKey: String = ""
    @State var lastError: String? = nil

#if !SKIP
    @FocusState var keyFocused
#endif

    var body: some View {
        ZStack {
            //LinearGradient(colors: [Color.red, Color.clear], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 0.0, y: 0.3))
                //.frame(maxHeight: .infinity) // doesn't seem to work on Android

            VStack(alignment: .center) {
                Spacer()

                Button {
                    Task.detached {
                        await joinChat()
                    }
                } label: {
                    ZStack {
                        chatKey.isEmpty ? Text("New Chat", bundle: .module) : Text("Join Chat", bundle: .module)
                    }
                    .font(.largeTitle)
                    .frame(width: 250.0, height: 180.0)
                }
                .buttonStyle(.borderedProminent)
                .disabled(chatKey.isEmpty == false && chatKey.count != chatKeyCount)


                Text(lastError ?? "")
                    .foregroundStyle(Color.red)
                    .opacity(lastError == nil ? 0.0 : 1.0)

                Spacer()

                TextField(text: $chatKey) {
                    Text("Chat Key", bundle: .module)
                }

                #if SKIP || os(iOS)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                #endif
                .padding()
            }
        }
        //.frame(maxHeight: .infinity)
    }

    private func joinChat() async {
        do {
            self.lastError = nil // clear the most recent error
            if chatKey.count == chatKeyCount {
                logger.log("joinChat: \(chatKey)")
                try await firestore.joinChat(chatKey: chatKey)
            } else {
                logger.log("startNewChat")
                chatKey = try await firestore.startNewChat()
            }
        } catch {
            logger.log("joinChat error: \(error)")
            self.lastError = error.localizedDescription
        }
    }
}

//#Preview {
//    if #available(iOS 17.0, *) {
//        ContentView()
//    } else {
//        // Fallback on earlier versions
//    }
//}
