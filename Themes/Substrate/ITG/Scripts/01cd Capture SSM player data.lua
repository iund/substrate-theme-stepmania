Capture.PaneObjects=function(s,pn) --Get the pane objects and put them into a table, to run GetText() on later.
		panec=Capture.ActorFrame.GetChildren(s).children[2].children --child order: under, contents, over
		PaneItemObjects=PaneItemObjects or {}
		PaneItemObjects[pn]=PaneItemObjects[pn] or {}
		for i,n in next,PaneItemNames,nil do
		
			PaneItemObjects[pn][n]={ Text=panec[i*2-1], Label=panec[i*2] }
		end
	end
Capture.SongStats=function(pn) -- Returns a table containing name=value pairs (names correspond to PaneItems)
		local p=PaneItemObjects[pn]
		if not p then return {} end --assert(p)

		local out={}
		local find=string.find
		local sub=string.sub
		for _,v in next,PaneItems[IsCourseMode()],nil do
			local val=p[v].Text:GetText()
			val=find(v,'HighScore') and val~="N/A" and sub(val,1,-2) or val
			out[v]=not find(v,'HighName') and tonumber(val) or val
			SetEnv(v..'P'..pn,out[v])
		end
--		DumpTable(out,"Capture.SongStats")
		--[[ Returns:
		return {
			["SongHands"]=0
Capture.		["SongJumps"]=4
Capture.		["SongRolls"]=0
Capture.		["MachineHighName"]="????"
Capture.		["MachineHighScore"]=90.51
Capture.		["ProfileHighScore"]="N/"
Capture.		["SongMines"]=0
Capture.		["SongHolds"]=0
Capture.		["SongNumSteps"]=78
Capture.	}
		--]]
		return out
	end
--[[
Capture.PaneObjects=function(pane,pn) --Get the pane objects and put them into a table, to run GetText() on later.
		local pane=GetScreen():GetChild('PaneDisplayP'..pn)
		assert(pane)
		if not pane then return end
		pane=pane:GetChild('') --contents frame (the others are called 'Under' and 'Over')
		PaneItemObjects=PaneItemObjects or {}
		PaneItemObjects[pn]=PaneItemObjects[pn] or {}
		for _,n in next,PaneItems[IsCourseMode()],nil do PaneItemObjects[pn][n]={ Label=pane:GetChild(n..'Label'), Text=pane:GetChild(n..'Text') } end
	end
Capture.SongStats=function(pn) -- Returns a table containing name=value pairs (names correspond to PaneItems)
		local pane=GetScreen():GetChild('PaneDisplayP'..pn)
		assert(pane)
		if not pane then return end
		pane=pane:GetChild('')
		local panevalues={}
		local find=string.find
		local sub=string.sub
		for _,v in next,PaneItems[IsCourseMode()],nil do
			local val=pane:GetChild(v..'Text'):GetText()
			val=find(v,'HighScore') and val~="N/A" and sub(val,1,-2) or val
			panevalues[v]=not find(v,'HighName') and tonumber(val) or val
			SetEnv(v..'P'..pn,panevalues[v])
		end
		--[ [ Returns:
		return {
			["SongHands"]=0
Capture.		["SongJumps"]=4
Capture.		["SongRolls"]=0
Capture.		["MachineHighName"]="????"
Capture.		["MachineHighScore"]=90.51
Capture.		["ProfileHighScore"]="N/"
Capture.		["SongMines"]=0
Capture.		["SongHolds"]=0
Capture.		["SongNumSteps"]=78
Capture.	}
		--] ]
		return panevalues
	end
--]]
Capture.Score=function(pn) --saves (to env) and returns a player's score value.
		local s=GetScreen():GetChild('PercentP'..pn) and GetScreen():GetChild('PercentP'..pn):GetChild('PercentP'..pn):GetText() --evaluation
			or GetScreen():GetChild('PaneDisplayP'..pn) and GetScreen():GetChild('PaneDisplayP'..pn):GetChild(''):GetChild('MachineHighScoreText'):GetText() --select music
			or GetScreen():GetChild('ScoreP'..pn) and GetScreen():GetChild('ScoreP'..pn):GetChild('ScoreDisplayPercentage Percent'):GetChild('PercentP'..pn):GetText() --gameplay
		if s then s=string.sub(s,1,-2) SetEnv('ScoreP'..pn,s) end
		return tonumber(s or 0)
	end
Capture.Meter=function(pn) return
		IsCourseMode() and Trail.GetMeter and CurTrail(pn) and CurTrail(pn):GetMeter()
		or CurSteps(pn) and CurSteps(pn):GetMeter()
		or tonumber(GetScreen():GetChild('MeterP'..pn):GetChild('Meter'):GetText())
	end
Capture.ModsIconRow={ --poll mod icons for CodeMod
		On=function(s)
			local pn=s:getaux()
			ModsIcons=ModsIcons or {}
			ModsIcons[pn]=Capture.ActorFrame.GetChildren(s)
			ModsIconChangedFlag=ModsIconChangedFlag or {}
			ModsIconChangedFlag[pn]=ModsIcons[pn].children[1].children[2]
			ModsIconChangedFlag[pn]:settext(' ')
--[[
			--move player icon to the bottom
			local spacingY=ModsIcons[pn].children[1].self:GetY() - ModsIcons[pn].children[2].self:GetY()
			local icons=ModsIcons[pn].children
			for i=1,table.getn(icons) do icons[i].self:addy(i==1 and spacingY*-7 or spacingY) end
--]]
			CodeMod=CodeMod or {}
			CodeModInit(pn)
			Capture.ModsIconRow.SetIcons(s,pn)
			LuaEffect(s,"Poll")
		end,
		Poll=function(s) --because Stepmania always sets the spare row's text to '' whenever the contents change.
			if not ModsIconChangedFlag then return end
			local pn=s:getaux()
			local flag=ModsIconChangedFlag[pn]
			if flag:GetText()=='' then CodeModChanged(pn) Capture.ModsIconRow.SetIcons(s,pn) flag:settext(' ') end
		end,
		SetIcons=function(s,pn)
			-- Overwrite Stepmania's mod icon text with our own.
		
			--TODO
--[[
			local icons=ModsIcons[pn].children
			local env=GetProfile(pn) --GAMESTATE:Env()[pn]
			local speed=FindSpeedMod(pn)

			-- use our own (better) mods icons list that echoes the mods menu order somewhat
			local noteskin=UsingModifierFromList(pn,NoteSkinList)
			local persp=UsingModifierFromList(pn,{'overhead','hallway','distant','incoming','space'})
			
			local contents={
				(env.SpeedChanges and 'M' or 'C')..env.BPM,
				env.Mods.Mini and env.Mods.Mini~=0 and 'Mini '..env.Mods.Mini..'%' or '',
				noteskin or '',
				persp or '',
				env.JudgeFont~=DefaultMods.JudgeFont and env.JudgeFont or '',
				UsingModifier(pn,'cover') and 'Hide BG' or '',
				
				--hmm... what can i put in here? Ghost measure counter?
				GetProfile(pn).MeasureType and 'Stream '..GetProfile(pn).MeasureType or ''
			}
		
			local upper=string.upper
			for i=1,table.getn(contents) do
				local on=contents[i]~=''
				icons[i+1].children[1]:setstate((pn-1)*3+1+(on and 1 or 0))
				icons[i+1].children[2]:settext(upper(contents[i]))
			end
--]]
		end,
		Off=function(s)
			ModsIcons=nil
			ModsIconChangedFlag=nil
			CodeMod=nil
		end
	}
