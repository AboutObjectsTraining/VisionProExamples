/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A RealityKit system that keeps entities with a BillboardComponent facing toward the camera.
*/

import ARKit
import SwiftUI
import RealityKit
import RealityKitContent

public struct BillboardSystem: System {

    static let query = EntityQuery(where: .has(BillboardComponent.self))

    private let arkitSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()
    
    public init(scene: RealityKit.Scene) {
        configureArkitSession()
    }

    func configureArkitSession() {
        Task {
            do {
                try await arkitSession.run([worldTrackingProvider])
            } catch {
                print(error)
            }
        }
    }

    public func update(context: SceneUpdateContext) {
        let entitiesWithBillboarding = context.scene.performQuery(Self.query).map { $0 }

        guard !entitiesWithBillboarding.isEmpty,
              let deviceAnchor = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        else { return }

        let translation = Transform(matrix: deviceAnchor.originFromAnchorTransform).translation

        for entity in entitiesWithBillboarding {
            entity.look(at: translation,
                        from: entity.position(relativeTo: nil),
                        relativeTo: nil,
                        forward: .positiveZ)
        }
    }
}

#Preview {
    RealityView { content, attachments in
        BillboardSystem.registerSystem()
        BillboardComponent.registerComponent()
        
        if let entity = attachments.entity(for: "previewTag") {

            let billboardComponent = BillboardComponent()
            entity.components[BillboardComponent.self] = billboardComponent
            
            content.add(entity)
        }
    } attachments: {
        Attachment(id: "previewTag") {
            Text("Preview")
                .font(.system(size: 100))
                .glassBackgroundEffect()
        }
    }
    .previewLayout(.sizeThatFits)
}
