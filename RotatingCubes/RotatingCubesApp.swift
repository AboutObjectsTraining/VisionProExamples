//
//  RotatingCubesApp.swift
//  RotatingCubes
//
//  Created by Jonathan Lehr on 4/18/24.
//

import SwiftUI

@main
struct RotatingCubesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
