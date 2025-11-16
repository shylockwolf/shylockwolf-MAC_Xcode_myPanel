//
//  myPanelApp.swift
//  myPanel
//
//  Created by Shylock Wolf on 2025/11/16.
//

import SwiftUI

@main
struct myPanelApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 350, idealWidth: 350, maxWidth: .infinity,
                       minHeight: 450, idealHeight: 450, maxHeight: .infinity)
        }
        .defaultSize(width: 350, height: 450)
    }
}