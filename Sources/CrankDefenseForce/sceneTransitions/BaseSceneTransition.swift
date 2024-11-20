enum SceneTransitionExitResult {
	case exiting
	case complete
}

enum SceneTransitionEnterResult {
	case entering
	case complete
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

