enum ControlScheme {
	case standard
	case leftyLauncher
	
	static func fromString(_ input: String) -> ControlScheme? {
		switch input.lowercased() {
		case "standard": return .standard
		case "leftylauncher": return .leftyLauncher
		default: return nil
		}
	}
	
	var title: String {
		switch self {
		case .standard: return "Standard controls"
		case .leftyLauncher: return "Lefty launcher"
		}
	}
	
	var stringValue: String {
		switch self {
		case .standard:
			return "standard"
		case .leftyLauncher:
			return "leftyLauncher"
		}
	}
	
	var description: String {
		switch self {
		case .standard: return """
Turn: 🎣, ⬅️ ➡️
Launch: Ⓑ Ⓐ
Switch: ⬆️ ⬇️
"""
		case .leftyLauncher: return """
Turn: 🎣, Ⓑ Ⓐ
Launch: ⬅️ ➡️
Switch: ⬆️ ⬇️
"""
		}
	}
	
	var next: ControlScheme {
		switch self {
		case .standard: return .leftyLauncher
		case .leftyLauncher: return .standard
		}
	}
	
	var prev: ControlScheme {
		switch self {
		case .standard: return .leftyLauncher
		case .leftyLauncher: return .standard
		}
	}
}
