//  Created by Jonathan Lehr on 4/15/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ToyCarView: View {
    let defaultTilt = 20.0
    let values = ["One"]
    @State private var entity: Entity?
    
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
        .dragRotation()
        .transform3DEffect(.init(translation: .init(x: 0, y: 0, z: 0)))
    }
    
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
    
    @MainActor private func configureGeometry(entity: Entity) async throws {
        entity.transform.scale = [0.1, 0.1, 0.1]
        entity.transform.translation = [0, 0, 0]
        print(entity.components)
    }
}
