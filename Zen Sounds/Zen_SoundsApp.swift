//
//  Zen_SoundsApp.swift
//  Zen Sounds
//
//  Created by Arunya Goojar on 10/05/24.
//

import SwiftUI

@main
struct Zen_SoundsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandMenu("Controls") {
                Button("Play / Pause") {}.keyboardShortcut(.space, modifiers: []).disabled(true)
                Divider()
                Button("Increase volume") {}.keyboardShortcut("=", modifiers: [.command]).disabled(true)
                Divider()
                Button("Decrease volume") {}.keyboardShortcut("-", modifiers: [.command]).disabled(true)
            }
        }
    }
}
