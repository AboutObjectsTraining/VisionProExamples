//
//  ContentView.swift
//  WindowGroups
//
//  Created by Jonathan Lehr on 6/3/24.
//

import SwiftUI

struct ContentView: View {

    @Bindable var viewModel: ViewModel

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack {
            Text("WindowGroups Example")
                .font(.title)
                .padding(50)

            Toggle("Show Window Two", isOn: $viewModel.isShowingWindowTwo)
                .font(.title2)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()
        }
        .onChange(of: viewModel.isShowingWindowTwo) { _, shouldShow in
            if shouldShow {
                openWindow(id: WindowGroupsApp.windowTwo)
            } else {
                dismissWindow(id: WindowGroupsApp.windowTwo)
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(viewModel: ViewModel())
}
