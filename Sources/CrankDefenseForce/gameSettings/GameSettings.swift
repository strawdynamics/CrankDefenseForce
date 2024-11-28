import PlaydateKit

class GameSettings {
	enum VolumeChangeResult {
		case incremented
		case decremented
		case unchanged
	}
	
	static func initialize() {
		readFromDisk()
	}
	
	private static nonisolated(unsafe) var _musicVolume: Float = 10
	
	private static nonisolated(unsafe) var _sfxVolume: Float = 10
	
	private static nonisolated(unsafe) var _controlScheme = ControlScheme.standard
	
	static var controlScheme: ControlScheme {
		get {
			return _controlScheme
		}
		
		set(newValue) {
			_controlScheme = newValue
			writeToDisk()
		}
	}
	
	static func incrementMusicVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.incremented
		_musicVolume += 1
		if _musicVolume > 10 {
			res = .unchanged
			_musicVolume = 10
		}
		
		writeToDisk()
		
		return res
	}
	
	static func decrementMusicVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.decremented
		
		_musicVolume -= 1
		if _musicVolume < 0 {
			res = .unchanged
			_musicVolume = 0
		}
		
		writeToDisk()
		
		return res
	}
	
	static func incrementSfxVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.incremented
		_sfxVolume += 1
		if _sfxVolume > 10 {
			res = .unchanged
			_sfxVolume = 10
		}
		
		writeToDisk()
		
		return res
	}
	
	static func decrementSfxVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.decremented
		_sfxVolume -= 1
		if _sfxVolume < 0 {
			res = .unchanged
			_sfxVolume = 0
		}
		
		writeToDisk()
		
		return res
	}
	
	private static func readFromDisk() {
		if GameSettingsReader.read() {
//			print("READ SCHEME: \(GameSettingsReader.controlScheme)")
//			_controlScheme = GameSettingsReader.controlScheme
		} else {
			// TODO: Write current (defaults) to disk
		}
	}
	
	private static func writeToDisk() {
		// TODO: Write to disk
	}
}
