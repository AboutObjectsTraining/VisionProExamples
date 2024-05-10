//
//  TransformsApp.swift
//  Transforms
//
//  Created by Jonathan Lehr on 5/10/24.
//

import SwiftUI

@main
struct TransformsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
