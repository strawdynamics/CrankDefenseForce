import PlaydateKit

protocol PowerUpDropper: BaseEntity {
	static var powerUpDropTable: [PowerUp.PowerUpType: Float] { get }

	var position: Point { get }
}

extension PowerUpDropper {
	func dropPowerUp() {
		let type = pickPowerUp()

		if type == .none {
			return
		}

		_ = PowerUp(
			PowerUp.Config(
				position: position,
				type: type,
				entityStore: entityStore
			))
	}

	private func pickPowerUp() -> PowerUp.PowerUpType {
		let weights = Self.powerUpDropTable
		let total = weights.values.reduce(0, +)
		let selectedWeight = Float.random(in: 0..<total)
		var accumulatedWeight: Float = 0
		var selectedType: PowerUp.PowerUpType = .none

		for (powerUpType, weight) in weights {
			accumulatedWeight += weight
			if selectedWeight < accumulatedWeight {
				selectedType = powerUpType
				break
			}
		}

		return selectedType
	}
}
