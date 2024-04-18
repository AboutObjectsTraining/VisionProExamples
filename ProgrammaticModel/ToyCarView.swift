//  Created by Jonathan Lehr on 4/15/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ToyCarView: View {
    let defaultTilt = 20.0
    let values = ["One"]
    @State private var toyContainerEntity: Entity? = Entity()
    @State private var toyCarEntity: Entity? = Entity()
    @State private var cube1: Entity = Entity()
    @State private var cube2: Entity = Entity()
    
    var body: some View {
        
        RealityView { content in
            if let entity = try? await Entity(named: "toy_car", in: Bundle.main) {
                self.toyContainerEntity = entity
//                self.toyContainerEntity = ModelEntity(
//                    mesh: .generateBox(width: 3, height: 3, depth: 3),
//                    materials: [SimpleMaterial(color: .blue, isMetallic: true)])

                toyCarEntity = toyContainerEntity?.children.first
                
                try? await configureLighting()
                configureGeometry()
                configureGroundingShadow()
                configureTouches()
                
                content.add(entity)
                print(entity.components)
                
                cube1 = addCube(
                    content: content,
                    position: SIMD3<Float>(-2, 3, -3),
                    material: SimpleMaterial(color: .systemBlue, roughness: 0.3, isMetallic: false)
                )
                cube2 = addCube(
                    content: content,
                    position: SIMD3<Float>(2, 3, -3),
                    material: SimpleMaterial(color: .systemPink, roughness: 0, isMetallic: true)
                )
            }
        } placeholder: {
            ProgressView()
        }
        .pitchAndYaw(targetEntity: toyContainerEntity!)
        .pitchAndYaw(targetEntity: cube1)
        .pitchAndYaw(targetEntity: cube2)
        .transform3DEffect(.init(translation: Vector3D(x: 0, y: 0, z: -3000)))
    }
    
    func addCube(content: RealityViewContent, position: SIMD3<Float>, material: SimpleMaterial) -> Entity {
        let entity = ModelEntity(
            mesh: .generateBox(size: 0.5, cornerRadius: 0.05),
            materials: [material],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.5)),
            mass: 0.0
        )
        entity.setPosition(position, relativeTo: nil)
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))

//        let material = PhysicsMaterialResource.generate(friction: 100, restitution: 0.5)
//        entity.components.set(PhysicsBodyComponent(shapes: entity.collision!.shapes,
//                                                   mass: 1.0,
//                                                   material: material,
//                                                   mode: .dynamic))
        
        content.add(entity)
        
        return entity
    }
    
    @MainActor private func configureLighting() async throws {
        guard let entity = toyContainerEntity else { return }
        let image = try await EnvironmentResource(named: "Sunlight", in: Bundle.main)
        let component = ImageBasedLightComponent(source: .single(image), intensityExponent: 7.5)
        
        entity.components[ImageBasedLightComponent.self] = component
        entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
        
        entity.setSunlight(intensity: 1)
    }
    
    @MainActor private func configureGroundingShadow() {
        guard let entity = toyContainerEntity else { return }
        entity.enumerateHierarchy { entity in
            if entity is ModelEntity {
                entity.components.set(GroundingShadowComponent(castsShadow: true))
            }
        }
    }
    
    @MainActor private func configureTouches() {
        guard let entity = toyCarEntity else { return }
        entity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
    }
    
    @MainActor private func configureGeometry() {
        guard /*let toyCar = toyCarEntity, */ let container = toyContainerEntity else { return }
//        toyCar.transform.scale = [0.1, 0.1, 0.1]
        container.transform.scale = [0.05, 0.05, 0.05]
//        container.transform.translation = [-1, 0, -2]
    }
}

extension Entity {

    func enumerateHierarchy(_ callback: (Entity) -> Void) {
        enumerate(callback)
    }

    func enumerate(_ callback: (Entity) -> Void) {
        callback(self)
        children.forEach { $0.enumerateHierarchy(callback) }
    }
}
