import ARKit
import SwiftUI
import RealityKit

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
        
        // Get the current device pose
        guard !entitiesWithBillboarding.isEmpty,
              worldTrackingProvider.state == .running,
              let deviceAnchor = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        else { return }
        
        let translation = Transform(matrix: deviceAnchor.originFromAnchorTransform).translation
        
        // Orient billboarding entities towards the device
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
        if let entity = attachments.entity(for: "Preview") {
            entity.components[BillboardComponent.self] = BillboardComponent()
            content.add(entity)
        }
    } attachments: {
        Attachment(id: "Preview") {
            Text("Preview")
                .font(.largeTitle)
                .padding()
                .glassBackgroundEffect()
        }
    }
    .previewLayout(.sizeThatFits)
}
