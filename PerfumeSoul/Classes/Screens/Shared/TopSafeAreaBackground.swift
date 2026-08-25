//
//  TopSafeAreaBackground.swift
//  PerfumeSoul
//

import SwiftUI

struct TopSafeAreaBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
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
