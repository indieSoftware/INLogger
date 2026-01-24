import INLogger
import SwiftUI

struct ExampleView: View {
	@StateObject var viewModel: ExampleViewModel

	var body: some View {
		ScrollView {
			VStack(spacing: 12) {
				Group {
					Text("\(viewModel.loggerState)").font(.title3)

					Button(action: {
						viewModel.setSimpleLogger()
					}, label: {
						Text("Set simple logger")
					})

					Button(action: {
						viewModel.setDevelopmentLogger()
					}, label: {
						Text("Set development logger")
					})

					Button(action: {
						viewModel.setFileLogger()
					}, label: {
						Text("Set file logger")
					})

					Button(action: {
						viewModel.setDisabledLogger()
					}, label: {
						Text("Disable logger")
					})

					Button(action: {
						viewModel.testFlush()
					}, label: {
						Text("Test flush")
					})

					Spacer().frame(height: 30)
				}

				Group {
					Toggle("\(LogTag.breadcrumb.abbreviation ?? "?") Breadcrumb (enabled)", isOn: $viewModel.breadcrumbTagEnabled)
					Toggle("\(LogTag.general.abbreviation ?? "?") General (enabled tag)", isOn: $viewModel.generalTagEnabled)
					Toggle("\(LogTag.myFeature.abbreviation ?? "?") MyFeature (enabled tag)", isOn: $viewModel.myFeatureTagEnabled)
					Toggle("\(LogTag.disabledTag.abbreviation ?? "?") Disabled tag", isOn: $viewModel.disabledTagEnabled)
					Toggle("\(LogTag.forceDisabledTag.abbreviation ?? "?") Force-disabled tag", isOn: $viewModel.forceDisabledTagEnabled)

					Spacer().frame(height: 16)

					TextField("Enter log message...", text: $viewModel.logMessageText)
						.textFieldStyle(RoundedBorderTextFieldStyle())

					Spacer().frame(height: 16)

					Toggle("☠️ Cash app after log", isOn: $viewModel.crashAppAfterLog)

					Spacer().frame(height: 16)
				}

				Group {
					Button(action: {
						viewModel.logDebug()
					}, label: {
						Text("🔍 Log debug 🔍")
					})
					Button(action: {
						viewModel.logInfo()
					}, label: {
						Text("💬 Log info 💬")
					})
					Button(action: {
						viewModel.logWarn()
					}, label: {
						Text("⚠️ Log warn ⚠️")
					})
					Button(action: {
						viewModel.logError()
					}, label: {
						Text("💣 Log error 💣")
					})
					Button(action: {
						viewModel.logFatal()
					}, label: {
						Text("💥 Log fatal 💥")
					})
				}

				Spacer()
			}
			.padding()
		}
	}
}

struct ExampleView_Previews: PreviewProvider {
	static var previews: some View {
		LoggerSetup.disabledLogger()
		return ExampleView(viewModel: ExampleViewModel())
	}
}
