//
//  ContentView.swift
//  SpinningCube
//
//  Created by Jonathan Lehr on 4/30/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    private let rotationDegrees = 30.0

    var body: some View {
        VStack {
            TimelineView(.animation) { context in
                Model3D(named: "RotatingSphere", bundle: realityKitContentBundle)
                    .rotation3DEffect(angle(for: context), axis: .y)
            }
            
            Text("Spinning Cube")
                .font(.title)
                .padding(.vertical, 50)

            Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                .font(.title3)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()
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
    
    private func angle(for timelineContext: TimelineViewDefaultContext) -> Angle {
        return Angle(degrees: rotationDegrees * timelineContext.date.timeIntervalSinceReferenceDate)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
