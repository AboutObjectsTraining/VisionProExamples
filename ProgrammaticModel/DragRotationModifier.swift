//  Created by Jonathan Lehr on 4/15/24.
//

import SwiftUI

extension View {
    func dragRotation() -> some View {
        self.modifier(DragRotationModifier())
    }
}

private struct DragRotationModifier: ViewModifier {
    @State private var yaw: Double = 0
    @State private var baseYaw: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.radians(yaw), axis: .y)
            .gesture(DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let delta = location3D - startLocation3D
                    yaw = Double(delta.x) + baseYaw
                }
                .onEnded { value in
                    baseYaw = yaw
                }
            )
    }
}
