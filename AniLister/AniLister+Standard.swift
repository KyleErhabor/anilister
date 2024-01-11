//
//  AniLister+Standard.swift
//  AniLister
//
//  Created by Kyle Erhabor on 1/11/24.
//

import Foundation
import OSLog

extension Bundle {
  static let identifier = Bundle.main.bundleIdentifier!
  static let extensionIdentifier = "\(identifier).Extension"
}

extension Logger {
  static let ui = Self(subsystem: Bundle.identifier, category: "UI")
}
