import CPlaydate
import PlaydateKit

struct GameSettingsWriter {
	static func write() -> Bool {
		// Set up file handle
		let file = try! PlaydateKit.File.open(path: "gameSettings.json", mode: File.Options.write)
		let pointer = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<File.FileHandle>.size, alignment: MemoryLayout<File.FileHandle>.alignment)
		pointer.storeBytes(of: file, as: File.FileHandle.self)
		defer { pointer.deallocate() }
		
		// Set up encoder
		var encoder = JSON.Encoder()
		JSON.initEncoder(
			encoder: &encoder,
			writeFunc: GameSettingsWriter.writeStringFunc,
			userdata: pointer,
			pretty: true,
		)
		
		// Write the data
		encoder.startTable(&encoder)

		encoder.addTableMember(&encoder, "timeOfDay", 9)
		encoder.writeString(&encoder, GameSettings.timeOfDay.stringValue, Int32(GameSettings.timeOfDay.stringValue.utf8.count))

		encoder.addTableMember(&encoder, "controlScheme", 13)
		encoder.writeString(&encoder, GameSettings.controlScheme.stringValue, Int32(GameSettings.controlScheme.stringValue.utf8.count))

		encoder.addTableMember(&encoder, "debugMode", 9)
		encoder.writeString(&encoder, GameSettings.debugMode.stringValue, Int32(GameSettings.debugMode.stringValue.utf8.count))

		encoder.addTableMember(&encoder, "musicVolume", 11)
		encoder.writeInt(&encoder, Int32(GameSettings.musicVolume))
		
		encoder.addTableMember(&encoder, "sfxVolume", 9)
		encoder.writeInt(&encoder, Int32(GameSettings.sfxVolume))

		encoder.endTable(&encoder)
		
		try! file.close()
		
		return true
	}
	
	static nonisolated(unsafe) var writeStringFunc: @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CChar>?, CInt) -> Void = { p, str, len in
		let file: File.FileHandle = p!.assumingMemoryBound(to: PlaydateKit.File.FileHandle.self).pointee
		
		let buffer = UnsafeRawBufferPointer(start: str!, count: Int(len))
		
		try! file.write(buffer: buffer)
	}
}
