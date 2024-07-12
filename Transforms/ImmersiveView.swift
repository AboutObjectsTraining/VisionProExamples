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
    @State private var toyPlaneEntity = Entity()
    @State private var toyRocketEntity = Entity()
    @State private var shouldPlayAudio = false
    
    @State private var playbackController: AudioPlaybackController?
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in toggleAirplaneEngineAudio() }
    }
    
    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Toys", in: realityKitContentBundle) {
                rootEntity = scene
                content.add(scene)
                
                if let entity = rootEntity.findEntity(named: "ToyBiplane") {
                    print(entity)
                    toyPlaneEntity = entity
                    toyPlaneEntity.generateCollisionShapes(recursive: true)
                    await loadPlaybackController()
                    
                    let parentEntity = Entity()
                    content.add(parentEntity)
                    toyPlaneEntity.setParent(parentEntity)
                }
                
                if let entity = rootEntity.findEntity(named: "ToyRocket3") {
                    print(entity)
                    toyRocketEntity = entity
                    toyRocketEntity.generateCollisionShapes(recursive: true)
                    
                    let parentEntity = Entity()
                    content.add(parentEntity)
                    toyRocketEntity.setParent(parentEntity)
                }
            }
        }
        .gesture(doubleTapGesture)
        .pitchAndYaw(targetEntity: toyPlaneEntity, sensitivity: 4)
        .pitchAndYaw(targetEntity: toyRocketEntity, sensitivity: 4)
    }
    
    @MainActor private func loadPlaybackController() async {
        
        guard let audioEntity = rootEntity.findEntity(named: "AirplaneEngineAudio"),
              let resource = try? await AudioFileResource(named: "/Root/AntiqueAirplaneEngineStart01",
                                                          from: "Toys.usda",
                                                          in: realityKitContentBundle)
        else { return }
        
        playbackController = audioEntity.prepareAudio(resource)
    }
    
    private func toggleAirplaneEngineAudio() {
        shouldPlayAudio.toggle()
        
        if shouldPlayAudio {
            playbackController?.play()
        } else {
            playbackController?.pause()
        }
        print(playbackController?.isPlaying ?? "nil playbackController")
    }
}

extension View {
    func pitchAndYaw(targetEntity: Entity, sensitivity: Double = 0.0) -> some View {
        modifier(PitchAndYawModifier(entity: targetEntity, sensitivity: sensitivity))
    }
}

private struct PitchAndYawModifier: ViewModifier {
    let entity: Entity
    let sensitivity: Double
    @State private var yaw = 0.0
    @State private var baseYaw = 0.0
    @State private var pitch = 0.0
    @State private var basePitch = 0.0
    
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture()
                .targetedToEntity(entity)
                .onChanged { value in
                    changeOrientation(value, sensitivity: 4)
                }
                .onEnded { value in
                    baseYaw = yaw
                    basePitch = pitch
                    // print("yaw: \(yaw)")
                }
            )
    }
    
    private func changeOrientation(_ value: EntityTargetValue<DragGesture.Value>,
                                   sensitivity: Double) {
        
        let location3D = value.convert(value.location3D, from: .local, to: .scene)
        let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
        let delta = location3D - startLocation3D
        yaw = Double(delta.x) * sensitivity + baseYaw
        pitch = Double(delta.y) * sensitivity + basePitch
        
        let deltaX = simd_quatf(angle: Float(yaw), axis: [0, 1, 0])
        let deltaY = simd_quatf(angle: Float(-pitch), axis: [1, 0, 0])
        // print(pitch)
        
        value.entity.orientation = deltaY * deltaX
    }
}


#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
