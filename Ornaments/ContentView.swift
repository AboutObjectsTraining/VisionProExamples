//
//  Created 6/20/24 by Jonathan Lehr
//  Copyright © 2024 About Objects.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                    .fill(.thinMaterial)
                Text("Content goes here")
                    .font(.title)
            }
            .padding()
            .navigationTitle("Ornaments and Toolbars")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Nav Item One", action: { })
                    Button("Nav Item Two", action: { })
                }
            }
            .ornament(attachmentAnchor: .scene(.top), contentAlignment: .bottom) {
                HStack(spacing: 15) {
                    Button(action: { }) { Image(systemName: "visionpro") }
                    Button(action: { }) { Image(systemName: "macbook.and.visionpro") }
                    Button(action: { }) { Image(systemName: "macbook") }
                }
                .padding(15)
                .imageScale(.large)
                .glassBackgroundEffect()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Bottom Bar Button One", action: { })
                    Button("Bottom Bar Button Two", action: { })
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    Button("Toolbar Button One", action: { })
                    Divider()
                    Button("Toolbar Button Two", action: { })
                }
            }
        }
    }
}
