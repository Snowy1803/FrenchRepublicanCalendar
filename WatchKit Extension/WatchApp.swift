//
//  HostingController.swift
//  FrenchRepublicanCalendar WatchKit Extension
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WatchKit
import Foundation
import SwiftUI

@main
struct WatchApp: App {
    @WKApplicationDelegateAdaptor var appDelegate: ExtensionDelegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(favorites: appDelegate.favorites)
            }
        }
    }
}
