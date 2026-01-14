//
//  CreateEventVC.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 02/11/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
import Combine
import EventKit
import EventKitUI

struct CreateEventVC: UIViewControllerRepresentable {
    typealias UIViewControllerType = EKEventEditViewController
    
    let store: EKEventStore
    let date: FrenchRepublicanDate
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let vc = EKEventEditViewController()
        vc.editViewDelegate = context.coordinator
        return vc
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        let event = EKEvent(eventStore: store)
        event.startDate = date.date
        event.endDate = date.date
        event.timeZone = FrenchRepublicanDateOptions.current.currentTimeZone
        event.isAllDay = true
        uiViewController.event = event
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            controller.dismiss(animated: true)
        }
    }
}
