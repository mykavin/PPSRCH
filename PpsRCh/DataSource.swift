//
//  DataSource.swift
//  PpsRCh
//

import Foundation

class DataSource {
    
    let fileName = "Variant5.json"
    
    var sensors: [Device] = []
    var mechs: [Device] = []
    
    var rowModels: [StepAction] = []
    
    func append(stepAction: StepAction) {
        rowModels.append(stepAction)
    }
    
    func remove(stepAction title: String) {
        for index in 0 ..< rowModels.count {
            if rowModels[index].title == title {
                rowModels.remove(at: index)
                break
            }
        }
    }
    
    func remove(device title: String) {
        
        for index in 0 ..< sensors.count {
            if sensors[index].title == title {
                sensors.remove(at: index)
                return
            }
        }
        
        for index in 0 ..< mechs.count {
            if mechs[index].title == title {
                mechs.remove(at: index)
                return
            }
        }
        
        devicesDidChange()
    }
    
    func addSensor(device: Device) {
        sensors.append(device)
        devicesDidChange()
    }
    
    func addMech(device: Device) {
        mechs.append(device)
        devicesDidChange()
    }
    
    func allDevices() -> [Device] {
        return sensors + mechs
    }
    
    func updateDevices() {
        
        for i in 0 ..< rowModels.count {
            var item = rowModels[i]
            item.devices = allDevices()
            rowModels[i] = item
        }
    }
    
    func devicesDidChange() {
        
        for i in 0 ..< rowModels.count {
            rowModels[i].devices = allDevices()
        }
    }
    
    func clear() {
        
        sensors.removeAll()
        mechs.removeAll()
        rowModels.removeAll()
    }
    
    func writeToFile() {
        
        let fileDataModel: FileData = fileData(from: rowModels)
        
        let encoder = JSONEncoder()
        
        if let encodedData = try? encoder.encode(fileDataModel),
           let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
            
            do {
                try encodedData.write(to: fileURL)
                debugPrint("Файл \(fileName) успішно записано і доступний по url: \(fileURL.path)")
            } catch {
                debugPrint("Помилка запису у файл: \(error)")
            }
        } else {
            debugPrint("Помилка кодуванні або отримання URL")
        }
    }
    
    func readFromFile() {
        
        var fileDataModel: FileData?
        
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
        else {
            debugPrint("Помилка отримання URL")
            return
        }
        
        do {

            let fileData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            fileDataModel = try decoder.decode(FileData.self, from: fileData)

            debugPrint("Файл прочитано успішно")
            
        } catch {
            debugPrint("Помилка зчитування файлу: \(error)")
        }
    
        if let result = fileDataModel {
            
            clear()
            var rows: [StepAction] = []
            
            for action in result.actions {
                
                var devices: [Device] = []
                
                for device in action.devices {
                    
                    var tempDevice = Device()
                    
                    tempDevice.title = device.title
                    tempDevice.selectedIndex = tempDevice.values.firstIndex(of: device.value) ?? 0
                    tempDevice.selectedValue = device.value
                    tempDevice.type = device.type == 0 ? .sensor : .mech
                    
                    devices.append(tempDevice)
                }
                
                let stepAction = StepAction(title: action.title, devices: devices)
                rows.append(stepAction)
            }
            
            rowModels = rows
            
            if let items = rows.first?.devices {
                sensors = items.filter({ $0.type == .sensor })
                mechs = items.filter({ $0.type == .mech })
            }
        }
    }
    
    func fileData(from rows: [StepAction]) -> FileData {
        
        var controls: [ControlAction] = []
        
        for item in rows {
            
            let hardwares: [Hardware] = item.devices.compactMap {
                Hardware(
                    title: $0.title,
                    type: $0.type.rawValue,
                    value: $0.selectedValue
                )
            }
            let control = ControlAction(title: item.title, devices: hardwares)
            
            controls.append(control)
        }
        
        let fileData = FileData(actions: controls)
        return fileData
    }
}
