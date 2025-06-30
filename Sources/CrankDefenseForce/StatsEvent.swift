enum StatsEventType {
	case cpuRocketDestroyed
	case cpuFastRocketDestroyed
	case cpuSmallUfoDestroyed
	case cpuBigUfoDestroyed
	case powerUpCollected(PowerUp.PowerUpType)
}

struct StatsEventPayload {
	var eventType: StatsEventType
}

struct StatsEvent: EventProtocol {
	typealias Payload = StatsEventPayload
}

//nonisolated(unsafe) static var statsEmitter = EventEmitter<StatsEvent>()
