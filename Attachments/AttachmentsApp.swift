//
//  AttachmentsApp.swift
//  Attachments
//
//  Created by Jonathan Lehr on 5/23/24.
//

import SwiftUI

@main
struct AttachmentsApp: App {
    
    init() {
        BillboardComponent.registerComponent()
        BillboardSystem.registerSystem()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
