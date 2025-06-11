import PlaydateKit

nonisolated(unsafe) let building1BitmapTable = try! Graphics.BitmapTable(path: "entities/Building/building1")

nonisolated(unsafe) let building2BitmapTable = try! Graphics.BitmapTable(path: "entities/Building/building2")

nonisolated(unsafe) let building3BitmapTable = try! Graphics.BitmapTable(path: "entities/Building/building3")

nonisolated(unsafe) let building4BitmapTable = try! Graphics.BitmapTable(path: "entities/Building/building4")

nonisolated(unsafe) let building5BitmapTable = try! Graphics.BitmapTable(path: "entities/Building/building5")

class Building: BaseEntity {
	enum BuildingType {
		case one
		case two
		case three
		case four
		case five
	}
	
	struct Config {
		let buildingType: BuildingType
		let entityStore: EntityStore
		let position: Point
	}
	
	class BuildingSprite: Sprite.Sprite {
		var buildingId: Int = -1
	}
	
	let buildingType: BuildingType
	
	let sprite = BuildingSprite()
	
	let destroyAnimation: SpriteAnimation
	
	private(set) var destroyed = false
	private var destructionComplete = false

	let bitmapTable: Graphics.BitmapTable

	var position: Point {
		return sprite.position
	}
	
	init(_ config: Config) {
		buildingType = config.buildingType

		switch buildingType {
		case .one:
			bitmapTable = building1BitmapTable
		case .two:
			bitmapTable = building2BitmapTable
		case .three:
			bitmapTable = building3BitmapTable
		case .four:
			bitmapTable = building4BitmapTable
		case .five:
			bitmapTable = building5BitmapTable
		}
		
		sprite.image = bitmapTable[0]
		sprite.center = Point(x: 0.5, y: 1.0)
		sprite.moveTo(config.position)
		sprite.zIndex = 50
		
		let (bitmapWidth, bitmapHeight, _) = sprite.image!.getData(mask: nil, data: nil)
		sprite.collideRect = Rect.init(
			x: 0,
			y: 0,
			width: bitmapWidth,
			height: bitmapHeight,
		)
		sprite.addToDisplayList()
		
		let destroyAnimIndices: Array<Int>
		switch buildingType {
		case .one:
			destroyAnimIndices = Array(1...11)
		case .two:
			destroyAnimIndices = Array(1...18)
		case .three:
			destroyAnimIndices = Array(1...18)
		case .four:
			destroyAnimIndices = Array(1...17)
		case .five:
			destroyAnimIndices = Array(1...23)
		}
		destroyAnimation = SpriteAnimation(SpriteAnimation.Config(
			sprite: sprite,
			bitmapTable: bitmapTable,
			bitmapTableIndices: destroyAnimIndices,
			frameDuration: 0.1,
			loopType: .stop,
		))
		
		super.init(config.entityStore)
		sprite.buildingId = id
	}
	
	func attemptDestroy() -> Bool {
		if destroyed {
			return false
		}
		
		destroyed = true
		destroyAnimation.play()
		
		return true
	}

	func repair() {
		if !destroyed {
			return
		}

		destroyed = false
		destructionComplete = false
		destroyAnimation.stop()

		sprite.collisionsEnabled = true
		sprite.image = bitmapTable[0]
	}

	override func update() {
		if destroyed && !destructionComplete {
			destroyAnimation.update()
			
			if destroyAnimation.isComplete {
				destructionComplete = true
				sprite.collisionsEnabled = false
			}
		}
	}
}
