//
//  CalculationScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct CalculationScreen: View {
    @Bindable private var viewModel: CalculationViewModel
    private let presenter: CalculationPresenter
    @FocusState private var focusedField: Field?
    @State private var activePicker: PickerSheet?
    
    init(
        viewModel: CalculationViewModel,
        presenter: CalculationPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                makeHeaderView()
                makeFormCard()
                makeContinueButton()
            }
            .padding(.horizontal, 20)
            .padding(.top, 36)
            .padding(.bottom, 24)
        }
        .background(Color(.backgroundPrimary))
        .modifier(TopSafeAreaBackground(isEnabled: true))
        .scrollDismissesKeyboard(.interactively)
        .sheet(item: $activePicker) { picker in
            switch picker {
            case .birthDate:
                BirthDatePickerSheet(date: $viewModel.birthDate)
                    .presentationDetents([.height(360)])
                    .presentationDragIndicator(.visible)
            case .birthTime:
                BirthTimePickerSheet(time: $viewModel.birthTime)
                    .presentationDetents([.height(320)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

extension CalculationScreen {
    enum Field {
        case name
        case birthPlace
    }

    enum PickerSheet: Identifiable {
        case birthDate
        case birthTime

        var id: Self {
            self
        }
    }
}

extension CalculationScreen {
    func makeHeaderView() -> some View {
        VStack(spacing: 12) {
            Text(L10n.Screen.calculationCreateProfile)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(L10n.Calculation.subtitle)
                .font(.title3)
                .foregroundStyle(Color(.textSecondary))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 12)
    }
    
    func makeFormCard() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            makeNameField()
            makeBirthDateField()
            makeBirthTimeField()
            makeBirthPlaceField()
        }
        .padding(22)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color(.cardShadowSoft), radius: 18, x: 0, y: 8)
    }
    
    func makeNameField() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Calculation.nameTitle)
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                
                TextField(L10n.Calculation.namePlaceholder, text: $viewModel.firstName)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .font(.title3)
                    .foregroundStyle(Color(.textPrimary))
                    .textInputAutocapitalization(.words)
                    .onSubmit {
                        focusedField = .birthPlace
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
    
    func makeBirthDateField() -> some View {
        makePickerButton(
            title: L10n.Calculation.birthDateTitle,
            systemImage: "calendar",
            value: viewModel.birthDate.formatted(.dateTime.day().month(.wide).year())
        ) {
            focusedField = nil
            activePicker = .birthDate
        }
    }
    
    func makeBirthTimeField() -> some View {
        makePickerButton(
            title: L10n.Calculation.birthTimeTitle,
            systemImage: "clock",
            value: viewModel.birthTime.formatted(.dateTime.hour().minute())
        ) {
            focusedField = nil
            activePicker = .birthTime
        }
    }
    
    func makeBirthPlaceField() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Calculation.birthPlaceTitle)
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                
                TextField(L10n.Calculation.birthPlacePlaceholder, text: $viewModel.birthPlace)
                    .focused($focusedField, equals: .birthPlace)
                    .submitLabel(.done)
                    .font(.title3)
                    .foregroundStyle(Color(.textPrimary))
                    .textInputAutocapitalization(.words)
                    .textContentType(.addressCity)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.birthPlace) { _, newValue in
                        if viewModel.selectedBirthPlace?.displayName != newValue {
                            viewModel.selectedBirthPlace = nil
                        }
                    }
                    .task(id: "\(focusedField == .birthPlace)|\(birthPlaceSearchQuery)|\(viewModel.birthPlaceSearchRetryID)") {
                        try? await Task.sleep(for: .seconds(0.5))
                        guard focusedField == .birthPlace && !Task.isCancelled else {
                            return
                        }
                        await presenter.birthPlaceDidChange(birthPlaceSearchQuery)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.inputBorder), lineWidth: 1)
            )

            if let birthPlaceErrorMessage = viewModel.birthPlaceErrorMessage {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(.destructiveAccent))
                        .accessibilityHidden(true)

                    Text(birthPlaceErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color(.destructiveAccent))

                    Spacer(minLength: 0)

                    Button {
                        focusedField = .birthPlace
                        viewModel.birthPlaceSearchRetryID += 1
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(.destructiveAccent))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.Calculation.birthPlaceRetryButton)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.destructiveSurface))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            let hasDropdownContent = viewModel.isSearchingBirthPlace
                || !viewModel.birthPlaceSuggestions.isEmpty
                || viewModel.activeBirthPlaceSearchQuery == birthPlaceSearchQuery

            if focusedField == .birthPlace, birthPlaceSearchQuery.count >= 2, hasDropdownContent {
                VStack(spacing: 0) {
                    if viewModel.isSearchingBirthPlace, viewModel.birthPlaceSuggestions.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    } else if viewModel.birthPlaceSuggestions.isEmpty,
                              viewModel.activeBirthPlaceSearchQuery == birthPlaceSearchQuery {
                        Text(L10n.Calculation.birthPlaceNoResults)
                            .font(.subheadline)
                            .foregroundStyle(Color(.textSecondary))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }

                    if viewModel.activeBirthPlaceSearchQuery == birthPlaceSearchQuery {
                        ForEach(Array(viewModel.birthPlaceSuggestions.prefix(5).enumerated()), id: \.offset) { index, suggestion in
                            Button {
                                Task {
                                    await presenter.birthPlaceSuggestionTapped(suggestion)
                                    await MainActor.run {
                                        focusedField = viewModel.birthPlaceErrorMessage == nil ? nil : .birthPlace
                                    }
                                }
                            } label: {
                                Text(suggestion.displayName)
                                    .font(.headline)
                                    .foregroundStyle(Color(.textPrimary))
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)

                            if index < min(viewModel.birthPlaceSuggestions.count, 5) - 1 {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
                .background(Color(.surfacePrimary))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(.inputBorder), lineWidth: 1)
                )
            }
        }
        .onChange(of: viewModel.birthPlaceErrorMessage) { _, birthPlaceErrorMessage in
            guard let birthPlaceErrorMessage else {
                return
            }

            AccessibilityNotification.Announcement(birthPlaceErrorMessage).post()
        }
    }

    var birthPlaceSearchQuery: String {
        viewModel.birthPlace.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Continue Button
    func makeContinueButton() -> some View {
        Button {
            Task {
                await presenter.continueButtonTapped()
            }
        } label: {
            Text(L10n.Common.continueButton)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Color(.textOnAccent))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.pinkButton))
                .clipShape(Capsule())
        }
        .disabled(!viewModel.isContinueEnabled)
        .opacity(viewModel.isContinueEnabled ? 1 : 0.6)
        .shadow(color: Color(.buttonShadow), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Display info view
    func makePickerButton(
        title: String,
        systemImage: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)

            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: systemImage)
                        .font(.headline)
                        .foregroundStyle(Color(.textPrimary))

                    Text(value)
                        .font(.title3)
                        .foregroundStyle(Color(.textPrimary))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(Color(.textSecondary))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.surfacePrimary))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(.inputBorder), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct BirthDatePickerSheet: View {
    @Binding private var date: Date
    @Environment(\.dismiss) private var dismiss
    @State private var day: Int
    @State private var month: Int
    @State private var year: Int

    init(date: Binding<Date>) {
        _date = date

        let components = Self.calendar.dateComponents([.day, .month, .year], from: date.wrappedValue)
        _day = State(initialValue: components.day ?? 1)
        _month = State(initialValue: components.month ?? 1)
        _year = State(initialValue: components.year ?? Self.currentYear)
    }

    var body: some View {
        VStack(spacing: 18) {
            makeSheetHeader(title: L10n.Calculation.birthDateTitle) {
                applySelection()
            }

            HStack(spacing: 0) {
                ForEach(Self.dateComponentOrder, id: \.self) { component in
                    makeDateComponentPicker(component)
                }
            }
            .frame(height: 190)
            .onChange(of: month) { _, _ in
                clampDay()
            }
            .onChange(of: year) { _, _ in
                clampDay()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 8)
    }

    private var daysInSelectedMonth: Int {
        let components = DateComponents(year: year, month: month)
        let date = Self.calendar.date(from: components) ?? Date()
        return Self.calendar.range(of: .day, in: .month, for: date)?.count ?? 31
    }

    private var years: [Int] {
        Array((1900...Self.currentYear).reversed())
    }

    private func clampDay() {
        day = min(day, daysInSelectedMonth)
    }

    private func applySelection() {
        let components = DateComponents(year: year, month: month, day: day)
        if let selectedDate = Self.calendar.date(from: components) {
            date = selectedDate
        }

        dismiss()
    }

    @ViewBuilder
    private func makeDateComponentPicker(_ component: DateComponent) -> some View {
        switch component {
        case .day:
            makeWheelPicker(
                selection: $day,
                values: 1...daysInSelectedMonth,
                accessibilityLabel: localized("calculation.picker.day")
            )
        case .month:
            makeWheelPicker(
                selection: $month,
                values: 1...12,
                accessibilityLabel: localized("calculation.picker.month")
            ) { value in
                Self.monthFormatter.standaloneMonthSymbols[value - 1]
            }
        case .year:
            makeWheelPicker(
                selection: $year,
                values: years,
                accessibilityLabel: localized("calculation.picker.year")
            )
        }
    }

    private enum DateComponent: Character {
        case day = "d"
        case month = "M"
        case year = "y"
    }

    private static let dateComponentOrder: [DateComponent] = {
        let format = DateFormatter.dateFormat(fromTemplate: "yMMMd", options: 0, locale: .current) ?? "dMy"
        let order = format.compactMap { DateComponent(rawValue: $0) }.reduce(into: [DateComponent]()) { result, component in
            if !result.contains(component) {
                result.append(component)
            }
        }

        return order.isEmpty ? [.day, .month, .year] : order
    }()

    private static let calendar = Calendar(identifier: .gregorian)
    private static let currentYear = calendar.component(.year, from: Date())
    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = .current
        return formatter
    }()
}

private struct BirthTimePickerSheet: View {
    @Binding private var time: Date
    @Environment(\.dismiss) private var dismiss
    @State private var hour: Int
    @State private var minute: Int
    @State private var period: Int

    init(time: Binding<Date>) {
        _time = time

        let components = Self.calendar.dateComponents([.hour, .minute], from: time.wrappedValue)
        let hour = components.hour ?? 12
        _hour = State(initialValue: Self.usesTwelveHourClock ? Self.twelveHourValue(from: hour) : hour)
        _minute = State(initialValue: components.minute ?? 0)
        _period = State(initialValue: hour >= 12 ? 1 : 0)
    }

    var body: some View {
        VStack(spacing: 18) {
            makeSheetHeader(title: L10n.Calculation.birthTimeTitle) {
                applySelection()
            }

            HStack(spacing: 0) {
                if Self.usesTwelveHourClock {
                    makeWheelPicker(
                        selection: $hour,
                        values: 1...12,
                        accessibilityLabel: localized("calculation.picker.hour")
                    )
                } else {
                    makeWheelPicker(
                        selection: $hour,
                        values: 0...23,
                        accessibilityLabel: localized("calculation.picker.hour")
                    )
                }
                makeWheelPicker(
                    selection: $minute,
                    values: 0...59,
                    accessibilityLabel: localized("calculation.picker.minute")
                )
                if Self.usesTwelveHourClock {
                    makePeriodPicker()
                }
            }
            .frame(height: 170)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 8)
    }

    private func applySelection() {
        let selectedTime = Self.calendar.date(
            bySettingHour: Self.usesTwelveHourClock ? twentyFourHourValue : hour,
            minute: minute,
            second: 0,
            of: time
        )

        if let selectedTime {
            time = selectedTime
        }

        dismiss()
    }

    private var twentyFourHourValue: Int {
        if period == 0 {
            return hour == 12 ? 0 : hour
        }

        return hour == 12 ? 12 : hour + 12
    }

    private func makePeriodPicker() -> some View {
        Picker("", selection: $period) {
            ForEach(0...1, id: \.self) { value in
                Text(value == 0 ? Self.periodFormatter.amSymbol : Self.periodFormatter.pmSymbol)
                    .font(.title2)
                    .tag(value)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .accessibilityLabel(localized("calculation.picker.period"))
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private static func twelveHourValue(from hour: Int) -> Int {
        let value = hour % 12
        return value == 0 ? 12 : value
    }

    private static let usesTwelveHourClock: Bool = {
        let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: .current) ?? ""
        return format.contains("a")
    }()

    private static let calendar = Calendar(identifier: .gregorian)
    private static let periodFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        return formatter
    }()
}

private func makeSheetHeader(
    title: String,
    onDone: @escaping () -> Void
) -> some View {
    HStack {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(Color(.textPrimary))

        Spacer()

        Button(localized("calculation.picker.doneButton"), action: onDone)
            .font(.headline)
            .foregroundStyle(Color(.pinkButton))
    }
}

private func makeWheelPicker<Values: RandomAccessCollection>(
    selection: Binding<Int>,
    values: Values,
    accessibilityLabel: String,
    title: ((Int) -> String)? = nil
) -> some View where Values.Element == Int {
    Picker("", selection: selection) {
        ForEach(values, id: \.self) { value in
            Text(title?(value) ?? String(format: "%02d", value))
                .font(.title2)
                .tag(value)
        }
    }
    .pickerStyle(.wheel)
    .labelsHidden()
    .accessibilityLabel(accessibilityLabel)
    .frame(maxWidth: .infinity)
    .clipped()
}

private func localized(_ key: String) -> String {
    String(localized: String.LocalizationValue(key))
}
