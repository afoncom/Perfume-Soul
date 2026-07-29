//
//  PersonalPerfumeRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PersonalPerfumeRouter {
    func finishOnboarding()
}

final class PersonalPerfumeRouterImpl {
    private let onFinish: (() -> Void)?

    init(onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
    }
}

extension PersonalPerfumeRouterImpl: PersonalPerfumeRouter {
    func finishOnboarding() {
        onFinish?()
    }
}
