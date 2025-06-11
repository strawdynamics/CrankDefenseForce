import UTF8ViewExtensions

enum TimeOfDay {
	case day
	case night
	
	static func fromString(_ input: String) -> TimeOfDay? {
		switch input.utf8 {
		case "day": return .day
		case "night": return .night
		default: return nil
		}
	}
	
	var title: String {
		switch self {
		case .day: return "Day"
		case .night: return "Night"
		}
	}
	
	var stringValue: String {
		switch self {
		case .day:
			return "day"
		case .night:
			return "night"
		}
	}
	
	var next: TimeOfDay {
		switch self {
		case .day: return .night
		case .night: return .day
		}
	}
	
	var prev: TimeOfDay {
		switch self {
		case .day: return .night
		case .night: return .day
		}
	}
}
