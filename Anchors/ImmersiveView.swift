//
//  Created 6/17/24 by Jonathan Lehr
//  Copyright © 2024 About Objects.
//  

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    @State var anchorEntity: Entity = {
        let anchorEntity = AnchorEntity(.plane(.vertical,
                                               classification: .wall,
                                               minimumBounds: [0.5, 0.5]))
        
        let planeMesh = MeshResource.generatePlane(
            width: 1,
            depth: 0.75,
            cornerRadius: 0.1
        )
        let imageMaterial = Self.loadImageMaterial(imageName: "Think Different")
        let entity = ModelEntity(mesh: planeMesh, materials: [imageMaterial])
        
        anchorEntity.addChild(entity)
        
        return anchorEntity
    }()
    
    var body: some View {
        RealityView { content in
            content.add(anchorEntity)
        }
    }
    
    static func loadImageMaterial(imageName: String) -> SimpleMaterial {
        guard let resource = try? TextureResource.load(named: imageName) else {
            fatalError("Unable to load image named \(imageName)")
        }
        
        var material = SimpleMaterial()
        material.color.texture = .init(resource)
        return material
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
