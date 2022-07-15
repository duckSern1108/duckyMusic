//
//  Double.ext.swift
//  DuckyMusic
//
//  Created by ghtk on 13/07/2022.
//

import Foundation

extension Double {
    func convertMsToMinuteAndSecond() -> String {
        let minute = (self / 60000).rounded(.down)
        let seconds = (self - minute * 60000) / 1000
        let minuteDisplay = "\(Int(minute))"
        let intSec = Int(seconds)
        let secondsDisplay = intSec < 10 ? "0" + String(intSec) : String(intSec)
        return minuteDisplay + ":" + secondsDisplay
    }
}
