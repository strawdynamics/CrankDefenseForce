//
//  SceneTransition.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

enum SceneTransitionUpdateResult {
	
}

protocol SceneTransition {
	func begin()
	
	func updateExit() -> SceneTransitionUpdateResult
	
	func updateEnter() -> SceneTransitionUpdateResult
}
