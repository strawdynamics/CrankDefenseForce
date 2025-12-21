enum StatsEventType {
	case cpuRocketDestroyed
	case cpuFastRocketDestroyed
	case cpuSmallUfoDestroyed
	case cpuBigUfoDestroyed
}

struct StatsEventPayload {
	var eventType: StatsEventType
	var count: Int = 1
}

struct StatsEvent: EventProtocol {
	typealias Payload = StatsEventPayload
}

//nonisolated(unsafe) static var statsEmitter = EventEmitter<StatsEvent>()
