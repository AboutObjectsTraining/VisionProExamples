//
//  VisionProExamplesApp.swift
//  VisionProExamples
//
//  Created by Jonathan Lehr on 4/9/24.
//

import SwiftUI

@main
struct VisionProExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
