//
//  ScenePresenter.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

class ScenePresenter {
	var currentScene: BaseScene
	
	var nextScene: BaseScene?
	
	var transition: BaseSceneTransition?
	
	var isExiting = false
	
	var isEntering = false
	
	
	init(firstScene: BaseScene) {
		firstScene.enter()
		firstScene.start()
		
		self.currentScene = firstScene
	}
	
	public func update() {
		self.currentScene.update()
		
		if self.isExiting {
			self.updateExit()
		} else if self.isEntering {
			self.updateEnter()
		}
	}
	
	public func changeScene(newScene: BaseScene, transition: BaseSceneTransition) {
		self.nextScene = newScene
		
		self.currentScene.exit()
		
		transition.begin()
		self.transition = transition
		
		self.isExiting = true
	}
	
	func updateExit() {
		guard let transition = self.transition else {
			return
		}
		
		let res = transition.updateExit()
		
		if res == .complete {
			self.completeExit()
		}
	}
	
	func completeExit() {
		self.isExiting = false
		self.isEntering = true
		
		self.currentScene.finish()
		
		
		self.currentScene = self.nextScene!
		self.nextScene = nil
		self.currentScene.enter()
	}
	
	func updateEnter() {
		guard let transition = self.transition else {
			return
		}
		
		let res = transition.updateEnter()
		
		if res == .complete {
			self.completeEnter()
		}
	}
	
	func completeEnter() {
		self.isEntering = false
		self.currentScene.start()
		self.transition = nil
	}
}
