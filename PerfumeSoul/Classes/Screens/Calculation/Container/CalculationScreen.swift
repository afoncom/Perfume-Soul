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
                    .task(id: viewModel.birthPlace) {
                        try? await Task.sleep(for: .seconds(0.5))
                        guard focusedField == .birthPlace && !Task.isCancelled else {
                            return
                        }
                        await presenter.birthPlaceDidChange(viewModel.birthPlace)
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
            
            if focusedField == .birthPlace, !viewModel.birthPlaceCompletions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.birthPlaceCompletions.prefix(5).enumerated()), id: \.offset) { index, completion in
                        Button {
                            focusedField = nil
                            Task {
                                await presenter.birthPlaceCompletionTapped(completion)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(BirthPlaceNameFormatter.format(
                                    title: completion.title,
                                    subtitle: completion.subtitle
                                ))
                                    .font(.headline)
                                    .foregroundStyle(Color(.textPrimary))
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        
                        if index < min(viewModel.birthPlaceCompletions.count, 5) - 1 {
                            Divider()
                                .padding(.leading, 16)
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
                makeWheelPicker(selection: $day, values: 1...daysInSelectedMonth)
                makeWheelPicker(selection: $month, values: 1...12) { value in
                    Self.monthFormatter.monthSymbols[value - 1]
                }
                makeWheelPicker(selection: $year, values: years)
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

    init(time: Binding<Date>) {
        _time = time

        let components = Self.calendar.dateComponents([.hour, .minute], from: time.wrappedValue)
        _hour = State(initialValue: components.hour ?? 12)
        _minute = State(initialValue: components.minute ?? 0)
    }

    var body: some View {
        VStack(spacing: 18) {
            makeSheetHeader(title: L10n.Calculation.birthTimeTitle) {
                applySelection()
            }

            HStack(spacing: 0) {
                makeWheelPicker(selection: $hour, values: 0...23)
                makeWheelPicker(selection: $minute, values: 0...59)
            }
            .frame(height: 170)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 8)
    }

    private func applySelection() {
        let selectedTime = Self.calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: time
        )

        if let selectedTime {
            time = selectedTime
        }

        dismiss()
    }

    private static let calendar = Calendar(identifier: .gregorian)
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
    .frame(maxWidth: .infinity)
    .clipped()
}

private func localized(_ key: String) -> String {
    String(localized: String.LocalizationValue(key))
}
