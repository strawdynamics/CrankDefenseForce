//
//  PdkTestScene.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class PdkTestScene: BaseScene {
	let logo = PdkLogo()
	
	static func new() -> Self {
		return PdkTestScene() as! Self
	}
	
	override func update() {
		//
	}
	
	override func enter() {
		self.logo.addToDisplayList()
	}
	
	override func start() {
		//
	}
	
	override func exit() {
		//
	}
	
	override func finish() {
		self.logo.removeFromDisplayList()
	}
}



class PdkLogo: Sprite.Sprite {
	// MARK: Lifecycle
	
	override init() {
		super.init()
		image = try! Graphics.Bitmap(path: "pdklogo.png")
		bounds = .init(x: 0, y: 0, width: 400, height: 240)
	}
	
	// MARK: Internal
	
	override func update() {
		moveBy(dx: 0, dy: sinf(System.elapsedTime * 4))
	}
}
