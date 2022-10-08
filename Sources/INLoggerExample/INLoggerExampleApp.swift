import SwiftUI

@main
struct INLoggerExampleApp: App {
	var body: some Scene {
		WindowGroup {
			ExampleView(viewModel: ExampleViewModel())
		}
	}
}
