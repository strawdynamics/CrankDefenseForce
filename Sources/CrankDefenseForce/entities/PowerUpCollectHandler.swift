import PlaydateKit

class PowerUpCollectHandler: BaseEntity {
	let city: City
	
	let enemyCoordinator: EnemyCoordinator
	
	struct Config {
		let entityStore: EntityStore
		let city: City
		let enemyCoordinator: EnemyCoordinator
	}
	
	init(_ config: Config) {
		enemyCoordinator = config.enemyCoordinator
		city = config.city
		
		super.init(config.entityStore)
		
		let _ = PowerUp.collectEmitter.on(handlePowerUpCollect)
	}
	
	func handlePowerUpCollect(_ e: PowerUp.CollectEvent.Payload) {
		PowerUpCollectedText(PowerUpCollectedText.Config(
			entityStore: entityStore,
			powerUpType: e.type,
			position: e.position
		))

		switch e.type {
		case .pauseEnemies:
			handleCollectedPauseEnemies(e)
		case .repairBuilding:
			handleCollectedRepairBuilding(e)
		case .destroyEnemies:
			handleCollectedDestroyEnemies(e)
		default:
			break
		}
	}

	private func handleCollectedPauseEnemies(_ e: PowerUp.CollectEvent.Payload) {
		enemyCoordinator.pause(for: 10)
	}

	private func handleCollectedRepairBuilding(_ e: PowerUp.CollectEvent.Payload) {
		city.repairBuilding()
	}

	private func handleCollectedDestroyEnemies(_ e: PowerUp.CollectEvent.Payload) {
		enemyCoordinator.destroyAll()
	}
}
