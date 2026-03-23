//
//  TodayScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

struct TodayScreen: View {
    @Bindable private var viewModel: TodayViewModel
    private let presenter: TodayPresenter
    
    init(
        viewModel: TodayViewModel,
        presenter: TodayPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                makeTodayEnergyScreen()
                    .padding(.horizontal, 16)
                
                makeAromaDay()
                    .padding(.horizontal, 16)
                
                makeRecommendedForYou()
                    .padding(.horizontal, 16)
                
                makeThisDayInPerfumery()
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
    }
}

private extension TodayScreen {
    func makeTodayEnergyScreen() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Energy")
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.pink, lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Moon in Scorpio")
                        .font(.headline)
                    
                    Text("Your emotions are deeper and more intense today.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .onTapGesture {
            presenter.todayEnergyButtonTab()
        }
    }
    
    func makeAromaDay() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aroma of the Day")
                .font(.title3)
                .fontWeight(.medium)
            
            
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tom Ford\nOud Wood")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Warm · Deep · Magnetic")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 6) {
                        Button(action: {}) {
                            Text("My vibe")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color.pink)
                                .clipShape(Capsule())
                        }
                        
                        Button(action: {}) {
                            Text("Not today")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color.white.opacity(0.7))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 82, height: 112)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
    
    func makeRecommendedForYou() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended for You")
                .font(.title3)
                .fontWeight(.medium)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<8, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.gray.opacity(0.12))
                                .frame(width: 84, height: 96)
                            
                            Text("Byredo")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .lineLimit(1)
                            
                            Text("Gypsy Water")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .padding(10)
                        .frame(width: 104, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                    }
                    
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    func makeThisDayInPerfumery() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("On This Day in Perfumery")
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("1957")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Dior released Diorissimo")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
                
                Text("One of the most iconic lily-of-the-valley perfumes from Dior.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
        .onTapGesture {
            presenter.dayInPerfumeryButtonTab()
        }
    }
}
