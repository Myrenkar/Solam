//
//  OutputWriter.swift
//

import Files

final class OutputWriter {
	
	private static let file = "weather.log"
	
	static var savePath: String {
		return "\(Folder.current.path)\(OutputWriter.file)"
	}
	
	static func write(_ content: String) throws{
		let homeFolder = Folder.current
		let home = try homeFolder.createFile(named: file)
		try home.write(string: content)
	}
}
