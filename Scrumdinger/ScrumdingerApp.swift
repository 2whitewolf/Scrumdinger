//
//  ScrumdingerApp.swift
//  Scrumdinger
//
//  Created by Bogdan Sevcenco on 05.07.2022.
//

import SwiftUI

@main
struct ScrumdingerApp: App {
    @StateObject private var store = ScrumStore()
    @State private var errorWrapper: ErrorWrapper?
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ScrumsView(scrums: $store.scrums) {
                    Task {
                        do {
                            try await ScrumStore.save(scrums: store.scrums)
                        } catch {
                            errorWrapper = ErrorWrapper(error: error, guidance: "Try again later.")
                        }
                    }
                }
            }
            .task {
                do {
                    store.scrums = try await ScrumStore.load()
                } catch {
                    errorWrapper = ErrorWrapper(error: error, guidance: "Scrumdinger will load sample data and continue.")
                }
            }
            .sheet(item: $errorWrapper, onDismiss: {
                store.scrums = DailyScrum.sampleData
                
            }) { wrapper in
                ErrorView(errorWrapper: wrapper)
            }
        }
    }
}


struct ScrumsListSeparator: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
                .listRowSeparator(.hidden)
        } else {
            content
        }
    }
}
