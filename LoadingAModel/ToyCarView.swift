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
    
    @State private var baseTransform: Transform?
    @State private var entity: Entity?
    
    var dragGesture: some Gesture {
        DragGesture()
            .simultaneously(with: RotateGesture3D(constrainedToAxis: .y))
            .targetedToAnyEntity()
            .onChanged { value in
                let entity = value.entity
                let rotation = value.second?.rotation
                let translation = value.first?.translation3D
                
                if baseTransform == nil {
                    baseTransform = entity.transform
                }
                
                if rotation != nil {
                    let rotationTransform = Transform(AffineTransform3D(rotation: rotation!))
                    entity.transform.rotation = baseTransform!.rotation * rotationTransform.rotation //
                        .inverse
                } else if translation != nil {
                    let convertedTranslation = value.convert(translation!, from: .local, to: entity.parent!)
                    entity.transform.translation = baseTransform!.translation + convertedTranslation
                }
            }
            .onEnded { _ in
                baseTransform = nil
            }
    }

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
            if let entity = try? await ModelEntity(named: "toy_car") {
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
        .gesture(dragGesture)
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
        
        if let extents = (entity as? ModelEntity)?.model?.mesh.bounds.extents {
            entity.components.set(CollisionComponent(shapes: [.generateBox(size: extents)]))
        } else {
            entity.generateCollisionShapes(recursive: false)
        }
    }
    
    @MainActor private func configureAnimations(entity: Entity) async throws {
        
        //        entity.availableAnimations.append(orbit)
        //        entity.playAnimation(orbit, transitionDuration: 1.0, startsPaused: false)
    }
    
    @MainActor private func configureGeometry(entity: Entity) async throws {
        
        entity.transform.scale = [0.02, 0.02, 0.02]
//        entity.transform.translation = [0, 1.0, -1.0]
        entity.position = [0.0, 1.0, -1.0]
        
        print(entity.components)
    }
}

#Preview(immersionStyle: .mixed) {
    ToyCarView()
}
