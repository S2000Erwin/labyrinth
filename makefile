STANZAFILES = main.stanza labyrinth.stanza cards.stanza communicator.stanza events.stanza gameBoardGraphics.stanza SDL2.stanza
OBJ = labyrinth

$(OBJ): $(STANZAFILES)
	stanza $(STANZAFILES) -ccfiles libSDL2.dll.a libSDL2_image.dll.a -o $(OBJ)
