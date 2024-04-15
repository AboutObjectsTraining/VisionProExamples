//
//  ImmersiveView.swift
//  LoadingAModel
//
//  Created by Jonathan Lehr on 4/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ToyCarView: View {
    let defaultTilt = 20.0
    let values = ["One"]
    @State private var eulerAngles = EulerAngles()
    @State private var entity: Entity?
    
//    private var orbitAnimation: OrbitAnimation {
//        OrbitAnimation(name: "orbit",
//                       duration: 10.0,
//                       axis: SIMD3<Float>(x: 1.0, y: 0.0, z: 0.0),
//                       startTransform: Transform(scale: simd_float3(10,10,10),
//                                                 rotation: simd_quatf(ix: 10, iy: 20, iz: 20, r: 100),
//                                                 translation: simd_float3(11, 2, 3)),
//                       spinClockwise: true,
//                       orientToPath: true,
//                       rotationCount: 100.0,
//                       bindTarget: nil)
//    }

    var body: some View {
        
        RealityView { content in
            if let entity = try? await Entity(named: "toy_car", in: Bundle.main) {
                print("Loading toy car...")
                try? await configureGeometry(entity: entity)
                try? await configureLighting(entity: entity)
                try? await configureTouches(entity: entity)
                content.add(entity)
                self.entity = entity
                print("Loaded toy car")
            }
        } placeholder: {
            ProgressView()
        }
        .dragRotation(sensitivity: 3)
        //.rotation3DEffect(.init(eulerAngles: eulerAngles))
        .transform3DEffect(.init(translation: .init(x: 0, y: 0, z: 0)))
    }
    
//    private func animateRotation(duration: Double, degrees: Double) {
//        
//        guard let entity = entity else { return }
//        
//        var currentTransform = entity.transform
//        let rotation = simd_quatf(angle: Float(degrees), axis: [1, 0, 0])
//        currentTransform.rotation = rotation * currentTransform.rotation
//        entity.transform = currentTransform
//    }
//    
//    
//    private func animateOrbit(entity: Entity) {
//        let orbit = try? AnimationResource.generate(with: orbitAnimation)
//        if let orbit = orbit {
//            entity.playAnimation(orbit)
//        }
//    }
    
    @MainActor private func configureLighting(entity: Entity) async throws {
        
        let image = try await EnvironmentResource(named: "Sunlight", in: Bundle.main)
        let component = ImageBasedLightComponent(source: .single(image), intensityExponent: 7.5)
        
        entity.components[ImageBasedLightComponent.self] = component
        entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
        
        entity.setSunlight(intensity: 1)
    }
    
    @MainActor private func configureTouches(entity: Entity) async throws {
        
        entity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
    }
    
    @MainActor private func configureAnimations(entity: Entity) async throws {
        
        //        entity.availableAnimations.append(orbit)
        //        entity.playAnimation(orbit, transitionDuration: 1.0, startsPaused: false)
    }
    
    @MainActor private func configureGeometry(entity: Entity) async throws {
        
//        let boundingBox = entity.visualBounds(relativeTo: nil)
//        boundingBox.transform(by: .)
        entity.transform.scale = [0.1, 0.1, 0.1]
        entity.transform.translation = [0, 0, 0]
//        entity.position = [0.0, 1.0, -1.0]
        
        print(entity.components)
    }
}

extension View {
    /// Enables people to drag an entity to rotate it, with optional limitations
    /// on the rotation in yaw and pitch.
    func dragRotation(
        yawLimit: Angle? = nil,
        pitchLimit: Angle? = nil,
        sensitivity: Double = 10,
        axRotateClockwise: Bool = false,
        axRotateCounterClockwise: Bool = false
    ) -> some View {
        self.modifier(
            DragRotationModifier(
                yawLimit: yawLimit,
                pitchLimit: pitchLimit,
                sensitivity: sensitivity,
                axRotateClockwise: axRotateClockwise,
                axRotateCounterClockwise: axRotateCounterClockwise
            )
        )
    }
}

/// A modifier that converts drag gestures into entity rotation.
private struct DragRotationModifier: ViewModifier {
    var yawLimit: Angle?
    var pitchLimit: Angle?
    var sensitivity: Double
    var axRotateClockwise: Bool
    var axRotateCounterClockwise: Bool

    @State private var baseYaw: Double = 0
    @State private var yaw: Double = 0
    @State private var basePitch: Double = 0
    @State private var pitch: Double = 0

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.radians(yaw == 0 ? 0.01 : yaw), axis: .y)
            .rotation3DEffect(.radians(pitch == 0 ? 0.01 : pitch), axis: .x)
            .gesture(DragGesture(minimumDistance: 0.0)
                .targetedToAnyEntity()
                .onChanged { value in
                    // Find the current linear displacement.
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let delta = location3D - startLocation3D

                    // Use an interactive spring animation that becomes
                    // a spring animation when the gesture ends below.
                    withAnimation(.interactiveSpring) {
                        yaw = spin(displacement: Double(delta.x), base: baseYaw, limit: yawLimit)
                        pitch = spin(displacement: Double(delta.y), base: basePitch, limit: pitchLimit)
                    }
                }
                .onEnded { value in
                    // Find the current and predicted final linear displacements.
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let predictedEndLocation3D = value.convert(value.predictedEndLocation3D, from: .local, to: .scene)
                    let delta = location3D - startLocation3D
                    let predictedDelta = predictedEndLocation3D - location3D

                    // Set the final spin value using a spring animation.
                    withAnimation(.spring) {
                        yaw = finalSpin(
                            displacement: Double(delta.x),
                            predictedDisplacement: Double(predictedDelta.x),
                            base: baseYaw,
                            limit: yawLimit)
                        pitch = finalSpin(
                            displacement: Double(delta.y),
                            predictedDisplacement: Double(predictedDelta.y),
                            base: basePitch,
                            limit: pitchLimit)
                    }

                    // Store the last value for use by the next gesture.
                    baseYaw = yaw
                    basePitch = pitch
                }
            )
            .onChange(of: axRotateClockwise) {
                withAnimation(.spring) {
                    yaw -= (.pi / 6)
                    baseYaw = yaw
                }
            }
            .onChange(of: axRotateCounterClockwise) {
                withAnimation(.spring) {
                    yaw += (.pi / 6)
                    baseYaw = yaw
                }
            }
    }

    /// Finds the spin for the specified linear displacement, subject to an
    /// optional limit.
    private func spin(
        displacement: Double,
        base: Double,
        limit: Angle?
    ) -> Double {
        if let limit {
            return atan(displacement * sensitivity) * (limit.degrees / 90)
        } else {
            return base + displacement * sensitivity
        }
    }

    /// Finds the final spin given the current and predicted final linear
    /// displacements, or zero when the spin is restricted.
    private func finalSpin(
        displacement: Double,
        predictedDisplacement: Double,
        base: Double,
        limit: Angle?
    ) -> Double {
        // If there is a spin limit, always return to zero spin at the end.
        guard limit == nil else { return 0 }

        // Find the projected final linear displacement, capped at 1 more revolution.
        let cap = .pi * 2.0 / sensitivity
        let delta = displacement + max(-cap, min(cap, predictedDisplacement))

        // Find the final spin.
        return base + delta * sensitivity
    }
}


#Preview(immersionStyle: .mixed) {
    ToyCarView()
}
