import PlaydateKit

/// Boilerplate entry code
nonisolated(unsafe) var game: Game!
//nonisolated(unsafe) var testGame: TestGame!
@_cdecl("eventHandler") func eventHandler(
	pointer: UnsafeMutableRawPointer!,
	event: System.Event,
	_: CUnsignedInt
) -> CInt {
	switch event {
	case .initialize:
		Playdate.initialize(with: pointer)
		
		GameSettings.initialize()
		game = Game()
		System.updateCallback = game.update
		
//		testGame = TestGame()
//		System.updateCallback = testGame.update
	default: game.handle(event)
	}
	return 0
}
