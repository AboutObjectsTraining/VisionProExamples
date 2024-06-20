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
    static let windowThree = "Window Three"
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
        .defaultSize(width: 400, height: 300)
        
        WindowGroup(id: Self.windowThree) {
            ZStack {
                Color.blue
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
                Text(Self.windowThree)
                    .font(.extraLargeTitle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.orange)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                viewModel.isShowingWindowThree = false
            }
        }
        .defaultSize(width: 400, height: 300, depth: 200)
        .windowStyle(.volumetric)
    }
}
