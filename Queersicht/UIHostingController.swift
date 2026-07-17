//
//  UIHostingController.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 13.07.2024.
//

import SwiftUI

class HostingController<Content: View>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        self.overrideUserInterfaceStyle = .light
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.overrideUserInterfaceStyle = .light
    }
}
