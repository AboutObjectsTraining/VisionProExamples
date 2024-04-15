//
//  LoadingAModelApp.swift
//  LoadingAModel
//
//  Created by Jonathan Lehr on 4/9/24.
//

import SwiftUI

@main
struct LoadingAModelApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
