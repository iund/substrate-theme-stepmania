---Mods

--5.1 removed ApplyGameCommand, so feature checking is necessary.

--eg, UsingModifier(1,"Mini",50) checks for 50% mini on p1, UsingModifier(2,"Mirror") checks if mirror is used on P2.
--ApplyModifier(2,"Cover",25) applies 25% cover to p2.
--ApplyModifier(2,"turn",false) removes p2's turn mods. (3.95 gets "no turn")
--ApplySpeedMod(1,"M",800) will apply M800 speed to p1

function UsingModifier(pn,mod,value)
	if GameState.GetPlayerState and PlayerState and PlayerState.GetPlayerOptions then
		local mods=GAMESTATE:GetPlayerState(pNum[pn]):GetPlayerOptions("ModsLevel_Preferred")
		assert(PlayerOptions and PlayerOptions[mod],"PlayerOptions["..mod.."]")
		local v=PlayerOptions[mod](mods)
		return type(value)=='number' and (value/100)==v or value==v
	else
		return mod and GAMESTATE:PlayerIsUsingModifier(pNum[pn],(type(value)=='number' and value.."% " or "")..mod)
	end
end

function ApplyModifier(pn,mod,value,approach)
	if GameState.GetPlayerState and PlayerState and PlayerState.GetPlayerOptions then
		if pn then
			local mods=GAMESTATE:GetPlayerState(pNum[pn]):GetPlayerOptions("ModsLevel_Preferred")
			assert(PlayerOptions and PlayerOptions[mod],"PlayerOptions["..mod.."]")
			PlayerOptions[mod](mods,type(value)=='number' and value/100 or value)
			
		else
			--its a shared mod
		
		end
	else
		-- *12 150% drunk
		-- no bumpy
		-- cel
		GAMESTATE:ApplyGameCommand("mod,"
		..(approach and IsNumber(approach) and "*"..tostring(approach) or "").." "
		..(value==false and "no " or IsNumber(value) and value.."% " or "")
		..mod,pn)
	end
end

function UsingNoteskin(pn,noteskin)
	if GameState.GetPlayerState and PlayerState and PlayerState.GetPlayerOptions then
		local mods=GAMESTATE:GetPlayerState(pNum[pn]):GetPlayerOptions("ModsLevel_Preferred")
		return PlayerOptions.NoteSkin(mods)==noteskin
	else
		return noteskin and GAMESTATE:PlayerIsUsingModifier(pNum[pn],noteskin)
	end
end

function ApplyNoteskin(pn,noteskin)
	if GameState.GetPlayerState and PlayerState and PlayerState.GetPlayerOptions then
		local mods=GAMESTATE:GetPlayerState(pNum[pn]):GetPlayerOptions("ModsLevel_Preferred")
		PlayerOptions.NoteSkin(mods,noteskin)
	else
		GAMESTATE:ApplyGameCommand('mod,'..noteskin,pn)
	end
end

--returns the first active modifier in the list.
function UsingModifierFromList(pn,list) for i=1,table.getn(list) do if UsingModifier(pn,list[i]) then return list[i] end end return false end

--Aliases for old SL-derived code
CheckMod=UsingModifier
function ApplyMod(mod,pn) ApplyModifier(pn,mod) end

--[[
SM5.0.x mods handling:

			state:SetPlayerOptions("ModsLevel_Preferred", self.Choices[1])
			local pref = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Preferred")

function GetSpeedModeAndValueFromPoptions(pn)
	local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
	local speed= nil
	local mode= nil
	if poptions:MaxScrollBPM() > 0 then
		mode= "m"
		speed= math.round(poptions:MaxScrollBPM())
	elseif poptions:TimeSpacing() > 0 then
		mode= "C"
		speed= math.round(poptions:ScrollBPM())
	else
		mode= "x"
		speed= math.round(poptions:ScrollSpeed() * 100)
	end
	return speed, mode
end
]]

--[[
In SM5.0.12 OptionsBinding.h:
	// Functions are designed to combine Get and Set into one, to be less clumsy to use. -Kyz
	// If a valid arg is passed, the value is set.
	// The previous value is returned.

	FLOAT_INTERFACE(TimeSpacing, TimeSpacing, true);
	FLOAT_INTERFACE(MaxScrollBPM, MaxScrollBPM, true);
	FLOAT_INTERFACE(ScrollSpeed, ScrollSpeed, true);
	FLOAT_INTERFACE(ScrollBPM, ScrollBPM, true);
		ADD_METHOD(TimeSpacing);
		ADD_METHOD(MaxScrollBPM);
		ADD_METHOD(ScrollSpeed);
		ADD_METHOD(ScrollBPM);
]]

function ApplySpeedMod(pn,xcm,speed)
	if GameState.GetPlayerState and PlayerState and PlayerState.GetPlayerOptions then
		local mods=GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
		PlayerOptions[xcm.."Mod"](mods,speed)
	else
		local approach=1000000000 --do it instantly. mostly for the benefit of charts with notes on the first measure
		if xcm=="X" then
			ApplyModifier(pn,string.format('%1.2fx',speed),true,approach)
		elseif xcm=="M" then
			local bpm=GetBPM()
			local maxbpm=bpm[2] or bpm[1]
			ApplyModifier(pn,string.format('%1.2fx',speed/maxbpm),true,approach)
		else --cmods
			ApplyModifier(pn,xcm..speed,true,approach)
		end
	end
end

function FindSpeedMod(pn)
	local format=string.format
	local UsingModifier=UsingModifier
	local env={}
	local speednum=1
	local xmod=false

	if GameState.GetPlayerState and PlayerState and PlayerState.GetPlayerOptions then
		--SM5:
		local mods=GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
		
		--mods:[XMod/CMod/MMod](speed)
		for _,xcm in next,{"X","C","M"},nil do
			local speed=PlayerOptions[xcm.."Mod"](mods)
			if speed then
				xmod=xcm=="X"
				speednum=speed
			end
		end
	else
		--ITG:
		for speed=1,9999 do
			if UsingModifier(pn,'C'..speed) then
				speednum=speed xmod=false
			elseif UsingModifier(pn,format('%2.2fx',speed/100)) then
				speednum=speed/100 xmod=true
			end
		end
	end

	if xmod and GetSysConfig().UseXMods then
		env.Type="X"
		env.XMod=speednum
	elseif xmod and not GetSysConfig().UseXMods then
		--convert it to an M-Mod
		env.Type="M" --env.SpeedChanges=true
		local bpm=GetBPM()
		local maxbpm=bpm and (tonumber(bpm[2]) or tonumber(bpm[1])) or 0
		env.BPM=maxbpm~=0 and math.floor(maxbpm*speednum) or DefaultMods.BPM
	else
		env.Type="C" --env.SpeedChanges=env.SpeedChanges or false --allow for existing USB profiles using M-Mods implemented via C-mod + flag (Simply LV does this)
		env.BPM=speednum
	end

	return env
end

function FindSpeedModString(pn)
	local env=FindSpeedMod(pn)
	return env.Type=="X" and tostring(env.XMod).."x" --sprintf("%1.2fx",env.XMod)
		or env.Type=="C" and sprintf("C%d",env.BPM)
		or env.Type=="M" and sprintf("m%d",env.BPM)
end

function SpeedModString(pn,showbpm)
	local sm=GetProfile(pn).SpeedMod
	if sm.Type=="X" then --eg: 1.50x (530), 4.20x (450-780), 5.85x
		local bpm=GetBPM()
		return bpm and showbpm and sprintf("%1.2fx (%s)",sm.XMod,GetBPMString(Env().SongMods.Rate*sm.XMod,bpm)) or sprintf("%1.2fx",sm.XMod)
	else
		return sm.Type..sm.BPM --eg: M640, C1000
	end

end

function LoadDefaultMods(pn) --for CancelAll event.
	--TODO: GetProfile mod rows aren't being reset. Why?
	local t=table.duplicate(DefaultMods)
	for n,v in next,t,nil do GetProfile(pn)[n]=v end
end

--If the build of oITG we're using is crippled, warn the theme by running these functions.
CrippledProfiles={
	Flag=function() SetEnv("CrippledProfiles",1) return "1" end,
	Pacify=function() return "name,1.5x" end --Return a speed mod to keep oITG happy; this needs to be passed to SaveModifiers() later.
}

--SGP
function SaveModifiers(pn) --Save DefaultModifiers (in 3.95, mods are saved in ScreenGameplay Init, while the rest of the USB profile is saved on ScreenEnding init)
	if GetEnv("CrippledProfiles") then
		ApplySpeedMod(pn,"X",1.5) --pacify crippled versions of oITG, see above
	elseif OPENITG then
		local env=GetProfile(pn).SpeedMod
		if env.Type=="M" then
			local bpm=GetBPM()
			local maxbpm=bpm[2] or bpm[1]
			ApplyModifier(pn,"m"..env.BPM,true)
		end
	else
		ApplyStageSpeedMod(pn,true)
	end
end

function ApplySpeedModBPM(pn,oldtype,newtype)
	--When switching speed type in the mods menu, preserve the BPM value.
	local sm=GetProfile(pn).SpeedMod
	local bpm=GetBPM()
	local maxbpm=bpm[2] or bpm[1]
	if maxbpm and maxbpm>0 then
		if oldtype~="X" and newtype=="X" then
			sm.XMod=sm.BPM/maxbpm
		elseif oldtype=="X" and newtype~="X" then
			sm.BPM=math.round(sm.XMod*maxbpm)
		end
	end
end

function ApplyStageSpeedMod(pn,norate)
	local rate=norate and 1 or Env().SongMods.Rate
	local env=GetProfile(pn).SpeedMod
	local bpm=GetBPM()
	local maxbpm=bpm[2] or bpm[1]
	if env.Type=="X" then
		ApplySpeedMod(pn,"X",env.XMod/rate)
	elseif env.Type=="M" and bpm[1] then --elseif env.SpeedChanges and bpm[1] then
		ApplySpeedMod(pn,"M",env.BPM/rate)
	else
		ApplySpeedMod(pn,"X",1) --make cmod work right. the current xmod multiplies whatever cmod value is set
		ApplySpeedMod(pn,"C",env.BPM/rate)
	end
end

function SpeedModString(pn,showbpm)
	local sm=GetProfile(pn).SpeedMod
	if sm.Type=="X" then --eg: 1.50x (530), 4.20x (450-780), 5.85x
		local bpm=GetBPM()
		return bpm and showbpm and sprintf("%1.2fx (%s)",sm.XMod,GetBPMString(Env().SongMods.Rate*sm.XMod,bpm)) or sprintf("%1.2fx",sm.XMod)
	else
		return sm.Type..sm.BPM --eg: M640, C1000
	end

end

function PlayerMods(pn,showbpm) --Returns a string with a list of mods
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

function UseForcedModifiersInBeginner() return not GAMESTATE:IsCourseMode() and (GAMESTATE:IsDemonstration() or Player(1) and CurSteps(1) and IsNovice(1) or Player(2) and CurSteps(2) and IsNovice(2)) or false end
function ForcedModifiersInBeginner() return 'clearall,'..join(",",forcedNoviceMods) end
