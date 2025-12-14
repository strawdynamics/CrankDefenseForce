class MatchStatsTracker {
	// MARK: Lifecycle

	init() {
		_ = Rocket.statsEmitter.on(handleStats)
		_ = RocketSilo.launchEmitter.on(handleLaunch)
		_ = PowerUp.collectEmitter.on(handlePowerUpCollect)
	}

	// MARK: Internal

	private(set) var rocketsLaunched = 0

	private(set) var cpuRocketsDestroyed = 0

	private(set) var cpuFastRocketsDestroyed = 0

	private(set) var cpuSmallUfosDestroyed = 0

	private(set) var cpuBigUfosDestroyed = 0

	private(set) var pauseEnemiesPowerUpsCollected = 0

	private(set) var repairBuildingPowerUpsCollected = 0

	private(set) var destroyEnemiesPowerUpsCollected = 0

	private(set) var finalUptime: Float = 0

	func stop(finalUptime: Float) {
		stopped = true
		self.finalUptime = finalUptime
	}

	// MARK: Private

	private var stopped = false

	private func handleStats(payload: StatsEventPayload) {
		if stopped {
			return
		}

		switch payload.eventType {
		case .cpuRocketDestroyed:
			cpuRocketsDestroyed += 1
		case .cpuFastRocketDestroyed:
			cpuFastRocketsDestroyed += 1
		case .cpuSmallUfoDestroyed:
			cpuSmallUfosDestroyed += 1
		case .cpuBigUfoDestroyed:
			cpuBigUfosDestroyed += 1
		}
	}

	private func handlePowerUpCollect(payload: PowerUp.CollectEventPayload) {
		switch payload.type {
		case .pauseEnemies:
			pauseEnemiesPowerUpsCollected += 1
		case .repairBuilding:
			repairBuildingPowerUpsCollected += 1
		case .destroyEnemies:
			destroyEnemiesPowerUpsCollected += 1
		case .none:
			break
		}
	}

	private func handleLaunch(payload: RocketSilo.LaunchEventPayload) {
		if stopped {
			return
		}

		rocketsLaunched += 1
	}
}
