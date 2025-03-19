import PlaydateKit

enum EnemyType {
	case rocket
	case fastRocket
	case none
}

class EnemyCoordinator: BaseEntity {
	struct DifficultyLevel {
		let baseSpawnInterval: Float
		let spawnWeights: [EnemyType: Float]
	}
	
	enum SpawnError: Error {
		case enemyPickFailure
	}
	
	private static let difficultyLevels: [DifficultyLevel] = [
		DifficultyLevel(
			baseSpawnInterval: 5.0,
			spawnWeights: [
				.rocket: 100,
			]
		),
	]
	
	let city: City
	
	private var uptime: Float = 0
	
	private var difficulty: DifficultyLevel
	
	private var started = false
	
	private var nextSpawnTime: Float = 0
	
	struct Config {
		let entityStore: EntityStore
		let city: City
	}
	
	init(_ config: Config) {
		city = config.city
		difficulty = Self.difficultyLevels[0]
		
		super.init(config.entityStore)
	}
	
	func start() {
		started = true
		
		spawnAndSchedule()
	}
	
	override func update() {
		if !started {
			return
		}
		
		uptime += Time.deltaTime
		
		if uptime >= nextSpawnTime {
			spawnAndSchedule()
		}
	}
	
	private func spawnAndSchedule() {
		spawnEnemy()
		
		let spawnDelay = difficulty.baseSpawnInterval * Float.random(in: 0.8..<1.2)
		nextSpawnTime = uptime + spawnDelay
	}
	
	private func pickEnemy() -> EnemyType {
		let weights = difficulty.spawnWeights
		let total = weights.values.reduce(0, +)
		let selectedWeight = Float.random(in: 0..<total)
		var accumulatedWeight: Float = 0
		
		for (enemyType, weight) in weights {
			accumulatedWeight += weight
			if selectedWeight < accumulatedWeight {
				return enemyType
			}
		}
		
		return .none
	}
	
	private func spawnEnemy() {
		let enemyType = pickEnemy()
		
		switch enemyType {
		case .rocket:
			spawnRocket()
		case .fastRocket:
			spawnFastRocket()
		case .none:
			break
		}
	}
	
	private func spawnRocket() {
		let pos = Point(x: Float.random(in: -40...440), y: -20)
		
		guard let targetBuilding = city.buildings.filter({
			return !$0.destroyed
		}).randomElement() else {
			return
		}
		let buildingPos = targetBuilding.sprite.position
				
		let down = Vector2D(x: 0, y: -1)
		let vecToTarget = Vector2D(x: buildingPos.x - pos.x, y: buildingPos.y - pos.y).normalized()
		let angleToTarget = down.angle(with: vecToTarget).toDegrees()
				
		let _ = Rocket(Rocket.Config(
			position: pos,
			angle: angleToTarget,
			thrust: 10,
			entityStore: entityStore,
			owner: .cpu
		))
	}
	
	private func spawnFastRocket() {
		// warning first
		// 30 thrust?
	}
}

