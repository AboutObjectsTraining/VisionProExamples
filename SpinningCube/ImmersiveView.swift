//
//  ImmersiveView.swift
//  SpinningCube
//
//  Created by Jonathan Lehr on 4/30/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

private let rotationAnimation = FromToByAnimation(
    name: "Rotation",
    from: Transform(rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 0, 0))),
    to: Transform(rotation: simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))),
    duration: 3,
    bindTarget: .transform,
    repeatMode: .repeat
)

private let finishRotationAnimation = FromToByAnimation(
    name: "Rotation",
    from: Transform(rotation: simd_quatf(angle: .pi + 0.001, axis: SIMD3<Float>(0, 1, 0))),
    to: Transform(rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 0, 0))),
    duration: 3,
    bindTarget: .transform
)

struct ImmersiveView: View {
    private let blueMaterial = SimpleMaterial(color: .systemBlue, roughness: 0.3, isMetallic: false)

    var body: some View {
        RealityView { content in
            await content.addSimpleCube(material: blueMaterial)
            await content.addForestCube()
        }
    }
}

extension RealityViewContent {
    
    @MainActor func addSimpleCube(material: SimpleMaterial) async {
        let parentEntity = Entity(position: SIMD3<Float>(-0.5, 1, -1.5))
        add(parentEntity)
        let cube = parentEntity.addCube(material: material)

        if let animation = try? AnimationResource.generate(with: rotationAnimation) {
            cube.playAnimation(animation)
        }
    }
    
    @MainActor func addForestCube() async {
        if let forestCube = try? await Entity(named:"Forest", in: realityKitContentBundle) {
            let parentEntity = Entity(position: SIMD3<Float>(0.5, 1, -1.5))
            add(parentEntity)
            parentEntity.addChild(forestCube)
            
            guard let animation1 = try? AnimationResource.generate(with: rotationAnimation),
                  let animation2 = try? AnimationResource.generate(with: finishRotationAnimation),
                  let animationSequence = try? AnimationResource.sequence(with: [animation1, animation2])
            else { return }
            
            forestCube.playAnimation(animationSequence.repeat())
        }
    }
}

extension Entity {
    
    convenience init(position: SIMD3<Float>) {
        self.init()
        setPosition(position, relativeTo: nil)
    }
    
    
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
