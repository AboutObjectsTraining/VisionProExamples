//  Created by Jonathan Lehr on 4/15/24.
//

import SwiftUI
import RealityKit

extension View {
    func pitchAndYaw() -> some View {
        modifier(PitchAndYawModifier())
    }
    func pitchAndYaw(targetEntity: Entity) -> some View {
        modifier(PitchAndYawEntityModifier(entity: targetEntity))
    }
}

private struct PitchAndYawEntityModifier: ViewModifier {
    let entity: Entity
    @State private var yaw = 0.0
    @State private var baseYaw = 0.0
    @State private var pitch = 0.0
    @State private var basePitch = 0.0
    
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture()
                .targetedToEntity(entity)
                .onChanged { value in
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let delta = location3D - startLocation3D
                    yaw = Double(delta.x) + baseYaw
                    pitch = Double(delta.y) + basePitch
                    
                    let deltaX = simd_quatf(angle: Float(yaw), axis: [0, 1, 0])
                    let deltaY = simd_quatf(angle: Float(-pitch), axis: [1, 0, 0])
                    
                    entity.orientation = deltaY * deltaX
                }
                .onEnded { value in
                    baseYaw = yaw
                    basePitch = pitch
                }
            )
    }
}

private struct PitchAndYawModifier: ViewModifier {
    @State private var yaw = 0.0
    @State private var baseYaw = 0.0
    @State private var pitch = 0.0
    @State private var basePitch = 0.0
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.radians(yaw), axis: .y)
            .rotation3DEffect(.radians(pitch), axis: .x)
            .gesture(DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let delta = location3D - startLocation3D
                    yaw = Double(delta.x) + baseYaw
                    pitch = Double(delta.y) + basePitch
                }
                .onEnded { value in
                    baseYaw = yaw
                    basePitch = pitch
                }
            )
    }
}
