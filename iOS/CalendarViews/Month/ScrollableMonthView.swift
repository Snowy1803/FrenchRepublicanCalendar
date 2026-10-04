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
import Combine
import FrenchRepublicanCalendarCore
@_spi(Advanced) import SwiftUIIntrospect

struct ScrollableMonthView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var topItem: FrenchRepublicanDate
    @Binding var selection: FrenchRepublicanDate
    @State private var scrollToToday = false
    var selectYear: (FrenchRepublicanDate) -> ()

    var body: some View {
        ScrollableCalendarUIView(topItem: $topItem, selection: $selection, scrollToToday: $scrollToToday)
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationTitle(Text(topItem, format: .republicanDate.day(.monthOnly)))
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        selectYear(topItem)
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text(topItem, format: .republicanDate.year())
                        }
                    }
                }
                ToolbarItem(placement: .navigation) {
                    // In this size class, the navigation title isn't shown, except on iPhone Duo.
                    if sizeClass == .regular && UIDevice.current.userInterfaceIdiom != .phone {
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

extension ToolbarItem {
    @ToolbarContentBuilder func hideGroup() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            self.sharedBackgroundVisibility(.hidden) 
        } else {
            self
        }
    }
}

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
            vc.scrollToToday(animate: true)
            DispatchQueue.main.async {
                scrollToToday = false
            }
        }
    }
}

struct ScrollableCalendarCell: View {
    var month: FrenchRepublicanDate
    @Binding var selection: FrenchRepublicanDate

    @Environment(\.horizontalSizeClass) var sizeClass
    @AppStorage("frc-force-full-week", store: UserDefaults.shared) var forceFullWeek: Bool = false
    
    var halfWeek: Bool {
        sizeClass == .compact && !forceFullWeek
    }
    
    var body: some View {
        HStack {
            Text(month, format: .republicanDate.day(.monthOnly).year(.long))
                .lineLimit(1)
                .font(.headline)
            Spacer(minLength: 0)
        }
        .padding(.top)
        .padding()
        CalendarMonthView(month: month, selection: $selection, halfWeek: halfWeek, constantHeight: false)
    }
}

protocol ScrollableToToday {
    func scrollTo(date: FrenchRepublicanDate, animate: Bool)
}

extension ScrollableToToday {
    func scrollToToday(animate: Bool) {
        scrollTo(date: FrenchRepublicanDate(date: .now), animate: animate)
    }
}

class CustomScrollToTopCollectionView: UICollectionView {
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        // catch "scroll to top" action from TabBar, and change to scroll to today
        if contentOffset.x == 0 && contentOffset.y == -adjustedContentInset.top {
            (delegate as! ScrollableToToday).scrollToToday(animate: animated)
            return
        }
        super.setContentOffset(contentOffset, animated: animated)
    }
}

class ScrollableCalendarController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ScrollableToToday {
    enum MonthLayoutType: Hashable {
        case standard
        case sansculottidesRegular
        case sansculottidesSextil
    }

    var collectionView: UICollectionView!
    let collection = MonthCollection()
    var registration: UICollectionView.CellRegistration<UICollectionViewCell, FrenchRepublicanDate>!
    var topItem: Binding<FrenchRepublicanDate> = .constant(FrenchRepublicanDate(date: .now))
    var selection: Binding<FrenchRepublicanDate> = .constant(FrenchRepublicanDate(date: .now))
    var initialScroll = false
    private var sizeCache: [MonthLayoutType: CGFloat] = [:]
    private var cachedWidth: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setup()
        self.setupObservers()
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
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
    
    private func layoutType(for month: FrenchRepublicanDate) -> MonthLayoutType {
        if !month.isSansculottides {
            return .standard
        } else if month.isYearSextil {
            return .sansculottidesSextil
        } else {
            return .sansculottidesRegular
        }
    }
    
    private func setupObservers() {
        // Invalidate and reload when variant / midnight changes
        Midnight.shared.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.invalidateSizeCache()
            }
            .store(in: &cancellables)
    }
    
    func invalidateSizeCache() {
        sizeCache.removeAll()
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        invalidateSizeCache()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            invalidateSizeCache()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        guard width > 0 else {
            return CGSize(width: 390, height: 380)
        }
        
        if width != cachedWidth {
            cachedWidth = width
            sizeCache.removeAll()
        }
        
        let month = collection[indexPath.item]
        let type = layoutType(for: month)
        
        if let cachedHeight = sizeCache[type] {
            return CGSize(width: width, height: cachedHeight)
        }
        
        // Measure exact SwiftUI cell height using a prototype host controller
        let hostView = UIHostingController(rootView: ScrollableCalendarCell(month: month, selection: selection)).view!
        hostView.translatesAutoresizingMaskIntoConstraints = false
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let measuredSize = hostView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        let height = measuredSize.height > 0 ? measuredSize.height : 380
        sizeCache[type] = height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: collection[indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard initialScroll else { return }
        updateNavigationItem()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initialScroll {
            scrollTo(date: topItem.wrappedValue, animate: false)
            initialScroll = true
        }
    }
    
    func updateNavigationItem() {
        guard let path = collectionView.indexPathsForVisibleItems.min(),
              let attr = collectionView.layoutAttributesForItem(at: path)?.frame else {
            return
        }
        let item = self.collectionView.bounds.inset(by: self.collectionView.safeAreaInsets).intersects(attr) ? path.item : path.item + 1
        guard item < collection.count else { return }
        let month = collection[item]
        if topItem.wrappedValue != month {
            topItem.wrappedValue = month
        }
    }
    
    func scrollTo(date: FrenchRepublicanDate, animate: Bool) {
        collectionView.scrollToItem(at: IndexPath(item: date.monthIndex, section: 0), at: .top, animated: animate)
    }
}
