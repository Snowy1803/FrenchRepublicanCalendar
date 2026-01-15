//
//  EventVC.swift
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
import EventKit
import EventKitUI

struct EventDetailsView: View {
    var event: EKEvent
    
    @State private var showEdit: Bool = false

    var body: some View {
        EventVC(event: event)
            .ignoresSafeArea()
            .navigationTitle("Détails de l'évènement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Modifier") {
                        showEdit = true
                    }
                }
            }
            .sheet(isPresented: $showEdit) {
                NavigationView {
                    EditEventView(store: (UIApplication.shared.delegate as! AppDelegate).eventStore, event: event)
                }
            }
    }
}

struct EventVC: UIViewControllerRepresentable {
    typealias UIViewControllerType = EKEventViewController
    
    let event: EKEvent
    
    func makeUIViewController(context: Context) -> EKEventViewController {
        EKEventViewController()
    }
    
    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {
        uiViewController.event = event
    }
}
