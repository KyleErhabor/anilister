//
//  SafariExtensionHandler.swift
//  AniLister Extension
//
//  Created by Kyle Erhabor on 7/22/23.
//

import SafariServices
import OSLog

extension Logger {
  static let standard = Self()
}

extension URL {
  static let malAPIURL = Self(string: "https://api.myanimelist.net/v2")!
  static let jikanAPIURL = Self(string: "https://api.jikan.moe/v4")!
}

func malClientId() -> String? {
  guard let id = UserDefaults.group.string(forKey: UserDefaults.malClientIDKey),
        !id.isEmpty else {
    return nil
  }

  return id
}

class SafariExtensionHandler: SFSafariExtensionHandler {
  override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]? = nil) {
    guard messageName == "MALQuery" else {
      Logger.standard.error("Unknown message received: \(messageName)")

      return
    }

    guard let info = userInfo,
          let type = info["type"] as? String,
          let id = info["id"] as? Int else {
      Logger.standard.error("Info payload could not be extracted")

      return
    }

    Task {
      var request: URLRequest
      let clientId = malClientId()

      if let clientId {
        let url = URL.malAPIURL
          .appending(components: type, String(id))
          .appending(queryItems: [.init(name: "fields", value: "synopsis")])

        request = URLRequest(url: url)
        request.setValue(clientId, forHTTPHeaderField: "X-MAL-CLIENT-ID")
      } else {
        let url = URL.jikanAPIURL
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
          ? (body["data"] as? [String: Any])?["synopsis"]
          // MyAnimeList
          : body["synopsis"]
      // While Jikan doesn't do this, MyAnimeList does return empty synopses, which we don't want.
      ) as? String, !synopsis.isEmpty else {
        // If we couldn't get a synosis out of the body, do we really need to continue? Leaving the description alone
        // should be fine (though, it may be a bit confusing to a keen user).
        return
      }

      if UserDefaults.group.bool(forKey: UserDefaults.malRewriteKey) && !synopsis.contains("Written by MAL Rewrite") {
        return
      }

      let message = ["synopsis": synopsis]

      page.dispatchMessageToScript(withName: "MALResponse", userInfo: message)
    }
  }
}
