import SwiftUI

@main
struct INLoggerExample: App {
	var body: some Scene {
		WindowGroup {
			ExampleView(viewModel: ExampleViewModel())
		}
	}
}
