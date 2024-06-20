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
    
    @State private var baseTransform: Transform?
    
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
    
    var modelUrl: URL {
        let url = Bundle.main.path(forResource: "toy_car", ofType: "usdz") ?? ""
        return URL(fileURLWithPath: url)
    }
    
    var body: some View {
        
        RealityView { content in
            // Load with URL
            if let entity = try? await ModelEntity(contentsOf: modelUrl) {
                try? await configureGeometry(entity: entity)
                try? await configureLighting(entity: entity)
                try? await configureTouches(entity: entity)
                content.add(entity)
            }
            
            // Load with entity name
            if let entity = try? await ModelEntity(named: "toy_car") {
                print("Loading toy car...")
                try? await configureGeometry(entity: entity)
                try? await configureLighting(entity: entity)
                try? await configureTouches(entity: entity)
                content.add(entity)
            }
        } placeholder: {
            ProgressView()
        }
        .gesture(dragGesture)
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
        
        if let extents = (entity as? ModelEntity)?.model?.mesh.bounds.extents {
            entity.components.set(CollisionComponent(shapes: [.generateBox(size: extents)]))
        } else {
            entity.generateCollisionShapes(recursive: false)
        }
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
