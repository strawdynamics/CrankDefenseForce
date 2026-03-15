import PlaydateKit

let CellPadding = 6

protocol Cell: AnyObject {
	var height: Int { get }

	var width: Int { get }

	func moveTo(topLeft: Point)

	func show()

	func hide()
}

// Duration, # fired
class KeyValueCell: Cell {
	struct Config {
		let key: String
		let value: String
		let rowCellCount: Int
		var keyFont: Graphics.Font = CdfFont.NicoPups16
		var valueFont: Graphics.Font = CdfFont.NicoClean16
	}

	let sprite = Sprite.Sprite()

	let rowCellCount: Int

	init(_ config: Config) {
		rowCellCount = config.rowCellCount
		
		let bitmap = Graphics.Bitmap(
			width: Display.width / config.rowCellCount,
			height: config.keyFont.height + config.valueFont.height + CellPadding * 3,
		)

		Graphics.pushContext(bitmap)
		Graphics.drawMode = .fillWhite
		Graphics.setFont(config.keyFont)
		Graphics.drawText(
			config.key,
			at: Point(
				x: CellPadding,
				y: CellPadding,
			))

		Graphics.setFont(config.valueFont)
		Graphics.drawText(
			config.value,
			at: Point(
				x: CellPadding,
				y: config.keyFont.height + CellPadding * 2,
			))
		Graphics.popContext()

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	var height: Int {
		return Int(sprite.bounds.height)
	}

	var width: Int {
		return Display.width / rowCellCount
	}

	func moveTo(topLeft: Point) {
		sprite.moveTo(topLeft)
	}

	func show() {
		sprite.addToDisplayList()
	}

	func hide() {
		sprite.removeFromDisplayList()
	}
}

// Horizontal rule
class HrCell: Cell {
	init() {
		let bitmap = Graphics.Bitmap(
			// Assume only cell in row
			width: Display.width - CellPadding * 2,
			height: 1,
			bgColor: .white,
		)

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	let sprite = Sprite.Sprite()

	var height: Int {
		return 1
	}

	var width: Int {
		return Display.width
	}

	func moveTo(topLeft: Point) {
		sprite.moveTo(
			topLeft
				+ Point(
					x: CellPadding,
					y: 0,
				))
	}

	func show() {
		sprite.addToDisplayList()
	}

	func hide() {
		sprite.removeFromDisplayList()
	}
}

class SpacerCell: Cell {
	struct Config {
		let height: Int
	}

	init(_ config: Config) {
		height = config.height
		let bitmap = Graphics.Bitmap(
			// Assume only cell in row
			width: Display.width - CellPadding * 2,
			height: height,
			bgColor: .clear,
		)

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	let sprite = Sprite.Sprite()

	var height: Int

	var width: Int {
		return Display.width
	}

	func moveTo(topLeft: Point) {
		sprite.moveTo(
			topLeft
				+ Point(
					x: CellPadding,
					y: 0,
				))
	}

	func show() {
		sprite.addToDisplayList()
	}

	func hide() {
		sprite.removeFromDisplayList()
	}
}

//// Headers (# enemies, power-ups)
class TextCell: Cell {
	struct Config {
		let text: String
		var alignment: Graphics.TextAlignment = .left
		var font: Graphics.Font = CdfFont.NicoPups16
	}

	let sprite = Sprite.Sprite()

	let text: String

	let font: Graphics.Font

	init(_ config: Config) {
		let width = Display.width - CellPadding * 2
		font = config.font
		text = config.text

		let bitmap = Graphics.Bitmap(
			// Assume only cell in row
			width: width,
			height: height,
		)

		Graphics.pushContext(bitmap)
		Graphics.drawMode = .fillWhite
		Graphics.setFont(font)
		Graphics.drawTextInRect(
			text, in: Rect(origin: Point.zero, width: Float(width), height: Float(height)),
			wrap: .word,
			aligned: config.alignment)
		Graphics.popContext()

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	var height: Int {
		let textHeight = font.getTextHeightForMaxWidth(
			for: text,
			maxWidth: width,
			wrap: .word,
			tracking: 0,
			extraLeading: 0
		)

		return textHeight + CellPadding * 2
	}

	var width: Int {
		return Display.width
	}

	func moveTo(topLeft: Point) {
		sprite.moveTo(
			topLeft
				+ Point(
					x: CellPadding,
					y: CellPadding,
				))
	}

	func show() {
		sprite.addToDisplayList()
	}

	func hide() {
		sprite.removeFromDisplayList()
	}
}

class ScoreEntryCell: Cell {
	struct Config {
		let entry: RemoteScoresDisplay.ScoreEntry
	}

	let sprite = Sprite.Sprite()

	init(_ config: Config) {
		let entry = config.entry
		let font = CdfFont.NicoPups16
		let timeFont = CdfFont.NicoClean16

		let cellHeight = font.height + CellPadding * 2
		let cellWidth = Display.width

		let rankText = "#\(entry.rank)"
		let playerText = entry.player
		let m = entry.value / 60
		let s = entry.value % 60
		let timeText = "\(m):\(s < 10 ? "0\(s)" : "\(s)")"

		let timeWidth = timeFont.getTextWidth(for: timeText, tracking: 0)
		let rankWidth = font.getTextWidth(for: rankText, tracking: 0)

		let bitmap = Graphics.Bitmap(width: cellWidth, height: cellHeight)
		Graphics.pushContext(bitmap)
		Graphics.drawMode = .fillWhite

		Graphics.setFont(font)
		Graphics.drawText(rankText, at: Point(x: CellPadding, y: CellPadding / 2))

		let lineX = CellPadding + rankWidth + CellPadding * 2
		Graphics.drawLine(Line(
			start: Point(x: lineX, y: CellPadding / 2),
			end: Point(x: lineX, y: cellHeight - (CellPadding + CellPadding / 2)),
		), lineWidth: 1, color: Graphics.Color.white)

		Graphics.drawText(playerText, at: Point(x: lineX + CellPadding * 2, y: CellPadding / 2))

		Graphics.setFont(timeFont)
		Graphics.drawText(timeText, at: Point(x: cellWidth - timeWidth - CellPadding, y: CellPadding))

		Graphics.popContext()

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	var height: Int { CdfFont.NicoClean16.height + CellPadding * 2 }
	var width: Int { Display.width }

	func moveTo(topLeft: Point) { sprite.moveTo(topLeft) }
	func show() { sprite.addToDisplayList() }
	func hide() { sprite.removeFromDisplayList() }
}

class ImageCell: Cell {
	struct Config {
		let path: String
		var paddingLeft: Int = 0
	}

	private let sprite = Sprite.Sprite()

	private let paddingLeft: Int

	init(_ config: Config) {
		let bitmap = try! Graphics.Bitmap(path: config.path)
		let (bitmapWidth, bitmapHeight, _) = bitmap.getData(mask: nil, data: nil)
		width = bitmapWidth
		height = bitmapHeight

		paddingLeft = config.paddingLeft

		sprite.image = bitmap
		sprite.center = Point.zero
		sprite.zIndex = 600
		sprite.addToDisplayList()
	}

	var height: Int = 0

	var width: Int = 0

	func moveTo(topLeft: Point) {
		sprite.moveTo(
			topLeft
				+ Point(
					x: CellPadding + paddingLeft,
					y: CellPadding,
				))
	}

	func show() {
		sprite.addToDisplayList()
	}

	func hide() {
		sprite.removeFromDisplayList()
	}
}

//
//// Everything else
class EntityCell: Cell {
	enum EntityType {
		case rocket
		case fastRocket
		case smallUfo
		case bigUfo
		case pauseEnemies
		case repairBuilding
		case destroyEnemies
	}

	struct Config {
		let text: String
		let secondaryText: String?
		let entityType: EntityType
		let entityStore: EntityStore
	}

	let textSprite = Sprite.Sprite()
	let secondaryTextSprite = Sprite.Sprite()

	let entityType: EntityType

	let entity: Movable & Toggleable

	init(_ config: Config) {
		entityType = config.entityType
		entity = Self.spawnEntity(config)

		let bitmap = Graphics.Bitmap(
			width: CdfFont.NicoClean16.getTextWidth(for: config.text, tracking: 0),
			height: CdfFont.NicoClean16.height,
		)

		Graphics.pushContext(bitmap)
		Graphics.drawMode = .fillWhite
		Graphics.setFont(CdfFont.NicoClean16)
		Graphics.drawText(config.text, at: Point.zero)
		Graphics.popContext()

		textSprite.image = bitmap
		textSprite.center = Point.zero
		textSprite.zIndex = 600
		textSprite.addToDisplayList()

		if let secondaryText = config.secondaryText {
			let secondaryBitmap = Graphics.Bitmap(
				width: CdfFont.NicoPups16.getTextWidth(for: secondaryText, tracking: 0),
				height: CdfFont.NicoPups16.height,
			)
			Graphics.pushContext(secondaryBitmap)
			Graphics.drawMode = .fillWhite
			Graphics.setFont(CdfFont.NicoPups16)
			Graphics.drawText(secondaryText, at: Point.zero)
			Graphics.popContext()

			secondaryTextSprite.image = secondaryBitmap
			secondaryTextSprite.center = Point.zero
			secondaryTextSprite.zIndex = 600
			secondaryTextSprite.addToDisplayList()
		}
	}

	var height: Int {
		return CdfFont.NicoClean16.height + CellPadding * 2
	}

	var width: Int {
		let secondaryWidth = secondaryTextSprite.bounds.width > 0
			? Int(secondaryTextSprite.bounds.width) + CellPadding
			: 0
		return entityWidth + textWidth + CellPadding * 4 + secondaryWidth
	}

	private var entityWidth: Int {
		switch entityType {
		case .rocket, .fastRocket:
			return 24
		case .smallUfo:
			return 30
		case .bigUfo:
			return 74
		case .pauseEnemies, .repairBuilding, .destroyEnemies:
			return 26
		}
	}

	private var textWidth: Int {
		return Int(textSprite.bounds.width)
	}

	func moveTo(topLeft: Point) {
		textSprite.moveTo(
			topLeft
				+ Point(
					x: entityWidth + CellPadding,
					y: (height - Int(textSprite.bounds.height)) / 2,
				))

		secondaryTextSprite.moveTo(
			topLeft
				+ Point(
					x: entityWidth + CellPadding + textWidth + CellPadding,
					y: (height - Int(secondaryTextSprite.bounds.height)) / 2,
				))

		moveEntity(topLeft: topLeft)
	}

	private func moveEntity(topLeft: Point) {
		switch entityType {
		case .rocket, .fastRocket:
			entity.moveTo(
				position: topLeft
					+ Point(
						x: 14,
						y: 9,
					))
		case .smallUfo:
			entity.moveTo(
				position: topLeft
					+ Point(
						x: 16,
						y: 12,
					))
		case .bigUfo:
			entity.moveTo(
				position: topLeft
					+ Point(
						x: 38,
						y: 10,
					))
		case .pauseEnemies, .repairBuilding, .destroyEnemies:
			entity.moveTo(
				position: topLeft
					+ Point(
						x: 14,
						y: 12,
					))
		}
	}

	static func spawnEntity(_ config: Config) -> Movable & Toggleable {
		switch config.entityType {
		case .rocket, .fastRocket:
			let rocket = Rocket(
				Rocket.Config(
					position: Point.zero,
					angle: 30,
					entityStore: config.entityStore,
					owner: .cpu,
					exhaustType: config.entityType == .fastRocket ? .big : .normal,
					alwaysExhaust: true,
				))

			rocket.sprite.zIndex = 700
			rocket.exhaust?.sprite.zIndex = 700

			return rocket
		case .smallUfo:
			let ufo = SmallUfo(
				SmallUfo.Config(
					entityStore: config.entityStore,
					position: Point.zero,
					facingLeft: true,
					speed: 0,
					exhaustZIndex: 650,
					silent: true,
				))

			ufo.sprite.zIndex = 700

			return ufo
		case .bigUfo:
			let ufoEyes = BigUfoEyes(
				BigUfoEyes.Config(
					entityStore: config.entityStore,
				))

			ufoEyes.sprite.zIndex = 700

			return ufoEyes
		case .pauseEnemies, .repairBuilding, .destroyEnemies:
			let type: PowerUp.PowerUpType =
				switch config.entityType {
				case .pauseEnemies:
					.pauseEnemies
				case .repairBuilding:
					.repairBuilding
				case .destroyEnemies:
					.destroyEnemies
				default:
					.none
				}

			let powerUp = PowerUp(
				PowerUp.Config(
					position: Point.zero,
					type: type,
					entityStore: config.entityStore,
				))

			powerUp.sprite.zIndex = 700

			return powerUp
//		default:
//			let rocket = Rocket(
//				Rocket.Config(
//					position: Point.zero,
//					angle: 30,
//					entityStore: config.entityStore,
//					owner: .cpu,
//					alwaysExhaust: true,
//				))
//
//			rocket.sprite.zIndex = 700
//			rocket.exhaust?.sprite.zIndex = 700
//
//			return rocket
		}
	}

	func show() {
		textSprite.addToDisplayList()
		if secondaryTextSprite.image != nil { secondaryTextSprite.addToDisplayList() }
		entity.show()
	}

	func hide() {
		textSprite.removeFromDisplayList()
		secondaryTextSprite.removeFromDisplayList()
		entity.hide()
	}
}
