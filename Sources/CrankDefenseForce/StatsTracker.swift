class StatsTracker {
	// MARK: Lifecycle
	
	init() {

	}

	// MARK: Internal

	private(set) var rocketsFired = 0

	private(set) var cpuRocketsDestroyed = 0

	private(set) var cpuFastRocketsDestroyed = 0

	private(set) var cpuSmallUfosDestroyed = 0

	private(set) var cpuBigUfosDestroyed = 0

	private(set) var pauseEnemiesPowerUpsCollected = 0

	private(set) var repairBuildingPowerUpsCollected = 0

	private(set) var destroyEnemiesPowerUpsCollected = 0
}
