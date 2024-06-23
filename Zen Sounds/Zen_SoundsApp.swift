//
//  Zen_SoundsApp.swift
//  Zen Sounds
//
//  Created by Arunya Goojar on 10/05/24.
//

import SwiftUI
import Sparkle

@main
struct Zen_SoundsApp: App {
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandGroup(after: .appInfo) {
                            CheckForUpdatesView(updater: updaterController.updater)
            }
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
