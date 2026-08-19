//
//  TopSafeAreaBackground.swift
//  PerfumeSoul
//

import SwiftUI

struct TopSafeAreaBackground: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if isEnabled {
                GeometryReader { proxy in
                    Color(.backgroundPrimary)
                        .frame(height: proxy.safeAreaInsets.top)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .ignoresSafeArea(edges: .top)
                }
                .allowsHitTesting(false)
            }
        }
    }
}
