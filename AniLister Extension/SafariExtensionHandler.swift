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
let malBaseUrl = URL(string: "https://api.myanimelist.net/v2")!
let jikanBaseUrl = URL(string: "https://api.jikan.moe/v4")!

func malClientId() -> String? {
  guard let id = appGroupDefaults.string(forKey: "malClientId"),
        !id.isEmpty else {
    return nil
  }

  return id
}

class SafariExtensionHandler: SFSafariExtensionHandler {
  override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]? = nil) {
    guard messageName == "MALQuery" else {
      logger.warning("Unknown message received: \(messageName)")

      return
    }

    let info = userInfo!
    let type = info["type"] as! String
    let id = info["id"] as! Int

    Task {
      var request: URLRequest
      let clientId = malClientId()

      if let clientId {
        let url = malBaseUrl
          .appending(components: type, String(id))
          .appending(queryItems: [.init(name: "fields", value: "synopsis")])

        request = URLRequest(url: url)
        request.setValue(clientId, forHTTPHeaderField: "X-MAL-CLIENT-ID")
      } else {
        logger.info("ljdskajfsjdflksjdf: Using Jikan")

        let url = jikanBaseUrl
          .appending(components: type, String(id))

        request = URLRequest(url: url)
      }

      let (data, _) = try await URLSession.shared.data(for: request)

      guard let body = try JSONSerialization.jsonObject(with: data) as? [String : Any] else {
        return
      }

      guard let synopsis = (
        clientId == nil
          // Jikan
          ? (body["data"] as? [String : Any])?["synopsis"]
          // MyAnimeList
          : body["synopsis"]
      // While Jikan doesn't do this, MyAnimeList does return empty synopses, which we don't want.
      ) as? String, !synopsis.isEmpty else {
        // If we couldn't get a synosis out of the body, do we really need to continue? Leaving the description alone
        // should be fine (though, it may be a bit confusing to a keen user).
        return
      }

      if appGroupDefaults.bool(forKey: "onlyMalRewrite") && !synopsis.contains("Written by MAL Rewrite") {
        return
      }

      page.dispatchMessageToScript(withName: "MALResponse", userInfo: ["synopsis": synopsis])
    }
  }
}
