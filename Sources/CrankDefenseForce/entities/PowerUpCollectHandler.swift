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
	}
}
