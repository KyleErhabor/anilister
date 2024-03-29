//
//  ContentView.swift
//  AniLister
//
//  Created by Kyle Erhabor on 7/21/23.
//

import OSLog
import SafariServices
import SwiftUI

struct ContentView: View {
  @Environment(\.scenePhase) var scenePhase

  @AppStorage(UserDefaults.malClientIDKey, store: .group) private var malClientId = ""
  @AppStorage(UserDefaults.malRewriteKey, store: .group) private var onlyMalRewrite = false
  @State private var enabled: Bool?
  @State private var displayApiHelp = false
  @State private var displayMalRewriteHelp = false

  var body: some View {
    Form {
      if enabled == false {
        LabeledContent {
          Button("Enable...") {
            SFSafariApplication.showPreferencesForExtension(withIdentifier: Bundle.extensionIdentifier)
          }
        } label: {
          Label("AniLister is not enabled.", systemImage: "exclamationmark.triangle.fill")
            .symbolRenderingMode(.multicolor)
        }
      }

      LabeledContent("MyAnimeList API Client ID") {
        TextField("MyAnimeList API Client ID", text: $malClientId)
          .labelsHidden()
          .fontDesign(.monospaced)

        HelpButtonView {
          displayApiHelp.toggle()
        }.popover(isPresented: $displayApiHelp, arrowEdge: .trailing) {
          ScrollView {
            Text("""
For AniLister to retrieve synopses from MyAnimeList directly, the official API is used to communicate with the service.

While MyAnimeList's official API is public, the ID used to identify clients (here, AniLister) is considered private and \
can't be provided by default. To circumvent this limitation, AniLister provides two solutions:

• Leave this field blank, and AniLister will rely on [Jikan](https://jikan.moe/) to query MyAnimeList
• Create a client ID on MyAnimeList (following the instructions below) and provide it in the text field

Jikan is a third-party service which acts as a proxy between you and MyAnimeList. It's ideal if you don't have a \
MyAnimeList account or don't want to go through the API setup process below, but it may be unstable at times. A \
notable limitation is that line breaks are not used, causing synopses to appear as one long paragraph.

To create your own client ID,

`1.` [Login to MyAnimeList](https://myanimelist.net/)
`2.` [From your preferences, go to the API tab](https://myanimelist.net/apiconfig)
`3.` [Create a client ID](https://myanimelist.net/apiconfig/create) with the following information:

    **App Name** as "AniLister"
    **App Type** as other
    **App Description** as "Preview MyAnimeList data on AniList (currently anime and manga)."
    **App Redirect URL** as "https://localhost/" (note that, while this field is marked as required, AniLister does \
not utilize it)
    **Homepage URL** as "https://github.com/KyleErhabor/anilister"
    **Commercial / Non-Commercial** as non-commercial
    **Name / Company Name** as your own name
    **Purpose of Use** as hobbyist

`4.` Agree to the API License and Developer Agreement
`5.` Hit the submit button
`6.` After being redirected back to the API tab, click the edit button for the client you just created
`7.` Copy the client ID and paste it into the \"MyAnimeList API Client ID\" text field
""")
            .textSelection(.enabled)
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.leading)
            .padding()
          }.frame(width: 384, height: 256)
        }
      }

      Section {
        LabeledContent("Only use MAL Rewrite") {
          Toggle("Only use MAL Rewrite", isOn: $onlyMalRewrite)
            .labelsHidden()
            .toggleStyle(.switch)

          HelpButtonView {
            displayMalRewriteHelp.toggle()
          }.popover(isPresented: $displayMalRewriteHelp, arrowEdge: .trailing) {
            Text("""
MAL Rewrite is a project on MyAnimeList tasked with improving synopses on the service. You can limit AniLister to only \
replace a description if it's corresponding synopsis on MyAnimeList was written by the project.
""")
              .textSelection(.enabled)
              .foregroundStyle(Color.primary)
              .multilineTextAlignment(.leading)
              .padding()
              .frame(width: 384)
          }
        }
      }
    }
    .formStyle(.grouped)
    .frame(minWidth: 544, minHeight: 128)
    .onReceive(NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)) { _ in
      Task {
        enabled = await isExtensionEnabled()
      }
    }
  }

  func isExtensionEnabled() async -> Bool {
    do {
      let state = try await SFSafariExtensionManager.stateOfSafariExtension(withIdentifier: Bundle.extensionIdentifier)

      return state.isEnabled
    } catch {
      Logger.ui.error("Could not get Safari extension status: \(error)")

      return false
    }
  }
}
