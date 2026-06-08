//
//  SearchPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol SearchPerfumePresenter {
    func onAppear() async
    func searchSubmitted() async
    func resultsDidScroll()
    func loadMoreIfNeeded() async
}

final class SearchPerfumePresenterImpl {
    private let viewModel: SearchPerfumeViewModel
    private let router: SearchPerfumeRouter
    private let searchPerfumeService: SearchPerfumeService
    private let pageSize = 10
    
    init(
        viewModel: SearchPerfumeViewModel,
        router: SearchPerfumeRouter,
        searchPerfumeService: SearchPerfumeService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.searchPerfumeService = searchPerfumeService
    }
}

extension SearchPerfumePresenterImpl: SearchPerfumePresenter {
    
    //- нужен для первой автозагрузки списка, когда экран открылся
    //- чтобы сразу показать первые 10 ароматов
    func onAppear() async {
        guard !viewModel.hasLoadedOnce else { return }
        await loadPerfumes(resetResults: true)
    }

    //- запускает новый поиск после нажатия search на клавиатуре
    //- сбрасывает старый список и грузит результаты заново по новому тексту
    func searchSubmitted() async {
        await loadPerfumes(resetResults: true)
    }

    //- помечает, что пользователь реально начал скроллить
    //- нужен, чтобы не запускать автодогрузку сразу при первом рендере списка
    func resultsDidScroll() {
        guard !viewModel.hasStartedScrolling else { return }
        viewModel.hasStartedScrolling = true
    }
    
    //- проверяет, можно ли грузить следующую пачку
    //- если да, запускает догрузку ещё 10 ароматов
    func loadMoreIfNeeded() async {
        guard viewModel.hasStartedScrolling else { return }
        guard viewModel.canLoadMore else { return }
        guard viewModel.errorMessage == nil else { return }
        guard !viewModel.isLoading, !viewModel.isLoadingMore else { return }

        await loadPerfumes(resetResults: false)
    }
}

private extension SearchPerfumePresenterImpl {
    
    //- общая внутренняя функция загрузки
    //- в одном месте управляет:
    //    - initial load
    //    - новый поиск
    //    - догрузка следующей пачки
    //    - loading state
    //    - error state
    //    - обновление списка
    
    func loadPerfumes(resetResults: Bool) async {
        let searchText = resetResults
            ? viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            : viewModel.activeSearchText
        let offset = resetResults ? 0 : viewModel.perfumes.count

        await MainActor.run {
            viewModel.errorMessage = nil

            if resetResults {
                viewModel.isLoading = true
                viewModel.canLoadMore = false
                viewModel.hasStartedScrolling = false
            } else {
                viewModel.isLoadingMore = true
            }
        }

        if !resetResults {
            try? await Task.sleep(for: .seconds(2))
        }

        do {
            let result = try await searchPerfumeService.requestPerfumes(
                searchText: searchText,
                offset: offset,
                limit: pageSize
            )

            await MainActor.run {
                if resetResults {
                    viewModel.perfumes = result.items
                    viewModel.activeSearchText = searchText
                } else {
                    viewModel.perfumes.append(contentsOf: result.items)
                }

                viewModel.canLoadMore = result.hasMore
                viewModel.errorMessage = nil
                viewModel.hasLoadedOnce = true
                viewModel.isLoading = false
                viewModel.isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                if resetResults {
                    viewModel.perfumes = []
                    viewModel.canLoadMore = false
                }

                viewModel.errorMessage = L10n.Common.Error.message
                viewModel.hasLoadedOnce = true
                viewModel.isLoading = false
                viewModel.isLoadingMore = false
            }
        }
    }
}
