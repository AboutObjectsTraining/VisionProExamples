//
//  LoadingAModelApp.swift
//  LoadingAModel
//
//  Created by Jonathan Lehr on 4/9/24.
//

import SwiftUI

@main
struct LoadingAModelApp: App {
    
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
