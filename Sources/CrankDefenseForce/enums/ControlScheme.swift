import UTF8ViewExtensions

enum ControlScheme {
	case standard
	case leftyLauncher
	case lrSwitch

	static func fromString(_ input: String) -> ControlScheme? {
		switch input.utf8 {
		case "standard": return .standard
		case "leftylauncher": return .leftyLauncher
		case "lrSwitch": return .lrSwitch
		default: return nil
		}
	}

	var title: String {
		switch self {
		case .standard: return "Standard controls"
		case .leftyLauncher: return "Lefty launcher"
		case .lrSwitch: return "L/R switch"
		}
	}

	var stringValue: String {
		switch self {
		case .standard:
			return "standard"
		case .leftyLauncher:
			return "leftyLauncher"
		case .lrSwitch:
			return "lrSwitch"
		}
	}

	var description: String {
		switch self {
		case .standard:
			return """
				Turn: 🎣, ⬅️ ➡️
				Launch: Ⓑ Ⓐ
				Switch: ⬆️ ⬇️
				"""
		case .leftyLauncher:
			return """
				Turn: 🎣, Ⓑ Ⓐ
				Launch: ⬅️ ➡️
				Switch: ⬆️ ⬇️
				"""
		case .lrSwitch:
			return """
				Turn: 🎣
				Launch: Ⓑ Ⓐ
				Switch: ⬅️ ➡️
				"""
		}
	}

	var next: ControlScheme {
		switch self {
		case .standard: return .leftyLauncher
		case .leftyLauncher: return .lrSwitch
		case .lrSwitch: return .standard
		}
	}

	var prev: ControlScheme {
		switch self {
		case .lrSwitch: return .leftyLauncher
		case .leftyLauncher: return .standard
		case .standard: return .lrSwitch
		}
	}
}
