//
//  ContentView.swift
//  PpsRCh
//

import SwiftUI

struct ContentView: View {
    
    let dataSource = DataSource()
    
    @State var totalColumns: [Device] = []
    
    @State var actions: [StepAction] = []
    @State var gridItems: [GridItem] = []
    
    @State private var stepActionShowAlert = false
    @State private var stepActionName = ""
    
    @State private var removeStepActionShowAlert = false
    @State private var stepActionToRemove = ""
    
    @State private var sensorShowAlert = false
    @State private var sensorName = ""
    
    @State private var mechShowAlert = false
    @State private var mechName = ""
    
    @State private var removeDeviceShowAlert = false
    @State private var deviceToRemove = ""
    
    let cellSize = CGSize(width: 180, height: 50)
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: 0) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack {
                        Button("Додати дію") {
                            stepActionShowAlert = true
                        }
                        .alert("Нова дія", isPresented: $stepActionShowAlert) {
                            TextField("Введіть назу дії:", text: $stepActionName)
                            Button("Додати", action: addStepAction)
                            Button("Вихід") {
                                stepActionName = ""
                            }
                        }
                        .padding(20)
                        Button("Додати сенсор") {
                            sensorShowAlert = true
                        }
                        .alert("Новий сенсор", isPresented: $sensorShowAlert) {
                            TextField("Введіть назу сенсора:", text: $sensorName)
                            Button("Додати", action: addSensor)
                            Button("Вихід") {
                                sensorName = ""
                            }
                        }
                        .padding(20)
                        Button("Додати пристрій") {
                            mechShowAlert = true
                        }
                        .alert("Новий пристрій", isPresented: $mechShowAlert) {
                            TextField("Введіть назу пристрою:", text: $mechName)
                            Button("Додати", action: addMech)
                            Button("Вихід") {
                                mechName = ""
                            }
                        }
                        .padding(20)
                        Button("Очистити") {
                            dataSource.clear()
                            loadData()
                        }
                        .padding(20)
                        Button("Експорт у JSON файл") {
                            dataSource.writeToFile()
                        }
                        .padding(20)
                        Button("Завантажити останній JSON файл") {
                            dataSource.readFromFile()
                            loadData()
                        }
                        Spacer()
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4, content: {
                        HStack {
                            Text("    S:")
                                .bold()
                            Text("- стан датчиків")
                        }
                        HStack {
                            Text("    D:")
                                .bold()
                            Text("- стан механізмів")
                        }
                    })
                    HStack {
                        Text("")
                    }
                    HStack {
                        Text("")
                            .frame(width: cellSize.width,
                                   height: cellSize.height)
                        
                        ForEach(0 ..< totalColumns.count, id: \.self) { column in
                            let type = totalColumns[column].type == .sensor ? "S: " : "D: "
                            Text("\(type) \(totalColumns[column].title)")
                                .frame(width: cellSize.width,
                                       height: cellSize.height)
                                .bold()
                        }
                    }
                    
                    List {
                        
                        ForEach(0 ..< actions.count, id: \.self) { item in
                            
                            HStack {
                                
                                Spacer(minLength: 10)
                                
                                Text("\(item + 1) \(actions[item].title)")
                                    .frame(width: cellSize.width,
                                           height: cellSize.height,
                                           alignment: .center)
                                    .bold()
                                
                                ForEach(0 ..< actions[item].devices.count, id: \.self) { column in
                                    let selected = actions[item].devices[column].selected
                                    let color: Color = selected ? .green : .white
                                    ZStack {
                                        Circle()
                                            .foregroundColor(color)
                                            .frame(width: cellSize.height * 0.5,
                                                   height: cellSize.height * 0.5)
                                        Text(actions[item].devices[column].selectedValue)
                                            .onTapGesture {
                                                var tappedItem = actions[item].devices[column]
                                                tappedItem.goNext()
                                                actions[item].devices[column] = tappedItem
                                                dataSource.rowModels[item].devices[column] = tappedItem
                                            }
                                    }
                                    .frame(width: cellSize.width,
                                           height: cellSize.height)
                                    .onTapGesture {
                                        actions[item].devices[column].goNext()
                                        loadData()
                                    }.onLongPressGesture {
                                        deviceToRemove = actions[item].devices[column].title
                                        removeDeviceShowAlert = true
                                    }
                                }
                                Spacer()
                            }.onTapGesture {
                                
                            }.onLongPressGesture {
                                stepActionToRemove = actions[item].title
                                removeStepActionShowAlert = true
                            }
                        }
                    }
                }
            }
            .alert("Видалити дію?", isPresented: $removeStepActionShowAlert) {
                Text(stepActionToRemove)
                Button("Видалити") {
                    dataSource.remove(stepAction: stepActionToRemove)
                    loadData()
                }
                Button("Вихід") {
                    removeStepActionShowAlert = false
                }
            }
            .alert("Видалити сенсор/пристрій?", isPresented: $removeDeviceShowAlert) {
                Text(deviceToRemove)
                Button("Видалити") {
                    dataSource.remove(device: deviceToRemove)
                    loadData()
                }
                Button("Вихід") {
                    removeStepActionShowAlert = false
                }
            }
        }
    }
    
    func loadData() {
        
        var result: [GridItem] = []
        let rows = dataSource.rowModels
        
        for _ in 0 ..< rows.count {
            result.append(GridItem(.flexible()))
        }
        
        gridItems = result
        
        actions = dataSource.rowModels
        totalColumns = dataSource.allDevices()
    }
    
    func addStepAction() {
        
        if !stepActionName.isEmpty {
            
            let devices = dataSource.allDevices()
            let stepAction = StepAction(title: stepActionName, devices: devices)
            
            dataSource.append(stepAction: stepAction)
            loadData()
        }
        
        stepActionName = ""
    }
    
    func addSensor() {
        
        if !sensorName.isEmpty {
            
            let device = Device(title: sensorName, type: .sensor)
            dataSource.addSensor(device: device)
            loadData()
        }
        
        sensorName = ""
    }
    
    func addMech() {
        
        if !mechName.isEmpty {
            
            let device = Device(title: mechName, type: .mech)
            dataSource.addMech(device: device)
            loadData()
        }
        
        mechName = ""
    }
}

#Preview {
    ContentView()
}
