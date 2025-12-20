import PlaydateKit

enum EnemyType {
	case rocket
	case fastRocket
	case bigUfo
	case smallUfo
	case none
}

class EnemyCoordinator: BaseEntity {
	struct DifficultyLevel {
		let duration: Float
		let baseSpawnInterval: Float
		let spawnWeights: [EnemyType: Float]
	}

	enum SpawnError: Error {
		case enemyPickFailure
	}

	private static let difficultyLevels: [DifficultyLevel] = [
//		DifficultyLevel(
//			//			baseSpawnInterval: 15.0, // slow for testing
//			//			baseSpawnInterval: 5.0, // previous easiest
//			baseSpawnInterval: 1.25,  // previous hardest
//			//			baseSpawnInterval: 0.5, // too many!
//			//			baseSpawnInterval: 4, // Test with Charlene 2025/06/06
//			spawnWeights: [
//				.rocket: 75
//					//				.fastRocket: 5,
//					//				.bigUfo: 10,
//					//				.smallUfo: 10,
//			]
//		)

		DifficultyLevel(
			duration: 15,
			baseSpawnInterval: 5,
			spawnWeights: [
				.rocket: 100
			]
		),

		DifficultyLevel(
			duration: 20,
			baseSpawnInterval: 4.5,
			spawnWeights: [
				.rocket: 97,
				.fastRocket: 2,
				.smallUfo: 1,
			]
		),

		DifficultyLevel(
			duration: 25,
			baseSpawnInterval: 3.8,
			spawnWeights: [
				.rocket: 94,
				.fastRocket: 5,
				.smallUfo: 2,
			]
		),

		// 60s

		DifficultyLevel(
			duration: 10,
			baseSpawnInterval: 100,
			spawnWeights: [
				.bigUfo: 100
			]
		),

		DifficultyLevel(
			duration: 20,
			baseSpawnInterval: 3,
			spawnWeights: [
				.rocket: 82,
				.fastRocket: 15,
				.smallUfo: 3,
			]
		),

		DifficultyLevel(
			duration: 25,
			baseSpawnInterval: 2.5,
			spawnWeights: [
				.rocket: 82,
				.fastRocket: 15,
				.smallUfo: 3,
			]
		),

		DifficultyLevel(
			duration: 3,
			baseSpawnInterval: 100,
			spawnWeights: [
				.bigUfo: 100
			]
		),

		DifficultyLevel(
			duration: 1,
			baseSpawnInterval: 100,
			spawnWeights: [
				.fastRocket: 100
			]
		),

		DifficultyLevel(
			duration: 1,
			baseSpawnInterval: 100,
			spawnWeights: [
				.fastRocket: 100
			]
		),

		// 120s

		DifficultyLevel(
			duration: 5,
			baseSpawnInterval: 100,
			spawnWeights: [
				.smallUfo: 1
			]
		),

		DifficultyLevel(
			duration: 25,
			baseSpawnInterval: 2,
			spawnWeights: [
				.rocket: 77,
				.fastRocket: 20,
				.smallUfo: 3,
			]
		),

		DifficultyLevel(
			duration: 30,
			baseSpawnInterval: 1.5,
			spawnWeights: [
				.rocket: 80,
				.fastRocket: 15,
				.smallUfo: 5,
			]
		),

		// 180s

		DifficultyLevel(
			duration: 0,
			baseSpawnInterval: 1.25,
			spawnWeights: [
				.rocket: 77,
				.fastRocket: 15,
				.smallUfo: 3,
				.bigUfo: 5,
			]
		),
	]

	let city: City

	private var uptime: Float = 0

	private var currentDifficulty: DifficultyLevel
	private var currentDifficultyIndex = 0
	private var nextDifficultyTime: Float = 0

	private var started = false

	private var nextSpawnTime: Float = 0

	private var rockets: [Rocket] = []

	private var bigUfo: BigUfo?

	private var smallUfos: [SmallUfo] = []

	private var pausedUntil: Float? = nil

	struct Config {
		let entityStore: EntityStore
		let city: City
	}

	init(_ config: Config) {
		city = config.city
		currentDifficulty = Self.difficultyLevels[currentDifficultyIndex]
		nextDifficultyTime = currentDifficulty.duration

		super.init(config.entityStore)

		_ = Rocket.removeEmitter.on(handleRocketRemove)
		_ = SmallUfo.removeEmitter.on(handleSmallUfoRemove)
	}

	func start() {
		started = true

		spawnAndSchedule()
	}

	func pause(for pauseDuration: Float) {
		pausedUntil = uptime + pauseDuration
	}

	/// Player owns all explosions here, because this is triggered by a PowerUp
	func destroyAll() {
		for rocket in rockets {
			rocket.explode(explosionOwner: .player)
		}

		for smallUfo in smallUfos {
			smallUfo.explode()
		}

		if let bigUfo {
			bigUfo.explode()
		}
	}

	override func update() {
		if !started {
			return
		}

		if let bigUfo = bigUfo {
			if bigUfo.destroyed {
				self.bigUfo = nil
			}
		}

		uptime += Time.deltaTime

		if let pausedUntil {
			if uptime >= pausedUntil {
				self.pausedUntil = nil
			}
		} else {
			if nextDifficultyTime > 0 && uptime >= nextDifficultyTime {
				advanceDifficulty()
				spawnAndSchedule()
			} else if uptime >= nextSpawnTime {
				spawnAndSchedule()
			}
		}
	}

	private func handleRocketRemove(payload: Rocket.RemoveEventPayload) {
		rockets.removeAll { rocket in
			let shouldRemove = rocket.id == payload.rocket.id

			return shouldRemove
		}
	}

	private func handleSmallUfoRemove(payload: SmallUfo.RemoveEventPayload) {
		smallUfos.removeAll { smallUfo in
			let shouldRemove = smallUfo.id == payload.smallUfo.id

			return shouldRemove
		}
	}

	private func spawnAndSchedule() {
		spawnEnemy()

		let spawnDelay = currentDifficulty.baseSpawnInterval * Float.random(in: 0.8..<1.2)
		nextSpawnTime = uptime + spawnDelay
	}

	private func pickEnemy() -> EnemyType {
		let weights = currentDifficulty.spawnWeights
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
		case .bigUfo:
			spawnBigUfo()
		case .smallUfo:
			spawnSmallUfo()
		case .none:
			break
		}
	}

	private func spawnRocket() {
		let pos = Point(x: Float.random(in: -40...440), y: -20)

		guard
			let targetBuilding = city.buildings.filter({
				return !$0.destroyed
			}).randomElement()
		else {
			return
		}
		let buildingPos = targetBuilding.sprite.position

		let down = Vector2(x: 0, y: -1)
		let vecToTarget = Vector2(x: buildingPos.x - pos.x, y: buildingPos.y - pos.y).normalized()
		let angleToTarget = down.angle(with: vecToTarget).toDegrees()

		let rocket = Rocket(
			Rocket.Config(
				position: pos,
				angle: angleToTarget,
				thrust: 10,
				entityStore: entityStore,
				owner: .cpu
			))

		rockets.append(rocket)
	}

	private func spawnFastRocket() {
		guard
			let targetBuilding = city.buildings.filter({
				return !$0.destroyed
			}).randomElement()
		else {
			return
		}

		let pos = Point(x: Float.random(in: 20...380), y: -100)

		let buildingPos = targetBuilding.sprite.position

		let down = Vector2(x: 0, y: -1)
		let vecToTarget = Vector2(x: buildingPos.x - pos.x, y: buildingPos.y - pos.y).normalized()
		let angleToTarget = down.angle(with: vecToTarget)
		let degAngleToTarget = angleToTarget.toDegrees()

		let adjacent: Float = -pos.y + 15
		let warningDist: Float = adjacent / fabsf(cosf(angleToTarget))  // hypotenuse
		let warningPos = Point(
			x: pos.x + (warningDist * cosf(angleToTarget - Float.pi * 0.5)),
			//			y: pos.y + (warningDist * sinf(angleToTarget - Float.pi * 0.5)),
			// FIXME: Workaround for some inputs giving different y outputs.
			y: pos.y + adjacent,
		)

		let _ = Warning(
			Warning.Config(
				position: warningPos,
				entityStore: entityStore,
				duration: 2.4,
				inPercentage: 0.3,
				outPercentage: 0.3
			))

		let rocket = Rocket(
			Rocket.Config(
				position: pos,
				angle: degAngleToTarget,
				thrust: 36,
				entityStore: entityStore,
				owner: .cpu,
				exhaustType: .big
			))

		rockets.append(rocket)
	}

	private func spawnBigUfo() {
		if bigUfo != nil {
			return
		}

		let left = Float.random(in: 0..<1) < 0.5
		let pos = Point(
			x: Float(left ? -90 : Display.width + 90),
			y: Float.random(in: 50..<60)
		)

		bigUfo = BigUfo(
			BigUfo.Config(
				city: city,
				entityStore: entityStore,
				position: pos,
				hitPoints: 3
			))
	}

	private func spawnSmallUfo() {
		let facingLeft = Float.random(in: 0..<1) < 0.5
		let pos = Point(
			x: Float(!facingLeft ? -30 : Display.width + 30),
			y: Float.random(in: 30..<150)
		)

		let smallUfo = SmallUfo(
			SmallUfo.Config(
				entityStore: entityStore,
				position: pos,
				facingLeft: facingLeft,
				speed: 20,
			))
		smallUfos.append(smallUfo)
	}

	private func advanceDifficulty() {
		currentDifficultyIndex += 1
		currentDifficulty = Self.difficultyLevels[currentDifficultyIndex]

		nextDifficultyTime = currentDifficulty.duration == 0 ? 0 : uptime + currentDifficulty.duration
	}
}
