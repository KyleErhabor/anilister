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
let appGroupIdentifier = "UY7357XWK6.\(bundleIdentifier)"

let appGroupDefaults = UserDefaults(suiteName: appGroupIdentifier)

struct ContentView: View {
  @Environment(\.scenePhase) var scenePhase

  @AppStorage("malClientId", store: appGroupDefaults) private var malClientId = ""
  @AppStorage("onlyMalRewrite", store: appGroupDefaults) private var onlyMalRewrite = false
  @State private var isExtensionEnabled: Bool?
  @State private var displayApiHelp = false
  @State private var displayMalRewriteHelp = false

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
        TextField("MyAnimeList API Client ID", text: $malClientId)
          .labelsHidden()
          .fontDesign(.monospaced)

        HelpButtonView {
          displayApiHelp.toggle()
        }.popover(isPresented: $displayApiHelp, arrowEdge: .trailing) {
          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              Text("For AniLister to retrieve synopses from MyAnimeList directly, the official API is used to communicate with the service.")

              Text("While MyAnimeList's official API is public, the ID used to identify clients (here, AniLister) is considered private and can't be provided by default. To circumvent this limitation, AniLister provides two solutions:")

              VStack(alignment: .leading) {
                Text("• Leave this field blank, and AniLister will rely on [Jikan](https://jikan.moe/) to query MyAnimeList")
                Text("• Create a client ID on MyAnimeList (following the instructions below) and provide it in the text field")
              }

              Text("Jikan is a third-party service which acts as a proxy between you and MyAnimeList. It's ideal if you don't have a MyAnimeList account or don't want to go through the API setup process below, but it may be unstable at times. A notable limitation in the service is that line breaks are not used, causing synopses to appear as one long paragraph.")

              Text("To create your own client ID,")

              VStack(alignment: .leading) {
                Text("`1.` [Login to MyAnimeList](https://myanimelist.net/)")
                Text("`2.` [From your preferences, go to the API tab](https://myanimelist.net/apiconfig)")
                Text("`3.` [Create a client ID](https://myanimelist.net/apiconfig/create) with the following information:")

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

                Text("`4.` Agree to the API License and Developer Agreement")
                Text("`5.` Hit the submit button")
                Text("`6.` After being redirected back to the API tab, click the edit button for the client you just created")
                Text("`7.` Copy the client ID and paste it into the \"MyAnimeList API Client ID\" text field")
              }
            }
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
            Text("MAL Rewrite is a project on MyAnimeList tasked with improving synopses on the service. You can limit AniLister to only replace a description if it's corresponding synopsis on MyAnimeList was written by the project.")
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
