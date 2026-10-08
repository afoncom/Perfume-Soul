//
//  PerfumeFlowHeader.swift
//  PerfumeSoul
//

import SwiftUI

struct PerfumeFlowHeader: View {
    let section: String
    let step: Int?

    @ScaledMetric(relativeTo: .headline) private var brandSize = 17

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("PERFUME SOUL")
                .font(.system(size: brandSize, weight: .bold))
                .tracking(-0.4)

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
