//import SwiftUI
//
//struct TemperatureModeSettingsView: View {
//    @EnvironmentObject var viewModel: FanControlViewModel
//    @Environment(\.presentationMode) var presentationMode
//    
//    @State private var tempRanges: [Int: FanSpeedSetting] = [:]
//    @State private var interval: Int = 5
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    @State private var isExpanded = false 
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Form {
//                    Section(header: Text("바람 세기별 온도 범위")
//                                .font(.headline)
//                                .foregroundColor(.blue)) {
//                        DisclosureGroup(isExpanded: $isExpanded) {
//                            ForEach(1...14, id: \.self) { speed in
//                                VStack(alignment: .leading, spacing: 5) {
//                                    Text("바람 세기 \(speed)")
//                                        .font(.subheadline)
//                                        .foregroundColor(.primary)
//                                    
//                                    HStack {
//                                        TextField("최소 온도", value: Binding(
//                                            get: { tempRanges[speed]?.lowerBound ?? viewModel.fanSpeedSettings[speed]?.lowerBound ?? 0.0 },
//                                            set: { tempRanges[speed]?.lowerBound = $0 }
//                                        ), formatter: NumberFormatter())
//                                        .keyboardType(.decimalPad)
//                                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                                        .padding(.horizontal, 5)
//                                        
//                                        Text("~")
//                                            .font(.title2)
//                                            .foregroundColor(.gray)
//                                        
//                                        TextField("최대 온도", value: Binding(
//                                            get: { tempRanges[speed]?.upperBound ?? viewModel.fanSpeedSettings[speed]?.upperBound ?? 0.0 },
//                                            set: { tempRanges[speed]?.upperBound = $0 }
//                                        ), formatter: NumberFormatter())
//                                        .keyboardType(.decimalPad)
//                                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                                        .padding(.horizontal, 5)
//                                    }
//                                    .padding(.vertical, 5)
//                                }
//                                .padding(.vertical, 8)
//                                .onAppear {
//                                    if tempRanges[speed] == nil {
//                                        tempRanges[speed] = viewModel.fanSpeedSettings[speed]
//                                    }
//                                }
//                            }
//                        } label: {
//                            Text("바람 세기 설정")
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                        }
//                    }
//                    
//                    Section(header: Text("온도 측정 주기")
//                                .font(.headline)
//                                .foregroundColor(.blue)) {
//                        HStack {
//                            TextField("주기 (분 단위)", value: $interval, formatter: NumberFormatter())
//                                .keyboardType(.numberPad)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding(.horizontal, 5)
//                            
//                            Text("분")
//                                .foregroundColor(.secondary)
//                                .font(.subheadline)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                .background(Color(.systemGroupedBackground))
//                .cornerRadius(15)
//                .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 2)
//                
//                Button(action: saveSettings) {
//                    Text("설정 저장")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 2)
//                }
//                .padding(.horizontal)
//            }
//            .padding()
//            .onAppear {
//                tempRanges = viewModel.fanSpeedSettings
//                interval = viewModel.temperatureInterval
//            }
//            .navigationBarTitle("온도 모드 설정", displayMode: .inline)
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("잘못된 설정"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
//            }
//        }
//    }
//
//    // 설정 저장 함수
//    private func saveSettings() {
//        alertMessage = ""
//        
//        // 각 바람 세기의 범위가 유효한지 확인
//        for speed in 1...14 {
//            if let setting = tempRanges[speed] {
//                if setting.lowerBound > setting.upperBound {
//                    alertMessage = "바람 세기 \(speed)의 최소 온도가 최대 온도보다 큽니다. 수정해주세요."
//                    showAlert = true
//                    return
//                }
//            }
//        }
//        
//        // 바람 세기 사이의 연속성 검사
//        for speed in 2...14 {
//            if let current = tempRanges[speed], let previous = tempRanges[speed - 1] {
//                if current.lowerBound < previous.upperBound {
//                    alertMessage = "바람 세기 \(speed - 1)의 최대 온도가 바람 세기 \(speed)의 최소 온도보다 큽니다. 수정해주세요."
//                    showAlert = true
//                    return
//                }
//            }
//        }
//        
//        viewModel.fanSpeedSettings = tempRanges
//        viewModel.temperatureInterval = interval
//        presentationMode.wrappedValue.dismiss()
//    }
//}


import SwiftUI

struct TemperatureModeSettingsView: View {
    @EnvironmentObject var viewModel: FanControlViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var tempRanges: [Int: FanSpeedSetting] = [:]
    @State private var interval: Int = 5
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isExpanded = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Form {
                    Section(header: Text("바람 세기별 온도 범위")
                                .font(.headline)
                                .foregroundColor(.blue)) {
                        DisclosureGroup(isExpanded: $isExpanded) {
                            ForEach(1...14, id: \.self) { speed in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("바람 세기 \(speed)")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)

                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("최소 온도: \(Int(tempRanges[speed]?.lowerBound ?? 0))°C")
                                            Slider(value: Binding(
                                                get: { tempRanges[speed]?.lowerBound ?? viewModel.fanSpeedSettings[speed]?.lowerBound ?? 0.0 },
                                                set: { tempRanges[speed]?.lowerBound = $0 }
                                            ), in: 0...40, step: 1)
                                        }

                                        VStack(alignment: .leading) {
                                            Text("최대 온도: \(Int(tempRanges[speed]?.upperBound ?? 0))°C")
                                            Slider(value: Binding(
                                                get: { tempRanges[speed]?.upperBound ?? viewModel.fanSpeedSettings[speed]?.upperBound ?? 0.0 },
                                                set: { tempRanges[speed]?.upperBound = $0 }
                                            ), in: 0...40, step: 1)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                                .padding(.vertical, 8)
                            }
                        } label: {
                            Text("바람 세기 설정")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .onChange(of: isExpanded) { expanded in
                            if expanded && tempRanges.isEmpty {
                                // Initialize tempRanges when the section is expanded
                                tempRanges = viewModel.fanSpeedSettings
                            }
                        }
                    }

                    Section(header: Text("온도 측정 주기")
                                .font(.headline)
                                .foregroundColor(.blue)) {
                        HStack {
                            Text("주기 (분): \(interval)")
                            Spacer()
                            Stepper("", value: $interval, in: 1...60)
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(15)
                .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 2)

                Button(action: saveSettings) {
                    Text("설정 저장")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal)
            }
            .padding()
            .onAppear {
                interval = viewModel.temperatureInterval
            }
            .navigationBarTitle("온도 모드 설정", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("잘못된 설정"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
        }
    }

    // 설정 저장 함수
    private func saveSettings() {
        alertMessage = ""

        // 각 바람 세기의 범위가 유효한지 확인
        for speed in 1...14 {
            if let setting = tempRanges[speed] {
                if setting.lowerBound > setting.upperBound {
                    alertMessage = "바람 세기 \(speed)의 최소 온도가 최대 온도보다 큽니다. 수정해주세요."
                    showAlert = true
                    return
                }
            }
        }

        // 바람 세기 사이의 연속성 검사 및 자동 조정
        for speed in 1...13 {  // Adjust only up to the penultimate level
            if let currentSetting = tempRanges[speed], let nextSetting = tempRanges[speed + 1] {
                if currentSetting.upperBound != nextSetting.lowerBound {
                    tempRanges[speed + 1]?.lowerBound = currentSetting.upperBound
                }
            }
        }

        viewModel.fanSpeedSettings = tempRanges
        viewModel.temperatureInterval = interval
        presentationMode.wrappedValue.dismiss()
    }
}




