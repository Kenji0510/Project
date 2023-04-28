//
//  TimeModeling.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/19.
//

import Foundation


class TimeModeling {
    let dateFormatter = DateComponentsFormatter()
    
    init() {
        dateFormatter.unitsStyle = .positional
        dateFormatter.allowedUnits = [.hour, .minute, .second]
        dateFormatter.zeroFormattingBehavior = .pad
    }
    
    // 秒を「00:00:00」に変換する
    func timeModeling(time: TimeInterval) -> String {
        return dateFormatter.string(from: time)!
    }
}
