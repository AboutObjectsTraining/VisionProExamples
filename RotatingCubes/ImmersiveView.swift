//
//  ImmersiveView.swift
//  RotatingCubes
//
//  Created by Jonathan Lehr on 4/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var cube1 = Entity()
    @State private var cube2 = Entity()
    
//    @State private var currLocationX = CGFloat(0)
//    @State private var currLocationY = CGFloat(0)
    
    @State private var yaw = 0.0
    @State private var pitch = 0.0
    @State private var baseYaw = 0.0
    @State private var basePitch = 0.0
    
    let blueMaterial = SimpleMaterial(color: .systemBlue, roughness: 0.3, isMetallic: false)
    let pinkMaterial = SimpleMaterial(color: .systemPink, roughness: 0.0, isMetallic: true)
    let increment = 1.0
    
    var body: some View {
        RealityView { content in
            cube1 = addCube(content: content, position: SIMD3<Float>(-0.5, 1, -1.5), material: blueMaterial)
            cube2 = addCube(content: content, position: SIMD3<Float>(0.5, 1, -1.5), material: pinkMaterial)
        }
        .gesture(
             DragGesture()
                 .targetedToAnyEntity()
                 .onChanged { value in
                     let entity = value.entity
                     
                     let location3D = value.convert(value.location3D, from: .local, to: .scene)
                     let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                     let delta = location3D - startLocation3D
                     yaw = Double(delta.x) + baseYaw
                     pitch = Double(delta.y) + basePitch
                     
                     let deltaX = simd_quatf(angle: Float(yaw), axis: [0, 1, 0])
                     let deltaY = simd_quatf(angle: Float(-pitch), axis: [1, 0, 0])
 //                    print(pitch)
                     
                     entity.orientation = deltaY * deltaX

//                     let orientation = Rotation3D(entity.orientation(relativeTo: nil))
//                     
//                     let yaw = value.location.x >= currLocationX ? increment : -increment
//                     let pitch = value.location.y >= currLocationY ? increment : -increment
//                     
//                     let newOrientation: Rotation3D = orientation
//                         .rotated(by: .init(angle: .degrees(pitch), axis: .x))
//                         .rotated(by: .init(angle: .degrees(yaw), axis: .y))
//                     
//                     entity.setOrientation(.init(newOrientation), relativeTo: nil)
//                     currLocationX = value.location.x
//                     currLocationY = value.location.y
                 }
                .onEnded { _ in
                    baseYaw = yaw
                    basePitch = pitch
                }
         )
    }
    
    private func addCube(content: RealityViewContent, position: SIMD3<Float>, material: SimpleMaterial) -> Entity {
        let entity = ModelEntity(mesh: .generateBox(size: 0.25, cornerRadius: 0.01), materials: [material])
        entity.setPosition(position, relativeTo: nil)
        entity.generateCollisionShapes(recursive: false)
        
        entity.components.set(HoverEffectComponent())
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(GroundingShadowComponent(castsShadow: true))
        content.add(entity)
        
        return entity
    }

}

//#Preview(immersionStyle: .mixed) {
//    ImmersiveView()
//}
