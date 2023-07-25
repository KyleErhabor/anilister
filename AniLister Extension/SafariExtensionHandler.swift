//
//  SafariExtensionHandler.swift
//  AniLister Extension
//
//  Created by Kyle Erhabor on 7/22/23.
//

import SafariServices
import os

let appGroupDefaults = UserDefaults(suiteName: "group.com.kyleerhabor.AniLister")!

let logger = Logger()
let malBaseUrl = {
  var url = URL(string: "https://api.myanimelist.net/v2")!
  url.append(queryItems: [.init(name: "fields", value: "synopsis")])

  return url
}()

class SafariExtensionHandler: SFSafariExtensionHandler {
  override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]? = nil) {
    guard messageName == "MALQuery" else {
      logger.warning("Unknown message received: \(messageName)")

      return
    }

    guard let clientId = appGroupDefaults.string(forKey: "malClientId"),
          !clientId.isEmpty else {
      logger.warning("No MyAnimeList API Client ID provided.")

      return
    }

    let info = userInfo!
    let type = info["type"] as! String
    let id = info["id"] as! Int
    let url = malBaseUrl
      .appending(path: type)
      .appending(path: String(id))

    Task {
      var request = URLRequest(url: url)
      request.setValue(clientId, forHTTPHeaderField: "X-MAL-CLIENT-ID")

      let (data, _) = try await URLSession.shared.data(for: request)

      guard let animanga = try JSONSerialization.jsonObject(with: data) as? [String : Any] else {
        return
      }

      if appGroupDefaults.bool(forKey: "onlyMalRewrite") && (animanga["synopsis"] as? String)?.contains("Written by MAL Rewrite") != true {
        return
      }

      page.dispatchMessageToScript(withName: "MALResponse", userInfo: animanga)
    }
  }
}
