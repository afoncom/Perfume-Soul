//
//  NatalChartRow.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.10.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//
import SwiftUI

struct NatalChartRow: View {
    private let color: Color
    private let symbol: String
    private let symbolColor: Color
    private let title: String
    private let placement: ZodiacPlacement
    private let horoscope: DailyHoroscope
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var signBadgeSize = 40.0
    
    init(
        color: Color, symbol: String, symbolColor: Color, title: String, placement: ZodiacPlacement
    ) {
        self.color = color
        self.symbol = symbol
        self.symbolColor = symbolColor
        self.title = title
        self.placement = placement
        self.horoscope = DailyHoroscope(sign: placement.sign.rawValue, energyOfDay: "")
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: symbol)
                        .font(.headline)
                        .foregroundColor(symbolColor)
                )
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.textPrimary))
                
                Text(horoscope.displayName)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color(.textPrimary))
            }
            
            Spacer()
            
            if !dynamicTypeSize.isAccessibilitySize {
                Text(horoscope.symbol)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(Color(.textPrimary))
                    .frame(width: signBadgeSize, height: signBadgeSize)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [
                    color.opacity(0.55),
                    Color(.rowBackground)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(symbolColor.opacity(0.12), lineWidth: 1)
        )
    }
}
