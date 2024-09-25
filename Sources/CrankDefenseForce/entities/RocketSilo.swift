//
//  RocketSilo.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

import PlaydateKit

nonisolated(unsafe) let siloBBitmap = try! Graphics.Bitmap(path: "siloB.png")

nonisolated(unsafe) let siloABitmap = try! Graphics.Bitmap(path: "siloA.png")

let SILO_SPAWN_Y: Float = 220.0;
let SILO_B_SPAWN_X: Float = 14.0;
let SILO_A_SPAWN_X: Float = 386.0;

let DEFAULT_THRUST: Float = 42.0;

class RocketSilo: BaseEntity {
	struct LaunchEventPayload {
		var rocket: Rocket
	}
	struct LaunchEvent: EventProtocol {
		typealias Payload = LaunchEventPayload
	}
	nonisolated(unsafe) static var launchEmitter = EventEmitter<LaunchEvent>()
	
	enum SiloType {
		case b
		case a
	}
	
	struct Config {
		let siloType: SiloType
		let entityStore: EntityStore
	}
	
	let sprite = Sprite.Sprite()
	
	let siloType: SiloType
	
	var readyForLaunch = true
	
	var rocket: Rocket?
	
	init(_ config: Config) {
		siloType = config.siloType
		
		super.init(config.entityStore)
		
		switch config.siloType {
		case .b:
			sprite.image = siloBBitmap
			sprite.center = Point(x: 0.0, y: 1.0)
			sprite.moveTo(Point(x: 0.0, y: 240.0))
		case .a:
			sprite.image = siloABitmap
			sprite.center = Point(x: 1.0, y: 1.0)
			sprite.moveTo(Point(x: 400.0, y: 240.0))
		}
		
		sprite.zIndex = 50
		
		sprite.addToDisplayList()
		
		self.spawnInitialRocket()
	}
	
	func attemptLaunch()-> Bool {
		if readyForLaunch {
			launch()
			return true
		} else {
			abortLaunch()
			return false
		}
	}
	
	private func launch() {
		if let rocket = self.rocket {
			readyForLaunch = false
			rocket.sprite.collisionsEnabled = true
			rocket.sprite.zIndex = 30
			rocket.setThrust(newThrust: DEFAULT_THRUST)
			
			Self.launchEmitter.emit(LaunchEventPayload(rocket: rocket))
			
			prepareNextRocket()
		}
	}
	
	private func abortLaunch() {
		// TODO: Anim/sfx
	}
	
	private var spawnX: Float {
		let x: Float
		switch self.siloType {
		case .b:
			x = SILO_B_SPAWN_X
		case .a:
			x = SILO_A_SPAWN_X
		}
		
		return x
	}
	
	private func prepareNextRocket() {
		// TODO: Animate
		spawnRocket(at: Point(x: spawnX, y: SILO_SPAWN_Y - 16.0))
		readyForLaunch = true
	}
	
	private func spawnInitialRocket() {
		spawnRocket(at: Point(x: spawnX, y: SILO_SPAWN_Y - 16.0))
	}
	
	private func spawnRocket(at: Point) {
		self.rocket = Rocket(Rocket.Config(
			position: at,
			angle: 0.0,
			entityStore: self.entityStore
		))
		self.rocket?.sprite.collisionsEnabled = false
	}
}
