//
//  HelpButtonView.swift
//  AniLister
//
//  Created by Kyle Erhabor on 7/23/23.
//

import SwiftUI

class HelpButton: NSButton {
  typealias Action = () -> Void

  var call: Action

  init(action: @escaping Action) {
    self.call = action

    super.init(frame: .zero)

    self.bezelStyle = .helpButton
    self.title = ""
    self.target = self
    self.action = #selector(click(_:))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func click(_ sender: HelpButton) {
    call()
  }
}

struct HelpButtonView: NSViewRepresentable {
  var action: HelpButton.Action

  func makeNSView(context: Context) -> HelpButton {
    HelpButton(action: action)
  }

  func updateNSView(_ nsView: HelpButton, context: Context) {}
}
