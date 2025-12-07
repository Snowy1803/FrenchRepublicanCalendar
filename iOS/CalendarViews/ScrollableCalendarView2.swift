//
//  ScrollableCalendarView.swift
//  FrenchRepublicanCalendar
// 
//  Created by Emil Pedersen on 02/12/2025.
//  Copyright © 2025 Snowy_1803. All rights reserved.
// 
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import FrenchRepublicanCalendarCore
@_spi(Advanced) import SwiftUIIntrospect

@available(iOS 16.0, *)
struct ScrollableCalendarView2: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var topItem = FrenchRepublicanDate(date: .now)
    @State private var selection = FrenchRepublicanDate(date: .now)
    @State private var scrollToToday = false

    var body: some View {
        ScrollableCalendarUIView(topItem: $topItem, selection: $selection, scrollToToday: $scrollToToday)
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text(topItem, format: .republicanDate.day(.monthOnly)))
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        scrollToToday = true
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text(topItem, format: .republicanDate.year())
                        }
                    }
                }
                ToolbarItem(placement: .navigation) {
                    if sizeClass == .regular { // In this size class, the navigation title isn't shown
                        Text(topItem, format: .republicanDate.day(.monthOnly))
                            .font(.headline)
                            .fixedSize()
                    }
                }.hideGroup()
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        scrollToToday = true
                    } label: {
                        Text("Aujourd'hui")
                    }
                }
            }
    }
}

@available(iOS 16.0, *)
extension ToolbarItem {
    @ToolbarContentBuilder func hideGroup() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            self.sharedBackgroundVisibility(.hidden) 
        } else {
            self
        }
    }
}

@available(iOS 16.0, *)
struct ScrollableCalendarUIView: UIViewControllerRepresentable {
    var topItem: Binding<FrenchRepublicanDate>
    var selection: Binding<FrenchRepublicanDate>
    @Binding var scrollToToday: Bool

    func makeUIViewController(context: Context) -> ScrollableCalendarController {
        ScrollableCalendarController()
    }
    func updateUIViewController(_ vc: ScrollableCalendarController, context: Context) {
        vc.topItem = topItem
        vc.selection = selection
        if scrollToToday {
            scrollToToday = false
            vc.scrollToToday(animate: true)
        }
    }
}

struct ScrollableCalendarCell: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    var month: FrenchRepublicanDate
    @Binding var selection: FrenchRepublicanDate

    var body: some View {
        HStack {
            Text(month, format: .republicanDate.day(.monthOnly).year(.long))
                .lineLimit(1)
                .font(.headline)
            Spacer(minLength: 0)
        }
        .padding(.top)
        .padding()
        CalendarMonthView(month: month, selection: $selection, halfWeek: sizeClass == .compact, constantHeight: false)
    }
}

@available(iOS 16.0, *)
class CustomScrollToTopCollectionView: UICollectionView {
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        // catch "scroll to top" action from TabBar, and change to scroll to today
        if contentOffset.x == 0 && contentOffset.y == -adjustedContentInset.top {
            (delegate as! ScrollableCalendarController).scrollToToday(animate: animated)
            return
        }
        super.setContentOffset(contentOffset, animated: animated)
    }
}

@available(iOS 16.0, *)
class ScrollableCalendarController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    let collection = MonthCollection()
    var registration: UICollectionView.CellRegistration<UICollectionViewCell, FrenchRepublicanDate>!
    var topItem: Binding<FrenchRepublicanDate> = .constant(FrenchRepublicanDate(date: .now))
    var selection: Binding<FrenchRepublicanDate> = .constant(FrenchRepublicanDate(date: .now))
    var initialScroll = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let collectionView = CustomScrollToTopCollectionView(frame: .zero, collectionViewLayout: setupLayout())
        collectionView.delegate = self
        registration = UICollectionView.CellRegistration { cell, indexPath, month in
            cell.contentConfiguration = UIHostingConfiguration {
                ScrollableCalendarCell(month: month, selection: self.selection)
            }
        }
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        self.collectionView = collectionView
        self.view = collectionView
    }
    
    func setupLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(380))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: collection[indexPath.item])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initialScroll {
            initialScroll = true
            scrollToToday(animate: false)
        }
    }
    
    func updateNavigationItem() {
        guard let path = collectionView.indexPathsForVisibleItems.min(),
              let attr = collectionView.layoutAttributesForItem(at: path)?.frame else {
            return
        }
        let item = self.collectionView.bounds.inset(by: self.collectionView.safeAreaInsets).intersects(attr) ? path.item : path.item + 1
        let month = collection[item]
        if topItem.wrappedValue != month {
            topItem.wrappedValue = month
        }
    }
    
    func scrollToToday(animate: Bool) {
        let today = FrenchRepublicanDate(date: .now).monthIndex
        collectionView.scrollToItem(at: IndexPath(item: today, section: 0), at: .top, animated: animate)
    }
}
