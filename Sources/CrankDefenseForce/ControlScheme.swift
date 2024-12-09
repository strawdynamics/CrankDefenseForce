enum ControlScheme: CaseIterable {
	case standard
	case leftyLauncher
	
	var title: String {
		switch self {
		case .standard: return "Standard controls"
		case .leftyLauncher: return "Lefty launcher"
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
