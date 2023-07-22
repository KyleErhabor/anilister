//
//  SafariExtensionViewController.swift
//  AniLister Extension
//
//  Created by Kyle Erhabor on 7/21/23.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
