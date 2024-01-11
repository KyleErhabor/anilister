//
//  Standard.swift
//  AniLister
//
//  Created by Kyle Erhabor on 1/11/24.
//

import Foundation
import OSLog

extension Bundle {
  static let appIdentifier = "com.kyleerhabor.AniLister"
  static let teamIdentifier = "UY7357XWK6"
}

extension UserDefaults {
  static let group = UserDefaults(suiteName: "\(Bundle.teamIdentifier).\(Bundle.appIdentifier)")!

  static let malClientIDKey = "malClientId"
  static let malRewriteKey = "onlyMalRewrite"
}
