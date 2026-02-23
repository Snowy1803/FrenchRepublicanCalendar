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
import EventKit

@main
struct WatchApp: App {
    @WKApplicationDelegateAdaptor var appDelegate: ExtensionDelegate
    @StateObject private var eventStore = EventStore(store: EKEventStore())

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(Midnight.shared)
            .environmentObject(appDelegate.favorites)
            .environmentObject(eventStore)
        }
    }
}
