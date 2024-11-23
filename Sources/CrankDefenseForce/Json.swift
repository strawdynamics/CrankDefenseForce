enum JsonValueType: Int8 {
	case null = 0 // kJSONNull
	case trueValue = 1 // kJSONTrue
	case falseValue = 2 // kJSONFalse
	case integer = 3 // kJSONInteger
	case float = 4 // kJSONFloat
	case string = 5 // kJSONString
	case array = 6 // kJSONArray
	case table = 7 // kJSONTable
}
