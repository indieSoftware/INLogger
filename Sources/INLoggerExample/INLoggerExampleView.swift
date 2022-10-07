import INLogger
import SwiftUI

struct INLoggerExampleView: View {
	var body: some View {
		Text(INLoggerVersion.version.description)
	}
}

struct INLoggerExampleView_Previews: PreviewProvider {
	static var previews: some View {
		INLoggerExampleView()
	}
}
