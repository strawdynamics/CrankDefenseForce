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
	
	static nonisolated(unsafe) var lastMainMenuSelectedItemIndex = 0
	
	private static nonisolated(unsafe) var _musicVolume: Int = 10
	
	private static nonisolated(unsafe) var _sfxVolume: Int = 10
	
	private static nonisolated(unsafe) var _controlScheme = ControlScheme.standard
	
	private static nonisolated(unsafe) var _showFps = false
	
	static var controlScheme: ControlScheme {
		get {
			return _controlScheme
		}
		
		set(newValue) {
			_controlScheme = newValue
			writeToDisk()
		}
	}
	
	static var showFps: Bool {
		get {
			return _showFps
		}
		
		set(newValue) {
			_showFps = newValue
			writeToDisk()
		}
	}
	
	static var musicVolume: Int {
		return _musicVolume
	}
	
	static var sfxVolume: Int {
		return _sfxVolume
	}
	
	static let MAX_VOLUME: Int = 10
	
	static func increaseMusicVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.incremented
		_musicVolume += 1
		if _musicVolume > MAX_VOLUME {
			res = .unchanged
			_musicVolume = MAX_VOLUME
		}
		
		writeToDisk()
		
		return res
	}
	
	static func decreaseMusicVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.decremented
		
		_musicVolume -= 1
		if _musicVolume < 0 {
			res = .unchanged
			_musicVolume = 0
		}
		
		writeToDisk()
		
		return res
	}
	
	static func increaseSfxVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.incremented
		_sfxVolume += 1
		if _sfxVolume > MAX_VOLUME {
			res = .unchanged
			_sfxVolume = MAX_VOLUME
		}
		
		writeToDisk()
		
		return res
	}
	
	static func decreaseSfxVolume() -> VolumeChangeResult {
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
