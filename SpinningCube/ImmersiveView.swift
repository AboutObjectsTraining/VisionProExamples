//
//  ImmersiveView.swift
//  SpinningCube
//
//  Created by Jonathan Lehr on 4/30/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    private let blueMaterial = SimpleMaterial(color: .systemBlue, roughness: 0.3, isMetallic: false)
    
    private static var rotationAnimation = FromToByAnimation(
        name: "Rotation",
        from: Transform(rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 0, 0))),
        to: Transform(rotation: simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))),
        duration: 3,
        bindTarget: .transform,
        repeatMode: .repeat
    )
    
    private static var finishRotationAnimation = FromToByAnimation(
        name: "Rotation",
        from: Transform(rotation: simd_quatf(angle: .pi + 0.001, axis: SIMD3<Float>(0, 1, 0))),
        to: Transform(rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 0, 0))),
        duration: 3,
        bindTarget: .transform
    )


    var body: some View {
        RealityView { content in
            let parentCube = makeParentEntity(position: SIMD3<Float>(-0.5, 1, -1.5))
            content.add(parentCube)
            let cube = parentCube.addCube(material: blueMaterial)

            if let animation = try? AnimationResource.generate(with: Self.rotationAnimation) {
                cube.playAnimation(animation)
            }

            if let forestCube = try? await Entity(named:"Forest", in: realityKitContentBundle) {
                let parentCube = makeParentEntity(position: SIMD3<Float>(0.5, 1, -1.5))
                content.add(parentCube)
                parentCube.addChild(forestCube)
                guard let animation1 = try? AnimationResource.generate(with: Self.rotationAnimation),
                      let animation2 = try? AnimationResource.generate(with: Self.finishRotationAnimation),
                      let animationSequence = try? AnimationResource.sequence(with: [animation1, animation2])
                else { return }
                
                forestCube.playAnimation(animationSequence.repeat())
            }
        }
    }
    
    private func makeParentEntity(position: SIMD3<Float>) -> Entity {
        let entity = Entity()
        entity.setPosition(position, relativeTo: nil)                
        return entity
    }
}

extension Entity {
    func addCube(material: SimpleMaterial) -> Entity {
        let entity = ModelEntity(mesh: .generateBox(size: 0.25, cornerRadius: 0.01), materials: [material])
        entity.setPosition(position, relativeTo: nil)
        entity.generateCollisionShapes(recursive: false)
        
        entity.components.set(HoverEffectComponent())
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(GroundingShadowComponent(castsShadow: true))
        
        addChild(entity)
        
        return entity
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
