import PlaydateKit

class ConfigMenu: BaseEntity {
	static let ITEM_HEIGHT: Int = 52

	static let OFFSET_TOP: Float = 60

	struct Config {
		let entityStore: EntityStore
	}

	let menuItems: [ConfigMenuItem]

	var selectedItemIndex = 0

	var yAnimator: Animator<Float>?

	init(_ config: Config) {
		let offsetX: Float = 10

		menuItems = [
			ControlsMenuItem(
				ControlsMenuItem.Config(
					title: "Controls",
					offsetX: offsetX,
					entityStore: config.entityStore
				)),
			EnumMenuItem(
				EnumMenuItem.Config(
					offsetX: offsetX,
					entityStore: config.entityStore,
					getValue: {
						return GameSettings.timeOfDay.title
					},
					prevHandler: {
						GameSettings.timeOfDay = GameSettings.timeOfDay.prev
					},
					nextHandler: {
						GameSettings.timeOfDay = GameSettings.timeOfDay.next
					}
				)),
			VolumeMenuItem(
				VolumeMenuItem.Config(
					title: "Music",
					offsetX: offsetX,
					volumeType: VolumeMenuItem.VolumeType.music,
					entityStore: config.entityStore
				)),
			VolumeMenuItem(
				VolumeMenuItem.Config(
					title: "SFX",
					offsetX: offsetX,
					volumeType: VolumeMenuItem.VolumeType.sfx,
					entityStore: config.entityStore
				)),
			EnumMenuItem(
				EnumMenuItem.Config(
					offsetX: offsetX,
					entityStore: config.entityStore,
					getValue: {
						return GameSettings.debugMode.title
					},
					prevHandler: {
						GameSettings.debugMode = GameSettings.debugMode.prev
					},
					nextHandler: {
						GameSettings.debugMode = GameSettings.debugMode.next
					}
				)),
		]

		super.init(config.entityStore)

		menuItems[selectedItemIndex].focus()
		positionMenuItems()
	}

	override func update() {
		updateYAnimator()
	}

	private func updateYAnimator() {
		if let yAnimator = yAnimator {
			yAnimator.update()

			positionMenuItems()

			if yAnimator.ended {
				self.yAnimator = nil
			}
		}
	}

	func selectNext() {
		let oldIndex = selectedItemIndex
		menuItems[selectedItemIndex].blur()

		selectedItemIndex += 1
		if selectedItemIndex >= menuItems.count {
			selectedItemIndex = 0
		}

		menuItems[selectedItemIndex].focus()

		Sfx.instance.play(.menuNavigate)

		animateY(oldIndex: oldIndex, newIndex: selectedItemIndex)
	}

	func selectPrev() {
		let oldIndex = selectedItemIndex
		menuItems[selectedItemIndex].blur()

		selectedItemIndex -= 1
		if selectedItemIndex < 0 {
			selectedItemIndex = menuItems.count - 1
		}

		menuItems[selectedItemIndex].focus()

		Sfx.instance.play(.menuNavigate, offset: -2)

		animateY(oldIndex: oldIndex, newIndex: selectedItemIndex)
	}

	func animateY(oldIndex: Int, newIndex: Int) {
		self.yAnimator = Animator(
			Animator.Config(
				duration: 0.3,
				startValue: (self.yAnimator == nil) ? Float(oldIndex) : self.yAnimator!.currentValue,
				endValue: Float(newIndex),
				easingFn: EasingFn.basic(Ease.outQuad),
			))
	}

	func positionMenuItems() {
		// FIXME: Jank
		let offsetY: Float =
			(yAnimator == nil ? Float(selectedItemIndex) : yAnimator!.currentValue)
			* Float(ConfigMenu.ITEM_HEIGHT)

		menuItems.enumerated().forEach { (i, menuItem) in
			menuItem.moveTo(y: ConfigMenu.OFFSET_TOP + Float(i * ConfigMenu.ITEM_HEIGHT) - offsetY)
		}
	}
}
