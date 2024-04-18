//
//  ContentView.swift
//  RotatingCubes
//
//  Created by Jonathan Lehr on 4/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

enum DragBehavior: CaseIterable {
    case rotate
    case translate
}

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @State private var dragBehavior = DragBehavior.translate
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Rotating Cubes")
                .font(.title)
                .padding(.bottom, 50)
            Group {
                Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                
//                Picker("Drag Behavior", sources: DragBehavior.allCases, selection: \.dragBehavior) {
//                    Text("Hello")
//                }
            }
            .font(.title)
            .frame(width: 360)
            .padding(24)
                
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
