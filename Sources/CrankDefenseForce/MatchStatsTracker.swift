class MatchStatsTracker {
	// MARK: Lifecycle

	init() {
		_ = Rocket.statsEmitter.on(handleStats)
		_ = RocketSilo.launchEmitter.on(handleLaunch)
		_ = PowerUp.collectEmitter.on(handlePowerUpCollect)
	}

	// MARK: Internal

	private(set) var rocketsLaunched = 42

	private(set) var cpuRocketsDestroyed = 2

	private(set) var cpuFastRocketsDestroyed = 5

	private(set) var cpuSmallUfosDestroyed = 12

	private(set) var cpuBigUfosDestroyed = 5

	private(set) var pauseEnemiesPowerUpsCollected = 1

	private(set) var repairBuildingPowerUpsCollected = 2

	private(set) var destroyEnemiesPowerUpsCollected = 3

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
