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
	
	func read() throws(PdxinfoReaderError) -> Dictionary<Utf8Key, String> {
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
		
//		return [Utf8Key("test"): "stuff"]
		return parse(pdxinfoString: pdxinfoString)
	}
	
	private func parse(pdxinfoString: String) -> Dictionary<Utf8Key, String> {
		var parsed: Dictionary<Utf8Key, String> = [:]
		
//		print("f \(pdxinfoString)")
		
		// FIXME: This line errors…
//		let q = pdxinfoString.split(separator: "e")
//		let q = pdxinfoString.firstIndex(of: "\n")
//		let _ = pdxinfoString.split(separator: "\n")
//		pdxinfoString.split(separator: "\n").forEach { line in
//			if line.first == "#" {
//				return
//			}
//			
//			let parts = line.split(separator: "=", maxSplits: 1)
//			
//			if parts.count == 2 {
//				parsed[Utf8Key(String(parts[0]))] = String(parts[1])
//			}
//		}
		
		return parsed
	}
}
