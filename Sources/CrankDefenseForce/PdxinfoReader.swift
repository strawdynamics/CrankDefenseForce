import PlaydateKit;

class PdxinfoReader {
	enum PdxinfoReaderError: Swift.Error {
		case noStat(path: String)
		case noHandle(path: String)
		case read(path: String)
		case invalidFileSize(path: String, bufferSize: Int, bytesRead: Int)
	}
	
	let path: String
	
	init(path: String) {
		self.path = path
	}
	
	func read() throws(PdxinfoReaderError) -> Dictionary<String.UTF8View, String> {
		guard let stat = try? File.stat(path: path) else {
			throw PdxinfoReaderError.noStat(path: path)
		}
		
		let bufferSize = Int(stat.size)
		
		guard let handle = try? File.open(path: path, mode: .read) else {
			throw PdxinfoReaderError.noHandle(path: path)
		}
		let buffer = UnsafeMutableRawPointer.allocate(
			byteCount: bufferSize,
			alignment: 1
		)
		defer { buffer.deallocate() }

		guard let bytesRead = try? handle.read(buffer: buffer, length: CUnsignedInt(bufferSize)) else {
			throw PdxinfoReaderError.read(path: path)
		}
		
		if bytesRead != bufferSize {
			throw PdxinfoReaderError.invalidFileSize(
				path: path,
				bufferSize: bufferSize,
				bytesRead: bytesRead
			)
		}
		
		let uint8Buffer = UnsafeBufferPointer<UInt8>(start: buffer.assumingMemoryBound(to: UInt8.self), count: bytesRead)
		let pdxinfoString = String(decoding: uint8Buffer, as: Unicode.UTF8.self)
		
		return parse(pdxinfoString: pdxinfoString)
	}
	
	private func parse(pdxinfoString: String) -> Dictionary<String.UTF8View, String> {
		var parsed: Dictionary<String.UTF8View, String> = [:]
		
		pdxinfoString.utf8.split(separator: "\n".utf8.first!).forEach { line in
			if line.first! == "#".utf8.first! {
				return
			}
			
			let parts = line.split(separator: "=".utf8.first!, maxSplits: 1)
			
			if parts.count == 2 {
				parsed[String(decoding: parts[0], as: UTF8.self).utf8] = String(parts[1])
			}
		}
		
		return parsed
	}
}
