//
//  PerfumeStudioBanner.swift
//  PerfumeSoul
//

import SwiftUI

struct PerfumeStudioBanner: View {
    let title: String
    let caption: String
    var showsProgress = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 32
    @ScaledMetric(relativeTo: .largeTitle) private var progressSize = 58

    var body: some View {
        Group {
            if dynamicTypeSize >= .xLarge {
                bannerText
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color(.textPrimary).opacity(0.035))
            } else {
                GeometryReader { geometry in
                    Image(.perfumeStudioPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .accessibilityHidden(true)
                        .overlay(alignment: .leading) {
                            bannerText
                                .frame(width: geometry.size.width * 0.52, alignment: .leading)
                                .padding(.leading, 20)
                        }
                }
                .aspectRatio(1.65, contentMode: .fit)
            }
        }
        .foregroundStyle(Color(.textPrimary))
    }

    private var bannerText: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(caption.uppercased())
                .font(.caption2.weight(.medium))
                .tracking(0.7)
                .fixedSize(horizontal: false, vertical: true)

            Text(title)
                .font(.system(size: showsProgress ? progressSize : titleSize, weight: .semibold))
                .tracking(-1.4)
                .monospacedDigit()
                .contentTransition(.numericText())
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
