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
            VStack {
                Group {
                    Toggle("Show Window Two", isOn: $viewModel.isShowingWindowTwo)
                    Toggle("Show Window Three", isOn: $viewModel.isShowingWindowThree)
                }
                .padding(6)
            }
            .font(.title3)
            .padding(24)
            .frame(width: 600)
            .glassBackgroundEffect()
        }
        .onChange(of: viewModel.isShowingWindowTwo) { _, shouldShow in
            if shouldShow {
                openWindow(id: WindowGroupsApp.windowTwo)
            } else {
                dismissWindow(id: WindowGroupsApp.windowTwo)
            }
        }
        .onChange(of: viewModel.isShowingWindowThree) { _, shouldShow in
            if shouldShow {
                openWindow(id: WindowGroupsApp.windowThree)
            } else {
                dismissWindow(id: WindowGroupsApp.windowThree)
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(viewModel: ViewModel())
}
