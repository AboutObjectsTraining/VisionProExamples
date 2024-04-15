//
//  ProgrammaticModelApp.swift
//  ProgrammaticModel
//
//  Created by Jonathan Lehr on 4/15/24.
//

import SwiftUI

@main
struct ProgrammaticModelApp: App {
    
    var mainWindow: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    var toyCarSpace: some Scene {
        ImmersiveSpace(id: "ImmersiveSpace") {
            ToyCarView()
        }
    }
    
    var body: some Scene {
        mainWindow
        toyCarSpace
    }
}
