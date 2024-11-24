import CPlaydate
import PlaydateKit

struct GameSettingsReader {
	static nonisolated(unsafe) var controlScheme = ControlScheme.standard
	
	static func read() -> Bool {
		var decoder = JSON.Decoder()
		decoder.decodeError = GameSettingsReader.decodeError
		decoder.didDecodeTableValue = GameSettingsReader.didDecodeTableValue
		
		var value = JSON.Value()
		
		let result = JSON.decodeString(using: &decoder, jsonString: #"{"controlScheme": "standard", "musicVolume": 5, "sfxVolume": 5}"#, value: &value)
		
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

	// void (*didDecodeTableValue)(json_decoder* decoder, const char* key, json_value value);
	static nonisolated(unsafe) var didDecodeTableValue: @convention(c) (UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, json_value) -> Void = { decoder, key, value in
		if let key = key {
			let keyString = String(cString: key)
			print("Decoded table value for key \(keyString): \(value.data), \(value.type)")
			let valueType = JsonValueType(rawValue: value.type)
			
//			if valueType == .string && keyString == "controlScheme" {
////				print("why does this crash?")
////				String(cString: )
////				controlScheme = ControlScheme.from(string: String(cString: value.data.stringval)) ?? .standard
//			}
		} else {
			print("Unexpected nil key in GameSettingsDecoder!")
		}
	}
}
