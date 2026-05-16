//
//  SendFeedbackViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.05.2026.
//

import Foundation
import Combine
import Observation

@Observable final class SendFeedbackViewModel {
    let developerEmail: String
    let canSendMail: Bool

    init(
        developerEmail: String,
        canSendMail: Bool
    ) {
        self.developerEmail = developerEmail
        self.canSendMail = canSendMail
    }
}
