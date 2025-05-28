import PlaydateKit

extension SoundWaveform: @retroactive CustomStringConvertible {
	public var description: String {
		switch self {
		case .square:
			return "square"
		case .triangle:
			return "triangle"
		case .sine:
			return "sine"
		case .noise:
			return "noise"
		case .sawtooth:
			return "sawtooth"
		case .poPhase:
			return "poPhase"
		case .poDigital:
			return "poDigital"
		case .povOsim:
			return "poVosim"
		default:
			return "unknown"
		}
	}
}
