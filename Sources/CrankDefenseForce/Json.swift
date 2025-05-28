enum JsonValueType: Int8, CustomStringConvertible {
	case null = 0 // kJSONNull
	case trueValue = 1 // kJSONTrue
	case falseValue = 2 // kJSONFalse
	case integer = 3 // kJSONInteger
	case float = 4 // kJSONFloat
	case string = 5 // kJSONString
	case array = 6 // kJSONArray
	case table = 7 // kJSONTable
	
	var description: String {
		switch self {
		case .null:
			return "null"
		case .trueValue:
			return "true"
		case .falseValue:
			return "false"
		case .integer:
			return "integer"
		case .float:
			return "float"
		case .string:
			return "string"
		case .array:
			return "array"
		case .table:
			return "table"
		}
	}
}
