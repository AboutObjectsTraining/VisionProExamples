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
    name: "FinishRotation",
    from: Transform(rotation: simd_quatf(angle: .pi + 0.001, axis: SIMD3<Float>(0, 1, 0))),
    to: Transform(rotation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 0, 0))),
    duration: 3,
    bindTarget: .transform
)

struct ImmersiveView: View {
    private let rotationAmount = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
    
    @State private var redCube = Entity()
    @State private var animationController: AnimationPlaybackController?
    
    var body: some View {
        TimelineView(.animation) { timelineContext in
            RealityView { content in
                await content.addBlueCube()
                await content.addForestCube()
                
                animationController = await content.addGreenCube()
                Task {
                    try await Task.sleep(for: .seconds(0.1))
                    animationController?.pause()
                }

                let _redCube = content.addRedCube()
                Task {
                    // Causes update closure to be called initially
                    redCube = _redCube
                }
            } update: { content in
                // Causes update closure to be called repeatedly
                let _ = timelineContext
                redCube.move(to: .init(yaw: 1), relativeTo: redCube, duration: 1, timingFunction: .linear)
            }
            .toggleAnimation(controller: animationController)
        }
    }
}

// MARK: - Adding cube entities
extension RealityViewContent {
    
    @MainActor func addBlueCube() async {
        let blueMaterial = SimpleMaterial(color: .systemBlue, roughness: 0.3, isMetallic: false)
        let parentEntity = Entity(position: SIMD3<Float>(-0.5, 1, -1.5))
        add(parentEntity)
        
        let cube = parentEntity.addCube(material: blueMaterial)
        
        if let animation = try? AnimationResource.generate(with: rotationAnimation) {
            cube.playAnimation(animation)
        }
    }
    
    @MainActor func addGreenCube() async -> AnimationPlaybackController? {
        let greenMaterial = SimpleMaterial(color: .systemGreen, roughness: 0.3, isMetallic: false)
        let parentEntity = Entity(position: SIMD3<Float>(-1.0, 1, -1.5))
        add(parentEntity)
        
        let cube = parentEntity.addCube(material: greenMaterial)
        cube.configureTouchInput()
        
        if let animation = try? AnimationResource.generate(with: rotationAnimation) {
            return cube.playAnimation(animation, startsPaused: true)
        }
        
        return nil
    }
    
    func addRedCube() -> Entity {
        let redMaterial = SimpleMaterial(color: .systemRed, roughness: 0.3, isMetallic: false)
        let parentEntity = Entity(position: SIMD3<Float>(0, 0.5, -0.75))
        add(parentEntity)
        
        return parentEntity.addCube(material: redMaterial)
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

// MARK: - Creating and managing cube entities
extension Entity {
    
    convenience init(position: SIMD3<Float>) {
        self.init()
        setPosition(position, relativeTo: nil)
    }
    
    func applyRotation(amount: simd_quatf, timeInterval: TimeInterval){
        var transform = transform
        transform.rotation *= amount
        move(to: transform, relativeTo: parent, duration: 0.5, timingFunction: .linear)
    }
    
    func addCube(material: SimpleMaterial) -> Entity {
        let child = ModelEntity(mesh: .generateBox(size: 0.25, cornerRadius: 0.01), materials: [material])
        child.setPosition(position, relativeTo: nil)
        
        child.components.set(HoverEffectComponent())
        child.components.set(GroundingShadowComponent(castsShadow: true))
        
        addChild(child)
        
        return child
    }
    
    func configureTouchInput() {
        components.set(InputTargetComponent())
        generateCollisionShapes(recursive: true)
    }
}

// MARK: - View modifiers
extension View {
    func toggleAnimation(controller: AnimationPlaybackController?) -> some View {
        modifier(ToggleAnimationModifier(animationController: controller))
    }
}

private struct ToggleAnimationModifier: ViewModifier {
    @State var animationController: AnimationPlaybackController?
    
    func body(content: Content) -> some View {
        content
            .gesture(
                TapGesture()
                    .targetedToEntity(animationController?.entity ?? Entity())
                    .onEnded { _ in
                        if animationController?.isPlaying == true {
                            animationController?.pause()
                        } else {
                            animationController?.resume()
                        }
                    }
            )
    }
}


#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
