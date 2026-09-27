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
            VStack(alignment: .leading, spacing: 0) {
                makeHeaderView()
                    .padding(.bottom, 48)
                makeFormCard()
                makeContinueButton()
                    .padding(.top, 32)
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 180)
        }
        .background {
            Image(.calculationBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
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
            case .birthPlace:
                BirthPlaceSearchSheet(viewModel: viewModel, presenter: presenter)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

extension CalculationScreen {
    enum Field {
        case name
    }

    enum PickerSheet: Identifiable {
        case birthDate
        case birthTime
        case birthPlace

        var id: Self {
            self
        }
    }
}

extension CalculationScreen {
    func makeHeaderView() -> some View {
        Text(L10n.Screen.calculationCreateProfile)
            .font(.system(size: 34, weight: .regular, design: .serif))
            .foregroundStyle(Color(.textPrimary))
            .lineLimit(3)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func makeFormCard() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            makeNameField()
            Divider()
            makeBirthDateField()
            Divider()
            makeBirthTimeField()
            Divider()
            makeBirthPlaceField()
        }
    }
    
    func makeNameField() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Calculation.nameTitle)
                .font(.subheadline)
                .foregroundStyle(Color(.textPrimary))
            
            TextField(L10n.Calculation.namePlaceholder, text: $viewModel.firstName)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .font(.body)
                .foregroundStyle(Color(.textPrimary))
                .textInputAutocapitalization(.words)
                .onSubmit {
                    focusedField = nil
                    activePicker = .birthPlace
                }
        }
        .padding(.vertical, 16)
    }
    
    func makeBirthDateField() -> some View {
        makePickerButton(
            title: L10n.Calculation.birthDateTitle,
            value: viewModel.birthDate.formatted(.dateTime.day().month(.wide).year())
        ) {
            focusedField = nil
            activePicker = .birthDate
        }
    }
    
    func makeBirthTimeField() -> some View {
        makePickerButton(
            title: L10n.Calculation.birthTimeTitle,
            value: viewModel.birthTime.formatted(.dateTime.hour().minute())
        ) {
            focusedField = nil
            activePicker = .birthTime
        }
    }
    
    func makeBirthPlaceField() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Calculation.birthPlaceTitle)
                .font(.subheadline)
                .foregroundStyle(Color(.textPrimary))

            Button {
                focusedField = nil
                activePicker = .birthPlace
            } label: {
                Text(viewModel.birthPlace.isEmpty ? L10n.Calculation.birthPlacePlaceholder : viewModel.birthPlace)
                    .font(.body)
                    .foregroundStyle(viewModel.birthPlace.isEmpty ? Color(.descriptionText) : Color(.textPrimary))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
        }
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
                .foregroundStyle(Color(.backgroundPrimary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.textPrimary))
                .clipShape(Capsule())
        }
        .disabled(!viewModel.isContinueEnabled)
        .opacity(viewModel.isContinueEnabled ? 1 : 0.6)
    }
    
    // MARK: - Display info view
    func makePickerButton(
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color(.textPrimary))

                Text(value)
                    .font(.body)
                    .foregroundStyle(Color(.descriptionText))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct BirthPlaceSearchSheet: View {
    @Bindable private var viewModel: CalculationViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    @State private var query = ""
    @State private var didSelectPlace = false

    private let presenter: CalculationPresenter
    private let initialBirthPlace: String
    private let initialSelection: BirthPlaceSelection?

    init(viewModel: CalculationViewModel, presenter: CalculationPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
        initialBirthPlace = viewModel.birthPlace
        initialSelection = viewModel.selectedBirthPlace
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.Calculation.birthPlaceTitle)
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(Color(.textPrimary))
                .padding(.bottom, 16)

            makeSearchField()
                .padding(.bottom, 12)

            Divider()

            if let errorMessage = viewModel.birthPlaceErrorMessage {
                makeErrorView(message: errorMessage)
            }

            makeSuggestionsView()
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.backgroundPrimary))
        .task {
            isSearchFocused = true
        }
        .onChange(of: viewModel.birthPlaceErrorMessage) { _, errorMessage in
            guard let errorMessage else {
                return
            }

            AccessibilityNotification.Announcement(errorMessage).post()
        }
        .onDisappear {
            presenter.birthPlaceSearchDismissed()
            if !didSelectPlace {
                viewModel.birthPlace = initialBirthPlace
                viewModel.selectedBirthPlace = initialSelection
            }
        }
    }

    private var searchQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func makeSearchField() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(.descriptionText))
                .accessibilityHidden(true)

            TextField(L10n.Calculation.birthPlacePlaceholder, text: $query)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityLabel(L10n.Calculation.birthPlaceTitle)
                .task(id: "\(searchQuery)|\(viewModel.birthPlaceSearchRetryID)") {
                    try? await Task.sleep(for: .seconds(0.5))
                    guard !Task.isCancelled else {
                        return
                    }
                    guard !searchQuery.isEmpty || !viewModel.activeBirthPlaceSearchQuery.isEmpty else {
                        return
                    }
                    guard viewModel.activeBirthPlaceSearchQuery != searchQuery else {
                        return
                    }

                    await presenter.birthPlaceDidChange(searchQuery)
                }

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(.descriptionText))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.Calculation.birthPlaceClearSearch)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.placeholderSoft))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.inputBorder), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func makeSuggestionsView() -> some View {
        if searchQuery.count >= 2,
            viewModel.birthPlaceErrorMessage == nil || !viewModel.birthPlaceSuggestions.isEmpty {
            if viewModel.isSearchingBirthPlace || viewModel.activeBirthPlaceSearchQuery != searchQuery {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
            } else if viewModel.birthPlaceSuggestions.isEmpty {
                Text(L10n.Calculation.birthPlaceNoResults)
                    .font(.subheadline)
                    .foregroundStyle(Color(.descriptionText))
                    .padding(.top, 20)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.birthPlaceSuggestions.enumerated()), id: \.offset) { index, suggestion in
                            Button {
                                Task {
                                    let isStillCurrent = await presenter.birthPlaceSuggestionTapped(suggestion)
                                    guard isStillCurrent else {
                                        return
                                    }

                                    await MainActor.run {
                                        if viewModel.birthPlaceErrorMessage == nil {
                                            didSelectPlace = true
                                            isSearchFocused = false
                                            dismiss()
                                        }
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(suggestion.completion.title.isEmpty ? suggestion.displayName : suggestion.completion.title)
                                        .font(.system(size: 21, weight: .regular, design: .serif))
                                        .foregroundStyle(Color(.textPrimary))

                                    if !suggestion.completion.subtitle.isEmpty {
                                        Text(suggestion.completion.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(Color(.descriptionText))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if index < viewModel.birthPlaceSuggestions.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.never)
            }
        } else {
            Spacer(minLength: 0)
        }
    }

    private func makeErrorView(message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.destructiveAccent))
                .accessibilityHidden(true)

            Text(message)
                .font(.footnote)
                .foregroundStyle(Color(.destructiveAccent))

            Spacer(minLength: 0)

            if viewModel.canRetryBirthPlaceSearch {
                Button {
                    viewModel.birthPlaceSearchRetryID += 1
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(.destructiveAccent))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.Calculation.birthPlaceRetryButton)
            }
        }
        .padding(.vertical, 12)
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
