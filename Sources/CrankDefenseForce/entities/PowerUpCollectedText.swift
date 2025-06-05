import PlaydateKit

class PowerUpCollectedText: BaseEntity {
	static nonisolated(unsafe) let dayBitmaps: [PowerUp.PowerUpType: Graphics.Bitmap] = [
		.pauseEnemies: Graphics.Bitmap(strokedText: "ASSAULT PAUSED", strokeWidth: 1, textColor: .fillWhite, strokeColor: .fillBlack, align: .right, font: CdfFont.NicoPups16)
	]

	static nonisolated(unsafe) let nightBitmaps: [PowerUp.PowerUpType: Graphics.Bitmap] = [
		.pauseEnemies: Graphics.Bitmap(strokedText: "ASSAULT PAUSED", strokeWidth: 1, textColor: .fillBlack, strokeColor: .fillWhite, align: .right, font: CdfFont.NicoPups16)
	]


	let powerUpType: PowerUp.PowerUpType

	let position: Point

	let sprite = Sprite.Sprite()

	struct Config {
		let entityStore: EntityStore
		let powerUpType: PowerUp.PowerUpType
		let position: Point
	}

	@discardableResult init(_ config: Config) {
		position = config.position
		powerUpType = config.powerUpType

		sprite.image = GameSettings.timeOfDay == .day ? Self.dayBitmaps[powerUpType]! : Self.nightBitmaps[powerUpType]!
		sprite.zIndex = 200
		sprite.moveTo(position)
		sprite.addToDisplayList()

		super.init(config.entityStore)
	}
}

