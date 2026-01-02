import SwiftUI
import FireSideModel

public struct ContentView: View {
    @AppStorage("setting") var setting = true
    @AppStorage("selectedTab") var selectedTab = 0
    @State var messageList: MessageList? = nil

    public init() {
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                VStack(spacing: 0.0) {
                    MessagesListView(messageList: $messageList)
                    Divider()
                    SendMessageBar(messageList: $messageList)
                }
            }
            .tag(0)
            .tabItem { Label("Messages", systemImage: "list.bullet") }

            NavigationStack {
                Form {
                    Toggle("Option", isOn: $setting)
                }
                .navigationTitle("Settings")
            }
            .tag(1)
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .task {
            do {
                let messageList = try await FireSideModel.shared.watchMessageList()
                self.messageList = messageList
            } catch {
                logger.error("error getting message list: \(error)")
            }
        }
        .task {
            #if os(iOS) || os(Android) // UNUserNotificationCenter unavailable on macOS
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let authorizationStatus = settings.authorizationStatus
            logger.info("notification authorization status: \(authorizationStatus.rawValue)")
            #endif
        }
        // Used when sending "deeplink" key in notifications: fireside://tab/<tab>
        .onOpenURL { url in
            if url.host() == "tab" {
                selectedTab = url.path() == "/settings" ? 1 : 0
            }
        }
    }
}

let shortFormat: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .short
    f.timeStyle = .short
    return f
}()

let longFormat: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .long
    f.timeStyle = .long
    return f
}()

let isAndroid = ProcessInfo.processInfo.environment["java.io.tmpdir"] != nil

struct SendMessageBar : View {
    @Binding var messageList: MessageList?

    var body: some View {
        HStack {
            ForEach(["♥️", "💙", "💛", "💚"], id: \.self) { emoji in
                Button(emoji) {
                    Task.detached {
                        let msg = emoji + " from " + (isAndroid ? "Android" : "iOS")
                        await sendMessage(msg)
                    }
                }
                .font(.largeTitle)
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    func sendMessage(_ message: String) async {
        logger.log("sendMessage: \(message)")
        do {
            let msg = try await FireSideModel.shared.sendMessage(message)
            logger.error("sent message: \(msg)")
        } catch {
            logger.error("error sending message: \(error)")
        }

    }
}

struct MessagesListView : View {
    @Binding var messageList: MessageList?

    var body: some View {
        VStack(spacing: 0.0) {
            List {
                if let messageList = messageList {
                    ForEach(messageList.messages) { m in
                        NavigationLink(value: m) {
                            HStack {
                                Text(m.message)
                                    .font(.title2)

                                Text(shortFormat.string(from: m.time))
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
                        Text(longFormat.string(from: msg.time))
                            .font(Font.subheadline)
                    }

                }
                .navigationTitle("Message")
            }
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
                try await FireSideModel.shared.deleteMessages(ids)
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
    }

    private func joinChat() async {
        do {
            self.lastError = nil // clear the most recent error
            if chatKey.count == chatKeyCount {
                logger.log("joinChat: \(chatKey)")
                try await FireSideModel.shared.joinChat(chatKey: chatKey)
            } else {
                logger.log("startNewChat")
                chatKey = try await FireSideModel.shared.startNewChat()
            }
        } catch {
            logger.log("joinChat error: \(error)")
            self.lastError = error.localizedDescription
        }
    }
}
