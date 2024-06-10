//
//  Created 6/10/24 by Jonathan Lehr
//  Copyright © 2024 About Objects.
//  

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        HStack(spacing: 60) {
            VStack {
                Text("Toy Car")
                    .font(.title)
                
                Model3D(named: "toy_car") { model in
                    model
                        .resizable()
                        .frame(width: 240, height: 240)
                        .background(Color.orange.gradient, in: Circle())
                } placeholder: {
                    ProgressView()
                }
            }
            
            VStack {
                Text("Toy Biplane")
                    .font(.title)
                
                Model3D(named: "toy_biplane_idle") { model in
                    model
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 480, height: 480)
                        .background(Color.blue.gradient, in: Circle())
                } placeholder: {
                    ProgressView()
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
