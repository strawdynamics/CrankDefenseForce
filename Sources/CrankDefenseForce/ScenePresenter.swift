//
//  ScenePresenter.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

class ScenePresenter {
	var currentScene: BaseScene
	
	var nextScene: BaseScene?
	
	var transition: SceneTransition?
	
	var isExiting = false
	
	var isEntering = false
	
	
	init(firstScene: BaseScene) {
		firstScene.enter()
		firstScene.start()
		
		self.currentScene = firstScene
	}
	
	public func update() {
		self.currentScene.update()
	}
}
