------------------------
-- Code-mapped actions on ScreenSelectMusic
------------------------

function CodeModInit(pn) CodeMod[pn]={} for modname,_ in next,CodeModList(),nil do CodeMod[pn][modname]=UsingModifier(pn,modname) end end

function CodeModChanged(pn)
	for modname,action in next,CodeModList(),nil do
		if CodeMod[pn][modname]~=UsingModifier(pn,modname) then
			ApplyModifier(pn,modname,CodeMod[pn][modname]) --CodeMod[pn][modname] and modname or 'no '..modname) --revert mod
			action.Action(pn)
		end
	end
end

-- Mods

ModActions = {
--[[
	ChangeSpeed = function(pn,speeddiff)
		--TODO
	end,
	ChangeMini = function(pn,minidiff)
		--TODO
	end,
	CycleNoteAppearance = function(pn)
		do return end

		--use ITG default noteskins instead of the em2 appearance mods, but make a concession for muscle memory (hitting the code 3 times to get Solo in particular)
		local mods = NoteSkinList
		local setmod = 0
		for i=1,table.getn(mods) do if CheckMod(pn,mods[i]) then setmod=i end end
		if mods[setmod] then ApplyMod('no '..mods[setmod]) ApplyMod(mods[math.mod(setmod,table.getn(setmod))+1],pn) end
	 end,
	CyclePerspective = function(pn)
		do return end

		--Use ITG perspectives instead of EM2 hide mods?
		local mods = PerspectiveList
		local setmod = 0
		for i=1,table.getn(mods) do if CheckMod(pn,mods[i]) then setmod=i end end
		if mods[setmod] then ApplyMod('no '..mods[setmod]) ApplyMod(mods[math.mod(setmod,table.getn(setmod))+1],pn) end
	end,
	RevertAll = function(pn)
		ApplyMod('clearall',pn)
		--TODO: re-init mods menu
	end,
	TogglePage = function(pn)
		print('Toggle Page('..pn..')')

		GetProfile(pn).PaneVisible = not GetProfile(pn).PaneVisible
		local visible = GetProfile(pn).PaneVisible and 1 or 0

		print('view = '..tostring(visible))

		local pio=PaneItemObjects[pn]
		for i=1,table.getn(pio) do
			pio[i].Label:visible(visible)
			pio[i].Text:visible(visible)
		end
		
		GetScreen():GetChild('OptionIconsP'..pn):hidden(visible)
		GetScreen():GetChild('DifficultyIconP'..pn):visible(visible)
		
		--For some reason, pane:GetChild('Overlay') and ('Underlay') don't work,
		--so I have to dump the actorframe to a table
		local pane = Capture.ActorFrame.GetChildren(GetScreen():GetChild('PaneDisplayP'..pn)).children
		--these are AutoActors
		--add ; before it to fix "ambiguous syntax (function call x new statement)"
		; (pane[1].self or pane[1]):visible(visible)
		; (pane[3].self or pane[3]):visible(visible)
		
		DumpTable(pane,"pane")
- - [ [
		local pane = GetScreen():GetChild('PaneDisplayP'..pn)
		pane:GetChild('Overlay'):visible(visible)
		pane:GetChild('Underlay'):visible(visible)
] ]
- - [ [
		--visible/hidden means the text doesnt get updated
		for i,s in ipairs({pane, panebg, ModsIcons[pn].self}) do
			s:stoptweening()
			s:linear(0.2)
			s:diffusealpha(math.mod(i==3 and visible+1 or visible,2))
		end
] ]
	end
]]
}




-- Easter egg for old itg unlock codes, plus a couple of others ;)
	UnlockEasterEgg = {
	--ITG1 songs
		{ Code = 'Left,Right,Up,Down,Left,Left,Right,Right', Sound = 'Disconnected Hyper' },
		{ Code = 'Left,Down,Right,Down,Up,Right,Down,Left', Sound = 'Disconnected Mobius' },
		{ Code = 'Up,Down,Up,Down,Up,Down,Right,Right,Up', Sound = 'Infection' },
		{ Code = 'Right,Up,Down,Down,Right,Down,Up,Left,Down', Sound = 'Xuxa' },
		{ Code = 'Down,Left,Up,Up,Right,Right,Down,Left,Down', Sound = 'Tell' },
		{ Code = 'Right,Left,Left,Right,Up,Down,Down,Left,Left', Sound = 'Bubble Dancer' },
		{ Code = 'Up,Right,Up,Left,Down,Left,Right,Left,Right', Sound = "Don't Promise Me ~Happiness~" },
		{ Code = 'Left,Down,Up,Left,Down,Down,Right,Right,Up', Sound = 'Anubis' },
		{ Code = 'Left,Right,Right,Left,Up,Down,Right,Left,Down', Sound = 'DJ Party' },
		{ Code = 'Left,Up,Left,Down,Up,Down,Right,Down,Left', Sound = 'Pandemonium' },
	--ITG2 songs
		{ Code = 'Up,Down,Down,Up,Left,Left,Down,Right,Down,Up,Right', Sound = 'Disconnected Disco' },
		{ Code = 'Left,Down,Right,Right,Right,Down,Left,Up,Up,Down,Right', Sound = 'VerTex^2' },
		{ Code = 'Right,Right,Up,Up,Up,Right,Left,Left,Up,Up,Up', Sound = 'Wanna Do' },
		{ Code = 'Right,Left,Down,Down,Down,Up,Left,Down,Left,Left,Right', Sound = 'Know Your Enemy' },
		{ Code = 'Down,Up,Up,Left,Down,Right,Down,Right,Right,Down,Up', Sound = 'Hardcore Symphony' },
	--Misc stuff for fun
		{ Code = 'Left,Down,Left,Right,Down,Up,Left,Down,Up,Down', Sound = 'MEGALOVANIA (ITG ver.)' },
		{ Code = 'Right,Down,Up,Left,Up,Left,Down,Up,Right,Up,Right', Sound = 'MAX 300' },
		{ Code = 'Right,Down,Left,Up,Right,Down,Left,Up', Sound = 'random' }
	}

function UnlockEggAction(title)
	local song = title=='random' and SONGMAN:GetRandomSong() or SONGMAN:FindSong(title)
	local sound = string.find(title,'.') and title..'.ogg' or title
	local Path = THEME:GetPath( EC_SOUNDS, '', "Unlocked " .. sound )
	if not string.find(Path,'_missing') and song then
		SOUND:PlayOnce( Path )
		SOUND:DimMusic( 0.2, 3 )
		GAMESTATE:SetPreferredSong(song)
	end
end

function UnlockEgg(field)
	local pos = GetScreen():getaux()
	local c = MenuList[pos]
	local out

	if field=='Action' then
		out = c.Sound and 'lua,function() UnlockEggAction("'..c.Sound..'") end' or 'lua,'..c.Action
		GetScreen():aux(pos+1)
	else
		out = c[field] or c.Code
	end

	if pos > table.getn(MenuList) then MenuList=nil end
	return out
end
