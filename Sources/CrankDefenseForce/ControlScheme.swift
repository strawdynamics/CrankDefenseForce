enum ControlScheme: CaseIterable {
	case standard
	case leftyLauncher
	
	var title: String {
		switch self {
		case .standard: return "Standard controls"
		case .leftyLauncher: return "Lefty launcher"
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
