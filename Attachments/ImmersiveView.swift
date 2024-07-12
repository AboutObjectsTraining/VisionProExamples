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
    let biplaneLabel = "Biplane"
    let rocketLabel = "Rocket"
    
    @State private var rootEntity = Entity()
    @State private var toyPlaneEntity = Entity()
    @State private var toyRocketEntity = Entity()
    
    var body: some View {
        
        RealityView { content, attachments in
            if let scene = try? await Entity(named: "Toys", in: realityKitContentBundle) {
                rootEntity = scene
                content.add(scene)
                content.add(loadEntity(named: "ToyBiplane", binding: $toyPlaneEntity))
                content.add(loadEntity(named: "ToyRocket3", binding: $toyRocketEntity))
                
                if let biplaneAttachment = attachments.entity(for: biplaneLabel) {
                    biplaneAttachment.position = [0.2, 1.5, -0.8]
                    biplaneAttachment.components.set(BillboardComponent())
                    toyPlaneEntity.parent?.addChild(biplaneAttachment)
                }
                
                if let rocketAttachment = attachments.entity(for: rocketLabel) {
                    rocketAttachment.position = [-0.2, 1.5, -0.8]
                    rocketAttachment.components.set(BillboardComponent())
                    toyRocketEntity.parent?.addChild(rocketAttachment)
                }
            }
        } attachments: {
            Attachment(id: biplaneLabel) { view(for: biplaneLabel) }
            Attachment(id: rocketLabel) { view(for: rocketLabel) }
        }
        .pitchAndYaw(targetEntity: toyPlaneEntity, sensitivity: 4)
        .pitchAndYaw(targetEntity: toyRocketEntity, sensitivity: 4)
    }
    
    private func view(for label: String) -> some View {
        Text(label)
            .font(.title).bold()
            .padding()
            .glassBackgroundEffect()
    }
    
    private func loadEntity(named name: String, binding: Binding<Entity>) -> Entity {
        guard let entity = rootEntity.findEntity(named: name) else {
            print("Unable to find entity named \(name)")
            return Entity()
        }
        
        binding.wrappedValue = entity
        entity.generateCollisionShapes(recursive: true)
        
        let parentEntity = Entity()
        entity.setParent(parentEntity)
        
        return parentEntity
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
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let delta = location3D - startLocation3D
                    pitch = Double(delta.y) * sensitivity + basePitch
                    yaw = Double(delta.x) * sensitivity + baseYaw
                    
                    let angleX = simd_quatf(angle: Float(yaw), axis: [0, 1, 0])
                    let angleY = simd_quatf(angle: Float(-pitch), axis: [1, 0, 0])
                    
                    entity.orientation = angleY * angleX
                }
                .onEnded { value in
                    baseYaw = yaw
                    basePitch = pitch
                }
            )
    }
}


#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
