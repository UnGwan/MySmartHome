//
//  MySmartHomeAppApp.swift
//  MySmartHomeApp
//
//  Created by 정운관 on 10/4/24.
//

import SwiftUI

@main
struct MySmartHomeAppApp: App {
    @StateObject private var ledViewModel = LEDControlViewModel()
    @StateObject private var fanViewModel = FanControlViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainHomeView()
            }
            .environmentObject(ledViewModel)
            .environmentObject(fanViewModel)
        }
    }
}
