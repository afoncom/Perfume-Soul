//
//  DiscoverScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct DiscoverScreen: View {
    @Bindable private var viewModel: DiscoverViewModel
    private let presenter: DiscoverPresenter
    @State private var perfumeAName = ""
    @State private var perfumeBName = ""
    @FocusState private var focusedField: FocusedField?
    private let primaryButtonColor = Color(red: 0.95, green: 0.74, blue: 0.80)
    
    init(
        viewModel: DiscoverViewModel,
        presenter: DiscoverPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                makeFindYourScentArchetype()
                    .padding(.horizontal, 16)
                
                makeComparePerfumes()
                    .padding(.horizontal, 16)
                
                makeFindSimilarPerfumes()
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
    }
}

private extension DiscoverScreen {
    func makeFindYourScentArchetype() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Find Your Scent Archetype")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.gray.opacity(0.12))
                    .frame(maxWidth: .infinity)
                    .frame(height: 170)
                
                Button("Start quiz") {
                    presenter.startQuizButtonTab()
                }
                .primaryCapsuleButton(color: primaryButtonColor)
                .padding(.horizontal, 28)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    func makeComparePerfumes() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Compare Perfumes")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                makePerfumeInput(
                    title: "Perfume A",
                    text: $perfumeAName,
                    field: .perfumeA
                )
                
                makePerfumeInput(
                    title: "Perfume B",
                    text: $perfumeBName,
                    field: .perfumeB
                )
                
                Button("Compare") {
                    presenter.comparePerfumesButtonTab()
                }
                .primaryCapsuleButton(color: primaryButtonColor)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    func makeFindSimilarPerfumes() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Find Similar Perfumes")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Enter perfumes you own to find similar scents.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Button("Find") {
                presenter.findPerfumesButtonTab()
            }
            .primaryCapsuleButton(color: primaryButtonColor)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

private extension DiscoverScreen {
    enum FocusedField {
        case perfumeA
        case perfumeB
    }
}

private extension DiscoverScreen {
    func makePerfumeInput(
        title: String,
        text: Binding<String>,
        field: FocusedField
    ) -> some View {
        HStack(spacing: 12) {
            TextField(title, text: text)
                .focused($focusedField, equals: field)
                .submitLabel(.done)
                .font(.title3)
                .onSubmit {
                    focusedField = nil
                }
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private extension View {
    func primaryCapsuleButton(color: Color) -> some View {
        self
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .clipShape(Capsule())
    }
}
