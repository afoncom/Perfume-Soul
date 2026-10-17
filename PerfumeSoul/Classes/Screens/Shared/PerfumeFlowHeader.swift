//
//  PerfumeFlowHeader.swift
//  PerfumeSoul
//

import SwiftUI

struct PerfumeFlowHeader: View {
    let section: String
    let step: Int?
    var showsBrand = true
    var title: String?

    @ScaledMetric(relativeTo: .headline) private var brandSize = 17
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 34

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            if showsBrand {
                Text("PERFUME SOUL")
                    .font(.system(size: brandSize, weight: .bold))
                    .tracking(-0.4)
            }

            if let title {
                Text(title)
                    .font(.system(size: titleSize, weight: .semibold))
                    .tracking(-0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
            }

            HStack(alignment: .firstTextBaseline) {
                Text(section.uppercased())
                    .font(.caption.weight(.medium))
                    .tracking(1)

                Spacer()

                if let step {
                    Text(String(format: "%02d / 03", step))
                        .font(.caption.monospacedDigit())
                }
            }
            .foregroundStyle(Color(.descriptionText))

            if let step {
                HStack(spacing: 5) {
                    ForEach(1...3, id: \.self) { index in
                        Rectangle()
                            .fill(Color(.textPrimary).opacity(index <= step ? 1 : 0.1))
                            .frame(height: 2)
                    }
                }
                .accessibilityHidden(true)
            }
        }
        .foregroundStyle(Color(.textPrimary))
    }
}
