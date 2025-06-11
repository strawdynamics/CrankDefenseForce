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
	
	private static nonisolated(unsafe) var _timeOfDay: TimeOfDay = .night
	
	private static nonisolated(unsafe) var _debugMode: DebugMode = .disabled

	static var timeOfDay: TimeOfDay {
		get {
			return _timeOfDay
		}
		
		set(newValue) {
			_timeOfDay = newValue
		}
	}
	
	static var controlScheme: ControlScheme {
		get {
			return _controlScheme
		}
		
		set(newValue) {
			_controlScheme = newValue
		}
	}
	
	static var debugMode: DebugMode {
		get {
			return _debugMode
		}

		set(newValue) {
			_debugMode = newValue
		}
	}

	static var musicVolume: Int {
		get {
			return _musicVolume
		}
		
		// Prefer increase/decrease for use in UI. Used for save/load
		set(newValue) {
			_musicVolume = newValue
		}
	}
	
	static var sfxVolume: Int {
		get {
			return _sfxVolume
		}
		
		// Prefer increase/decrease for use in UI. Used for save/load
		set(newValue) {
			_sfxVolume = newValue
		}
	}
	
	static let MAX_VOLUME: Int = 10
	
	static func increaseMusicVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.incremented
		_musicVolume += 1
		if _musicVolume > MAX_VOLUME {
			res = .unchanged
			_musicVolume = MAX_VOLUME
		}
		
		return res
	}
	
	static func decreaseMusicVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.decremented
		
		_musicVolume -= 1
		if _musicVolume < 0 {
			res = .unchanged
			_musicVolume = 0
		}
		
		return res
	}
	
	static func increaseSfxVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.incremented
		_sfxVolume += 1
		if _sfxVolume > MAX_VOLUME {
			res = .unchanged
			_sfxVolume = MAX_VOLUME
		}
		
		return res
	}
	
	static func decreaseSfxVolume() -> VolumeChangeResult {
		var res = VolumeChangeResult.decremented
		_sfxVolume -= 1
		if _sfxVolume < 0 {
			res = .unchanged
			_sfxVolume = 0
		}

		return res
	}
	
	private static func readFromDisk() {
		_ = GameSettingsReader.read()
	}
	
	public static func writeToDisk() {
		_ = GameSettingsWriter.write()
	}
}
