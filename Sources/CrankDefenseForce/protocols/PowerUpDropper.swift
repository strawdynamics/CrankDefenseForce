import PlaydateKit

protocol PowerUpDropper: AnyObject {
	static var powerUpDropTable: [PowerUp.PowerUpType: Float] { get }
}

extension PowerUpDropper {
	func dropPowerUp() {
		let type = pickPowerUp()
		
		switch type {
		case .none:
			break
		case .pauseEnemies:
			break
		}
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
