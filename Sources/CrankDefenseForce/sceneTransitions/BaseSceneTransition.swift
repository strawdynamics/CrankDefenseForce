//
//  BaseSceneTransition.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

enum SceneTransitionExitResult {
	case Exiting
	case Complete
}

enum SceneTransitionEnterResult {
	case Entering
	case Complete
}

class BaseSceneTransition {
	func begin() {
		
	}
	
	func updateExit() -> SceneTransitionExitResult {
		fatalError("BaseSceneTransition updateExit must be overridden")
	}
	
	func updateEnter() -> SceneTransitionEnterResult {
		fatalError("BaseSceneTransition updateEnter must be overridden")
	}
}

