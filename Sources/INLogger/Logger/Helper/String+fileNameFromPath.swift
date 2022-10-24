import Foundation

public extension String {
	/// Returns the last path component of this string.
	/// Suitable to get the file's name from a path.
	/// Requires that this string is a file path.
	var fileNameFromPath: String {
		let url = URL(fileURLWithPath: self)
		return url.lastPathComponent
	}
}
