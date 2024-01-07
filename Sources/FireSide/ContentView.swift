import SwiftUI
import FireSideModel

let fireSide = try! FireSideStore()

public struct ContentView: View {
    @AppStorage("setting") var setting = true

    public init() {
    }

    public var body: some View {
        TabView() {
            JoinChatView()
                .tag(0)
                .tabItem { Label("Welcome", systemImage: "star") }
                .task {
                    //do {
                    //    try await fireSide.runTask()
                    //} catch {
                    //    logger.error("error running fireSide task: \(error)")
                    //}
                }

            NavigationStack {
                List {
                    ForEach(1..<1_000) { i in
                        NavigationLink("Home \(i)", value: i)
                    }
                }
                .navigationTitle("Navigation")
                .navigationDestination(for: Int.self) { i in
                    Text("Destination \(i)")
                        .font(.title)
                        .navigationTitle("Navigation \(i)")
                }
            }
            .tag(1)
            .tabItem { Label("Home", systemImage: "house.fill") }

            Form {
                Text("Settings")
                    .font(.largeTitle)
                Toggle("Option", isOn: $setting)
            }
            .tag(1)
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

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
                .disabled(chatKey.isEmpty == false && chatKey.count != 8)


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
            if chatKey.count == 8 {
                try await fireSide.joinChat(chatKey: chatKey)
            } else {
                chatKey = try await fireSide.startNewChat()
            }
        } catch {
            self.lastError = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
