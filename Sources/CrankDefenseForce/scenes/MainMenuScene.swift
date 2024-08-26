//
//  MainMenuScene.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class MainMenuScene: BaseScene {
	static func new() -> Self {
		return MainMenuScene() as! Self
	}
	
	override init() {
		//
	}
	
	override func update() {
		Graphics.pushContext(nil)
		Graphics.drawMode = .fillWhite
		Graphics.drawText("CDF SWIFT *salute*", at: Point(x: 50.0, y: 50.0))
		Graphics.drawText("oi buddy \(Time.deltaTime.description)", at: Point(x: 50.0, y: 68.0))
		Graphics.popContext()
	}
	
	override func enter() {
		//
	}
	
	override func start() {
		//
	}
	
	override func exit() {
		//
	}
	
	override func finish() {
		//
	}
}
