//
//  Building.swift
//  
//
//  Created by Paul Straw on 8/27/24.
//

import PlaydateKit

nonisolated(unsafe) let building1BitmapTable = try! Graphics.BitmapTable(path: "building1.png")

nonisolated(unsafe) let building2BitmapTable = try! Graphics.BitmapTable(path: "building2.png")

nonisolated(unsafe) let building3BitmapTable = try! Graphics.BitmapTable(path: "building3.png")

nonisolated(unsafe) let building4BitmapTable = try! Graphics.BitmapTable(path: "building4.png")

nonisolated(unsafe) let building5BitmapTable = try! Graphics.BitmapTable(path: "building5.png")

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
	
	var destroyed = false
	var destructionComplete = false
	
	init(_ config: Config) {
		buildingType = config.buildingType
		
		let bitmapTable: Graphics.BitmapTable
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
	
	func attemptDestroy() {
		if destroyed {
			return
		}
		
		destroyed = true
		destroyAnimation.play()
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
