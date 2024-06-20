//
//  Created 6/18/24 by Jonathan Lehr
//  Copyright © 2024 About Objects.
//  

import SwiftUI

@main
struct GesturesApp: App {
    
    init() {
        BlueComponent.registerComponent()
        PinkComponent.registerComponent()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
