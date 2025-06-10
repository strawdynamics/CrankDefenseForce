import UTF8ViewExtensions

enum DebugMode {
	case disabled
	case fpsOnly
	case enabled

	static func fromString(_ input: String) -> Self? {
		switch input.utf8 {
		case "disabled": return .disabled
		case "fpsOnly": return .fpsOnly
		case "enabled": return .enabled
		default: return nil
		}
	}

	var title: String {
		switch self {
		case .disabled: return "Debug disabled"
		case .fpsOnly: return "Show FPS"
		case .enabled: return "Debug enabled"
		}
	}

	var stringValue: String {
		switch self {
		case .disabled:
			return "disabled"
		case .fpsOnly:
			return "fpsOnly"
		case .enabled:
			return "enabled"
		}
	}

	var next: Self {
		switch self {
		case .disabled: return .fpsOnly
		case .fpsOnly: return .enabled
		case .enabled: return .disabled
		}
	}

	var prev: Self {
		switch self {
		case .disabled: return .enabled
		case .fpsOnly: return .disabled
		case .enabled: return .fpsOnly
		}
	}
}
