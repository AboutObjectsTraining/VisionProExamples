//
//  SpinningCubeApp.swift
//  SpinningCube
//
//  Created by Jonathan Lehr on 4/30/24.
//

import SwiftUI

@main
struct SpinningCubeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
