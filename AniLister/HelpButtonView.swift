//
//  HelpButtonView.swift
//  AniLister
//
//  Created by Kyle Erhabor on 7/23/23.
//

import SwiftUI

class HelpButton: NSButton {
  typealias Action = () -> Void

  var perform: Action

  init(action: @escaping Action) {
    self.perform = action

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
    perform()
  }
}

struct HelpButtonView: NSViewRepresentable {
  var action: HelpButton.Action

  func makeNSView(context: Context) -> HelpButton {
    .init(action: action)
  }

  func updateNSView(_ buttonView: HelpButton, context: Context) {
    buttonView.perform = action
  }
}
