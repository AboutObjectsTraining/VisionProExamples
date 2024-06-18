//
//  Created 6/17/24 by Jonathan Lehr
//  Copyright © 2024 About Objects.
//  

import SwiftUI

@main
struct AnchorsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
