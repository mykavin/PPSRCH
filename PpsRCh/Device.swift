//
//  Device.swift
//  PpsRCh
//

import Foundation

struct Device {
    
    var title = ""
    var selected = false
    var selectedIndex = 0
    var selectedValue = "  "
    var values = ["  ", "00", "01", "10", "11"]
    var type: DeviceType = .sensor

    mutating func goNext() {
        
        selectedIndex += 1
        
        if selectedIndex >= values.count {
            selectedIndex = 0
        }
        
        selectedValue = values[selectedIndex]
    }
}


