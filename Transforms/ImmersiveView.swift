//
//  ImmersiveView.swift
//  Transforms
//
//  Created by Jonathan Lehr on 5/10/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    @State private var rootEntity = Entity()
    
    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Toys", in: realityKitContentBundle) {
                rootEntity = scene
                content.add(scene)
            }
        } update: { _ in
            Task {
                await playAirplaneEngineAudio()
            }
        }
    }
    
    @MainActor private func playAirplaneEngineAudio() async {
        
        guard let audioEntity = rootEntity.findEntity(named: "AirplaneEngineAudio"),
              let resource = try? await AudioFileResource(named: "/Root/AntiqueAirplaneEngineStart01",
                                                          from: "Toys.usda",
                                                          in: realityKitContentBundle)
        else { return }
        
        let playbackController = audioEntity.prepareAudio(resource)
        playbackController.play()
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
