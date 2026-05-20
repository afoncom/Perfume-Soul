//
//  MailService.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.05.2026.
//

import Foundation
import MessageUI

protocol MailService {
    func canSendMail() -> Bool
}

final class MailServiceImpl: MailService {
    func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
}
