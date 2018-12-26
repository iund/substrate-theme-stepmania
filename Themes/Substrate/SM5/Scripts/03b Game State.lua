-- Remember: need to be able to handle latejoin here

function LoadProfileData(pn)
end
	
function InitPlayer(pn)
	if GAMESTATE:IsPlayerEnabled(pn) and not GAMESTATE:GetPreferredDifficulty(pn) then
		GAMESTATE:SetPreferredDifficulty(pn,"Difficulty_Beginner")
	end

	GAMESTATE:Env().PlayerState=GAMESTATE:Env().PlayerState or {}

	local ps=GAMESTATE:Env().PlayerState

	ps[pn]={}

	ps[pn].UIColor="blue" --Default to this, unless a profile variable overrides it.

	LoadProfileData(pn)

end
--[[
function SpeedModString(pn,showbpm)
	local sm=GetProfile(pn).SpeedMod
	if sm.Type=="X" then --eg: 1.50x (530), 4.20x (450-780), 5.85x
		local bpm=GetBPM()
		return bpm and showbpm and sprintf("%1.2fx (%s)",sm.XMod,GetTempoString(Env().SongMods.Rate*sm.XMod,bpm)) or sprintf("%1.2fx",sm.XMod)
	else
		return sm.Type..sm.BPM --eg: M640, C1000
	end
end

function GetPlayerModsString(pn,showbpm) --Returns a string with a list of mods
	local insert=table.insert
	local UsingModifier=UsingModifier
	local lang=Languages[CurLanguage()].Mods
	local env=GetProfile(pn)

	--local speed=FindSpeedMod(pn)
	local mini=0 for i=-200,200 do if UsingModifier(pn,"Mini",i) then mini=i end end
	out={
		SpeedModString(pn,showbpm)
		--env.SpeedMod.Type=="X" and (env.SpeedMod.XMod.."X") or (env.SpeedMod.Type..env.SpeedMod.BPM),
		--(env.SpeedChanges and 'M' or 'C')..env.BPM,
	}
	if mini~=0 then insert(out,sprintf("Mini %.0f%%", mini)) end
	insert(out,lang.Names.Persp[UsingModifierFromList(pn,{'Overhead','Hallway','Distant','Incoming','Space'})])
	for i,ns in next,NoteSkinList[CurGame],nil do if UsingNoteskin(pn,ns) then insert(out,lang.Names.Noteskins[ns] or ns) end end
	if UsingModifier(pn,"Cover") then insert(out,lang.Titles.Cover) end
	if env.HideHoldJudge then insert(out,lang.Titles.HideHoldJudge) end
	for i,mod in next,{"Dark","Reverse","NoHolds","NoMines","NoJumps","NoHands","NoQuads","NoStretch"},nil do if UsingModifier(pn,mod) then insert(out,lang.Titles[mod] or mod) end end
	return join(", ",out)
end
--]]