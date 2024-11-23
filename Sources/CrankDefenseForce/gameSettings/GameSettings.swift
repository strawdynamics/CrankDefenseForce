import PlaydateKit

class GameSettings {
	static func initialize() {
		readFromDisk()
	}
	
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
