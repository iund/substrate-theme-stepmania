-- Inherited this code I made for Simply LV

function GameplaySetup()
	local Song = GAMESTATE:GetCurrentSong()
	local forced_noteskin=false
	local players_required=false

	if Song and not string.find(Song:GetSongDir(),'@mc') then --Don't process for USB customs (easy way to crash the machine)

		--Force noteskins for specific files
		if string.sub(Song:GetSongDir(),11)=='Songs/UKSRT' or string.sub(Song:GetSongDir(),23)=='Songs/Mawaru Collection' then
			if string.find(string.lower(Song:GetDisplayMainTitle()),'setsu') then
				forced_noteskin='DivinEntity'
			elseif Song:GetDisplayMainTitle()=='MAWARUCHI SURVIVER' or Song:GetDisplayMainTitle()=='MAWARU RIDES AGAIN' then
				forced_noteskin='cel-cmd'
			elseif string.find(Song:GetSongDir(),'UKSRT7.3') and Song:GetSongDir()~='SRT - Machine Gun' then
				forced_noteskin='DivinEntity'
			end
		end
		--Handle files with "2 PLAYERS" in the title (eg, WinDEU Hates You 401K)
		if not GAMESTATE:IsCourseMode() and string.find(string.lower(Song:GetDisplayFullTitle()),'2 players') then players_required=2 end

		--Read special attributes in simfile - #GENRE:name1=value1|name2=value2;
		--These can be used to override forced values above.
		if Song:GetGenre() and string.find(Song:GetGenre(),"=") then --ignore actual genre fields
			local attrlist = GetPairsFromString(Song:GetGenre(),"|") -- , works but it conflicts with applying multiple mods in mods= - use | instead
			for m,v in pairs(attrlist) do
				local n=string.lower(m) -- make it case-insensitive

				if n=="mods" then GAMESTATE:ApplyGameCommand('mod,'..v) end
				if n=="noteskin" then forced_noteskin=v~='any' and v or false end
				if n=="players" then players_required=v end

				if n=="type" then
					--add more types here if needed
					if v=="randomsong" then
						--Pick a random song with the difficulty meter in the current slot.
						local curmeter = GetNearestDifficulty(GAMESTATE:GetCurrentSong(),GAMESTATE:GetMasterPlayerNumber()+1):GetMeter()
						local entry = GetRandomSongAndStepsByMeter(curmeter)
						if entry then
							GAMESTATE:SetCurrentSong(entry.Song)
							ForeachPlayer(function(player) GAMESTATE:SetCurrentSteps(player,entry.Steps) end)
						else
							ScreenMessage('No songs of this difficulty ('..curmeter..') present')
							return Branch.SelectMusic()
						end
					elseif v=="randomsongany" then
						--Pick a random song with a random difficulty.
						local entry = SONGMAN:GetRandomSong()
						GAMESTATE:SetCurrentSong(entry)
						local st = entry:GetStepsByStepsType(GetEnv('StepsType'))
						local slot = math.floor(math.random()*table.getn(st))+1
						ForeachPlayer(function(player) GAMESTATE:SetCurrentSteps(player,st[slot]) end)
					elseif v=="nonstopmode" then
						--Switch to "Nonstop" mode
						GAMESTATE:ApplyGameCommand('playmode,nonstop')
						return Branch.NonstopInstructions()
					end
				end
			end
		end
	end

	if forced_noteskin then
		local game = CurGame or 'dance'
		if not GetPath('NoteSkins/'..game..'/'..forced_noteskin..'/*') then
			ScreenMessage('Missing noteskin '..forced_noteskin)
			return Branch.SelectMusic()
		else
			GAMESTATE:ApplyGameCommand('mod,'..forced_noteskin)
		end
	end

	if players_required and players_required~=GAMESTATE:GetNumPlayersEnabled() then
		ScreenMessage(tostring(players_required)..' players required')
		return Branch.SelectMusic()
	end

	return Branch.Stage()
end
