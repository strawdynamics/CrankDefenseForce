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
	
	init(_ config: Config) {
		buildingType = config.buildingType
		
		switch buildingType {
		case .one:
			sprite.image = building1BitmapTable[0]
		case .two:
			sprite.image = building2BitmapTable[0]
		case .three:
			sprite.image = building3BitmapTable[0]
		case .four:
			sprite.image = building4BitmapTable[0]
		case .five:
			sprite.image = building5BitmapTable[0]
		}
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
		
		super.init(config.entityStore)
		sprite.buildingId = id
	}
}
