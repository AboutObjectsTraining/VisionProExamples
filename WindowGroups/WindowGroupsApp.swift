//
//  WindowGroupsApp.swift
//  WindowGroups
//
//  Created by Jonathan Lehr on 6/3/24.
//

import SwiftUI

@main
struct WindowGroupsApp: App {
    
    static let windowTwo = "Window Two"
    @State private var viewModel = ViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        
        WindowGroup(id: Self.windowTwo) {
            Text(Self.windowTwo)
                .font(.title)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                print("Background")
                viewModel.isShowingWindowTwo = false
            }
        }
    }
}
