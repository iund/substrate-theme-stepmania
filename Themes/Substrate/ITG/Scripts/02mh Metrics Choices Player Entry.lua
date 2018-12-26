-- Player Entry Screen , PlayerEntryChoices[NumPlayersEnabled()]

		--Master list. Remove solo which is a 6panel layout (why does it share gametype with 4panel anyway??)
	PlayerEntryChoices = {
		dance  = {{{Style="single",Sides=1},{Style="double",Sides=2}},{{Style="versus",Sides=2},{Style="versus",Sides=2}}}, --use a gametype that'll always be invalid as a placeholder
		--dance  = {{{Style="single"},{Style="double"},{Style="solo"}},{{Style="versus"},{Style="couple"},{Style="couple-edit"}}}, --solo-versus is commented out in GameManager
		pump   = {{
						{Style="single",Sides=1},{Style="halfdouble",Sides=2},{Style="double",Sides=2}
					},{
						{Style="versus",Sides=2},{Style="couple",Sides=2},{Style="couple-edit",Sides=2}
					}},
		ez2    = {{
						{Style="single",Sides=1},{Style="double",Sides=2},{Style="real",Sides=1}
					},{
						{Style="versus",Sides=2},{Style="versusReal",Sides=2}
					}},
		para   = {{{Style="single",Sides=1}},{{Style="versus"}}},
		ds3ddx = {{{Style="single",Sides=1}}}, --no versus
		bm     = {{{Style="single5",Sides=1},{Style="double5",Sides=2},{Style="single7",Sides=1},{Style="double7",Sides=2}}}, --no versus
		maniax = {{{Style="single",Sides=1},{Style="double"}},{{Style="versus"}}},
		techno =	{{{Style="single4",Sides=1},{Style="single5",Sides=1},{Style="single8",Sides=1},{Style="double4",Sides=2},{Style="double5",Sides=2}},{{Style="versus4",Sides=2},{Style="versus5",Sides=2},{Style="versus8",Sides=2}}},
		--techno =	{{--[[{Style="single4",Sides=1},{Style="single5",Sides=1},]]{Style="single8",Sides=1},--[[{Style="double4",Sides=2},{Style="double5",Sides=2}]]},{--[[{Style="versus4",Sides=2},{Style="versus5",Sides=2},]]{Style="versus8",Sides=2}}},
		pnm    = {{{Style="pnm-five",Sides=1},{Style="pnm-nine",Sides=1}}}, --no vs
		lights = {{{Style="cabinet"}}}, --why?
	}

	--A lot of the modes without versus keep p2 unmapped