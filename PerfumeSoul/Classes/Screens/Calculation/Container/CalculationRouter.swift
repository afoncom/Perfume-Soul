//
//  CalculationRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol CalculationRouter {
    func finishCalculation()
}

final class CalculationRouterImpl {
    private let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
}

extension CalculationRouterImpl: CalculationRouter {
    func finishCalculation() {
        onFinish()
    }
}
