//
//  NatalChartInput.swift
//  PerfumeSoul
//
//  Created by Codex on 10.07.2026.
//

import Foundation

struct NatalChartInput: Equatable {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String
    let altitudeMeters: Double

    init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        latitude: Double,
        longitude: Double,
        timeZoneIdentifier: String,
        altitudeMeters: Double = 0
    ) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
        self.altitudeMeters = altitudeMeters
    }
}
