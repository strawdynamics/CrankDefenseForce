import CPlaydate
import PlaydateKit

struct GameSettingsReader {
	static nonisolated(unsafe) var controlScheme = ControlScheme.standard
	
	static func read() -> Bool {
		let stat = try? PlaydateKit.File.stat(path: "gameSettings.json")
		
		if stat == nil {
			return false
		}
		
		let file = try! PlaydateKit.File.open(path: "gameSettings.json", mode: File.Options.readData)
		
		let fileBuffer = UnsafeMutableRawPointer.allocate(byteCount: Int(stat!.size), alignment: 1)
		
		let bytesRead = try! file.read(buffer: fileBuffer, length: stat!.size)
		
		let uint8Buffer = UnsafeBufferPointer<UInt8>(start: fileBuffer.assumingMemoryBound(to: UInt8.self), count: bytesRead)
		let jsonString = String(decoding: uint8Buffer, as: Unicode.UTF8.self)
		
		var decoder = JSON.Decoder()
		decoder.decodeError = GameSettingsReader.decodeError
		decoder.didDecodeTableValue = GameSettingsReader.didDecodeTableValue
		
		var value = JSON.Value()
		
		let result = JSON.decodeString(using: &decoder, jsonString: jsonString, value: &value)
		
		return result != 0
	}
	
	static nonisolated(unsafe) var decodeError: @convention(c) (UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, Int32) -> Void = { decoder, error, lineNumber in
		if let error = error {
			let message = String(cString: error)
			print("Decode error at line \(lineNumber): \(message)")
		} else {
			print("Unknown decode error at line \(lineNumber)")
		}
	}

//	 void (*didDecodeTableValue)(json_decoder* decoder, const char* key, json_value value);
	static nonisolated(unsafe) var didDecodeTableValue: @convention(c) (UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, json_value) -> Void = { decoder, key, value in
		if let key = key {
			let keyString = String(cString: key)
			let valueType = JsonValueType(rawValue: value.type)
			
			if valueType == .string && keyString == "controlScheme" {
				GameSettings.controlScheme = ControlScheme.fromString(String(cString: value.data.stringval))!
			} else if valueType == .integer && keyString == "musicVolume" {
				GameSettings.musicVolume = Int(value.data.intval)
			} else if valueType == .integer && keyString == "sfxVolume" {
				GameSettings.sfxVolume = Int(value.data.intval)
			} else if (valueType == .trueValue || valueType == .falseValue) && keyString == "showFps" {
				GameSettings.showFps = valueType == .trueValue
			}
		} else {
			print("Unexpected nil key in GameSettingsDecoder!")
		}
	}
}
