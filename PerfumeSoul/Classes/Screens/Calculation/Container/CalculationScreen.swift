//
//  CalculationScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import MapKit
import SwiftUI

struct CalculationScreen: View {
    @Bindable private var viewModel: CalculationViewModel
    private let presenter: CalculationPresenter
    @FocusState private var focusedField: Field?
    @StateObject private var birthPlaceSearch = BirthPlaceSearchCompleter()
    
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
        .background(Color.white)
        .scrollDismissesKeyboard(.interactively)
    }
}

private extension CalculationScreen {
    enum Field {
        case name
        case birthPlace
    }
}

private extension CalculationScreen {
    func makeHeaderView() -> some View {
        VStack(spacing: 12) {
            Text("Create your profile")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Enter your birth details to unlock personalized insights.")
                .font(.title3)
                .foregroundStyle(.secondary)
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 8)
    }
    
    func makeNameField() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Name")
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .font(.headline)
                    .foregroundStyle(.black)
                
                TextField("Your first name", text: $viewModel.firstName)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .textInputAutocapitalization(.words)
                    .onSubmit {
                        focusedField = .birthPlace
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
    
    func makeBirthDateField() -> some View {
        makePickerField(
            title: "Birth Date",
            systemImage: "calendar",
            iconColor: .black
        ) {
            DatePicker(
                "",
                selection: $viewModel.birthDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
    }
    
    func makeBirthTimeField() -> some View {
        makePickerField(
            title: "Birth Time",
            systemImage: "clock",
            iconColor: .black
        ) {
            DatePicker(
                "",
                selection: $viewModel.birthTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
    }
    
    func makeBirthPlaceField() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Birth Place")
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .font(.headline)
                    .foregroundStyle(.black)
                
                TextField("Enter city or town", text: $viewModel.birthPlace)
                    .focused($focusedField, equals: .birthPlace)
                    .submitLabel(.done)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .textInputAutocapitalization(.words)
                    .textContentType(.addressCity)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.birthPlace) { _, newValue in
                        birthPlaceSearch.updateQuery(newValue)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            
            if focusedField == .birthPlace, !birthPlaceSearch.completions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(birthPlaceSearch.completions.prefix(5).enumerated()), id: \.offset) { index, completion in
                        Button {
                            viewModel.birthPlace = birthPlaceSearch.formattedTitle(for: completion)
                            birthPlaceSearch.clear()
                            focusedField = nil
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(completion.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if !completion.subtitle.isEmpty {
                                    Text(completion.subtitle)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        
                        if index < min(birthPlaceSearch.completions.count, 5) - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }
    
    //MARK: - Continue Button
    func makeContinueButton() -> some View {
        Button {
            presenter.continueButtonTapped()
        } label: {
            Text("Continue")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.pinkButton)
                .clipShape(Capsule())
        }
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    //MARK: - Display info view
    func makePickerField<Content: View>(
        title: String,
        systemImage: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(iconColor)
                
                content()
                    .font(.title3)
                    .tint(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
}

private final class BirthPlaceSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published private(set) var completions: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func updateQuery(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedQuery.count >= 2 else {
            clear()
            return
        }
        
        completer.queryFragment = trimmedQuery
    }
    
    func clear() {
        completions = []
    }
    
    func formattedTitle(for completion: MKLocalSearchCompletion) -> String {
        guard !completion.subtitle.isEmpty else { return completion.title }
        return "\(completion.title), \(completion.subtitle)"
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        completions = []
    }
}
