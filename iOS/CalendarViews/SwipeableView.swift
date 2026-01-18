//
//  SwipeableView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 18/01/2026.
//  Copyright © 2026 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI
import FrenchRepublicanCalendarCore

// Based on RepublicanDatePicker. RepublicanDatePicker should probably be refactored to use this, but it has many additional accessibility attributes, previous/next buttons, and an overlay that disables the behaviour.
struct SwipeableView<Item: Hashable, ItemView: View>: View {
    @Binding var current: Item
    @State private var dragOffset: CGFloat = 0
    @State private var width: CGFloat = 0
    
    var previousItem: Item
    var nextItem: Item
    var previousValid: Bool
    var nextValid: Bool
    var renderer: (Item) -> ItemView

    var body: some View {
        ZStack {
            renderer(previousItem)
                .id(previousItem)
                .offset(x: -width)
                .accessibilityHidden(true)
            renderer(current)
                .id(current)
            renderer(nextItem)
                .id(nextItem)
                .offset(x: width)
                .accessibilityHidden(true)
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear { width = geo.size.width }
                    .onChange(of: geo.size.width) { width = $0 }
            }
        }
        .offset(x: dragOffset)
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 10).onChanged { value in
                dragOffset = value.translation.width
                if (dragOffset > 0 && !previousValid) || (dragOffset < 0 && !nextValid) {
                    dragOffset *= 0.2
                }
            }.onEnded { value in
                let threshold = width / 2
                let forward: Bool?
                if value.predictedEndTranslation.width < -threshold {
                    forward = true
                } else if value.predictedEndTranslation.width > threshold {
                    forward = false
                } else {
                    forward = nil
                }
                swipe(
                    animation: .interpolatingSpring(
                        stiffness: 170,
                        damping: 20,
                        initialVelocity: value.velocity.width / width
                    ),
                    forward: forward
                )
            },
            isEnabled: true
        )
    }
    
    func swipe(animation: Animation, forward _forward: Bool?) {
        var forward: Bool? {
            switch _forward {
            case true where !nextValid: nil
            case false where !previousValid: nil
            case let forward: forward
            }
        }
        func animated() {
            switch forward {
            case true: dragOffset = -width
            case false: dragOffset = width
            case nil: dragOffset = 0
            }
        }
        func end() {
            if let forward {
                dragOffset = 0
                if forward {
                    current = nextItem
                } else {
                    current = previousItem
                }
            }
        }
        if #available(iOS 17.0, *) {
            withAnimation(animation) {
                animated()
            } completion: {
                end()
            }
        } else {
            withAnimation(animation) {
                animated()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                end()
            }
        }
    }
}
