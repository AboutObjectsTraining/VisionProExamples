//
//  ProgrammaticModelApp.swift
//  ProgrammaticModel
//
//  Created by Jonathan Lehr on 4/15/24.
//

import SwiftUI

@main
struct ProgrammaticModelApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
