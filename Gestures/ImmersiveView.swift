//
//  Created 6/18/24 by Jonathan Lehr
//  Copyright © 2024 About Objects.
//  

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var currentTransform: Transform?

    @State private var isScaled = false
    @State private var isRotated = false
    
    let blueMaterial = SimpleMaterial(color: .systemBlue,
                                      roughness: 0.3,
                                      isMetallic: false)
    let pinkMaterial = SimpleMaterial(color: .systemPink,
                                      roughness: 0.0,
                                      isMetallic: true)
    
    let myPhysicallyBasedMaterial = {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .systemGreen)
        material.metallic = 0.5
        material.clearcoat = 0.9
        material.roughness = 0.4
        material.specular = 0.8
        material.emissiveIntensity = 0.1
        material.emissiveColor = .init(color: .systemBlue)
        // Uncomment the line below to render the mesh.
        // material.triangleFillMode = .lines
        return material
    }()
    
    let increment = 1.0
    
    // Targeted to entities that contain an instance of BlueComponent
    var blueTapGesture: some Gesture {
        TapGesture()
            .targetedToEntity(where: .has(BlueComponent.self))
            .onEnded { value in
                isScaled.toggle()
                value.entity.scale += isScaled ? 1 : -1
            }
    }
    
    // Targeted to entities that contain an instance of PinkComponent
    var pinkTapGesture: some Gesture {
        TapGesture()
            .targetedToEntity(where: .has(PinkComponent.self))
            .onEnded { value in
                let rotation1 = simd_quatf(angle: .pi / 4, axis: [0, 1, 0])
                let rotation2 = simd_quatf(angle: 0, axis: [0, 1, 0])
                isRotated.toggle()
                value.entity.transform.rotation = isRotated ? rotation1 : rotation2
            }
    }
    
    // Targeted to any entity
    var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                let entity = value.entity
                if currentTransform == nil {
                    currentTransform = entity.transform
                }
                
                let translation = value.convert(value.translation3D, from: .local, to: entity.parent!)
                entity.transform.translation = currentTransform!.translation + translation
            }
            .onEnded { _ in
                currentTransform = nil
            }
    }
    
    var body: some View {
        RealityView { content in
            let cube1 = makeCube(material: blueMaterial)
            let cube2 = makeCube(material: pinkMaterial)
            let cube3 = makeCube(material: myPhysicallyBasedMaterial)
            
            cube1.components.set(BlueComponent())
            cube2.components[PinkComponent.self] = PinkComponent()
            
            cube1.setPosition([-0.5, 1, -1.5], relativeTo: nil)
            cube2.setPosition([0.5, 1, -1.5], relativeTo: nil)
            cube3.setPosition([0, 1, -1.5], relativeTo: nil)
            
            content.add(cube1)
            content.add(cube2)
            content.add(cube3)
        }
        .gesture(dragGesture)
        .simultaneousGesture(blueTapGesture)
        .simultaneousGesture(pinkTapGesture)
    }
    
    private func makeCube<T: RealityKit.Material>(material: T) -> Entity {
        let mesh = MeshResource.generateBox(size: 0.25, cornerRadius: 0.01)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.generateCollisionShapes(recursive: false)
        
        // entity.components.set(HoverEffectComponent())
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(GroundingShadowComponent(castsShadow: true))
        
        return entity
    }
}

