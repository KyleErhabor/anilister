//
//  ContentView.swift
//  AniLister
//
//  Created by Kyle Erhabor on 7/21/23.
//

import SwiftUI
import SafariServices

let bundleIdentifier = Bundle.main.bundleIdentifier!
let extensionBundleIdentifier = "\(bundleIdentifier).Extension"
let appGroupIdentifier = "group.\(bundleIdentifier)"

let appGroupDefaults = UserDefaults(suiteName: appGroupIdentifier)

struct ContentView: View {
  @Environment(\.scenePhase) var scenePhase

  @AppStorage("malClientId", store: appGroupDefaults) private var malClientId = ""
  @AppStorage("onlyMalRewrite", store: appGroupDefaults) private var onlyMalRewrite = false
  @State private var isExtensionEnabled: Bool?
  @State private var shouldDisplayHelp = false

  var body: some View {
    Form {
      if isExtensionEnabled == false {
        LabeledContent {
          Button("Enable...") {
            SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier)
          }
        } label: {
          Label("AniLister is not enabled.", systemImage: "exclamationmark.triangle.fill")
            .symbolRenderingMode(.multicolor)
        }
      }

      LabeledContent("MyAnimeList API Client ID") {
        TextField(text: $malClientId) {}
          .labelsHidden()

        HelpButtonView {
          shouldDisplayHelp.toggle()
        }.popover(isPresented: $shouldDisplayHelp, arrowEdge: .trailing) {
          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              Text("AniLister relies on MyAnimeList's API to retrieve its descriptions (an API is a means for one process to communicate with another). While MyAnimeList's API is public, the ID used to identify the client (here, AniLister) is considered private and can't be provided by default. For AniLister to work, you'll need to create your own client and supply your own ID.")
              
              VStack(alignment: .leading) {
                Text("1. [Login to MyAnimeList](https://myanimelist.net/)")
                Text("2. [From your preferences, go to the API tab](https://myanimelist.net/apiconfig)")
                Text("3. [Create a client ID](https://myanimelist.net/apiconfig/create) with the following information:")
                
                Group {
                  Text("**App Name** as AniLister")
                  Text("**App Type** as other")
                  Text("**App Description** as \"Preview MyAnimeList data on AniList (currently anime and manga).\"")
                  Text("**App Redirect URL** as \"https://localhost/\" (note that, while this field is marked as required, AniLister does not utilize it)")
                  Text("**Homepage URL** as https://github.com/KyleErhabor/anilister")
                  Text("**Commercial / Non-Commercial** as non-commercial")
                  Text("**Name / Company Name** as your own name")
                  Text("**Purpose of Use** as hobbyist")
                }.padding(.leading, 16)

                Text("4. Agree to the API License and Developer Agreement")
                Text("5. Hit the submit button")
                Text("6. After being redirected back to the API tab, click the edit button for the client you just created")
                Text("7. Copy the client ID and paste it into AniLister's designated field")
              }
            }
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
            .padding()
          }
          .frame(width: 384, height: 256)
        }
      }

      Section {
        Toggle("Only use MAL Rewrite", isOn: $onlyMalRewrite)
      }
    }
    .formStyle(.grouped)
    .onReceive(NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)) { _ in
      Task {
        await checkExtensionEnabledState()
      }
    }
  }

  func checkExtensionEnabledState() async {
    do {
      let state = try await SFSafariExtensionManager.stateOfSafariExtension(withIdentifier: extensionBundleIdentifier)

      isExtensionEnabled = state.isEnabled
    } catch {
      // I currently don't see what could cause an error to be thrown.
      print(error)

      // Since we did not receive an explicit response, we're not sure if the extension is enabled at the moment.
      isExtensionEnabled = nil
    }
  }
}

#Preview {
  ContentView()
}
