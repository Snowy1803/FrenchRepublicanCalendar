//
//  LayoutGuidesSwiftUI.swift
//
//

import SwiftUI

struct ReadableContentGuidesKey: EnvironmentKey {
    static var defaultValue: EdgeInsets { .init() }
}

extension EnvironmentValues {
    var readableContentInsets: EdgeInsets {
        get { self[ReadableContentGuidesKey.self] }
        set { self[ReadableContentGuidesKey.self] = newValue }
    }
}

struct ReadableContentMeasuringModifier: ViewModifier {
    @State var readableContentInsets: EdgeInsets = .init()
    
    func body(content: Content) -> some View {
        content
            .environment(\.readableContentInsets, readableContentInsets)
            .background(
                LayoutGuides(onReadableContentGuideChange: {
                    readableContentInsets = $0
                })
            )
    }
}

struct LayoutGuides: UIViewRepresentable {
    let onReadableContentGuideChange: (EdgeInsets) -> Void
    
    func makeUIView(context: Context) -> LayoutGuidesView {
        let uiView = LayoutGuidesView()
        uiView.onReadableContentGuideChange = onReadableContentGuideChange
        return uiView
    }
    
    func updateUIView(_ uiView: LayoutGuidesView, context: Context) {
        uiView.onReadableContentGuideChange = onReadableContentGuideChange
    }
    
    final class LayoutGuidesView: UIView {
        var onReadableContentGuideChange: (EdgeInsets) -> Void = { _ in }
        
        override func layoutMarginsDidChange() {
            super.layoutMarginsDidChange()
            updateReadableContent()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            updateReadableContent()
        }
        
        func updateReadableContent() {
            let isRightToLeft = traitCollection.layoutDirection == .rightToLeft
            let layoutFrame = readableContentGuide.layoutFrame
            
            let readableContentInsets =
            UIEdgeInsets(
                top: layoutFrame.minY - bounds.minY,
                left: layoutFrame.minX - bounds.minX,
                bottom: -(layoutFrame.maxY - bounds.maxY),
                right: -(layoutFrame.maxX - bounds.maxX)
            )
            let edgeInsets = EdgeInsets(
                top: readableContentInsets.top,
                leading: isRightToLeft ? readableContentInsets.right : readableContentInsets.left,
                bottom: readableContentInsets.bottom,
                trailing: isRightToLeft ? readableContentInsets.left : readableContentInsets.right
            )
            onReadableContentGuideChange(edgeInsets)
        }
    }
}

struct ReadableContentFollowingModifier: ViewModifier {
    @Environment(\.readableContentInsets) var readableContentInsets

    func body(content: Content) -> some View {
        content.padding(readableContentInsets)
    }
}
