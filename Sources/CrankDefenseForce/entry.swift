import PlaydateKit

/// Boilerplate entry code
nonisolated(unsafe) var game: Game!
@_cdecl("eventHandler") func eventHandler(
	pointer: UnsafeMutablePointer<PlaydateAPI>!,
	event: System.Event,
	_: CUnsignedInt
) -> CInt {
	switch event {
	case .initialize:
		Playdate.initialize(with: pointer)

		DrumsElectric.register()

		// Prevent lag when first SFX is played
		let _ = Sfx.instance

		GameSettings.initialize()
		game = Game()
		System.updateCallback = game.update
	default: game.handle(event)
	}
	return 0
}
