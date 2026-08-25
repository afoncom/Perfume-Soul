//
//  TopSafeAreaBackground.swift
//  PerfumeSoul
//

import SwiftUI

struct TopSafeAreaBackground: ViewModifier {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content.overlay(alignment: .top) {
                GeometryReader { proxy in
                    Color(.backgroundPrimary)
                        .frame(height: proxy.safeAreaInsets.top)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .ignoresSafeArea(edges: .top)
                }
                .allowsHitTesting(false)
            }
        } else {
            content
        }
    }
}
