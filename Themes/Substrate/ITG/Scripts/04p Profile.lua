-----------------------
-- Profile handling
-----------------------

function GetSpeedModStringAuto(pn)
	local str=GetProfile(pn).SpeedMod and SpeedModString(pn) or FindSpeedModString(pn)
	return "name,"..str
end

function LoadProfile()
	if GetEnv('ProfileLoaded') then return end SetEnv('ProfileLoaded',1) --run this only once at credit start

	--Temp variables used by the game. Set some defaults here.
	Env().SongMods={
		Rate=1,
		Lives=4
	}
	Env().SongBPM={}
	Scores={} --Used to fill out the name entry screen.
	
	Env().NumStagesPlayed=0 --for event mode

	Rival.Init()
	
	ForeachPlayer(function(pn)
		Env()[pn]={}

		local env=GetProfile(pn)

		if GetEnv("CrippledProfiles") then LoadProfileAux(pn) end

		table.copy(DefaultMods,env,true)

		--do not overwrite these
		env.Rival=env.Rival or {}
		env.GhostData=env.GhostData or {}
		env.CourseData=env.CourseData or {}
		
			if env.Mods then for n,v in next,env.Mods,nil do
				if type(v)=='number' or type(v)=='boolean' then
					ApplyModifier(pn,n,v)

					--ApplyModifier(pn, type(v)=='number' and string.format('%d%% %s', v, n) or type(v)=='boolean' and (v and '' or 'no ')..n )
				end
			end end
--			for n,v in next,env,nil do env[n]=GetProfile(pn)[n] or v end -- ????? what

		if UsingUSB(pn) then
			if not GetEnv("CrippledProfiles") then
				env.UUID=env.UUID or uuid()
				Rival.InitPlayer(pn)
			end
			--prevent the game tripping over an assert
			PROFILEMAN:GetProfile(pNum[pn]):SetGoalType(GOAL_NONE)

			Env().FullMode=true --If you're using a usb you obviously don't want simple mode 
		end
	end) --end
	
	Rival.AfterInit()
end

function LoadSpeedMod()
	--This must be separate from LoadProfile() because importing speed mods (X-mods) into the correct M-Mod requires the bpm values of whatever file was last played.

	if GetEnv('SpeedModLoaded') then return end SetEnv('SpeedModLoaded',1)
	ForeachPlayer(function(pn)
		local env=GetProfile(pn)
		
		env.SpeedMod=env.SpeedMod or FindSpeedMod(pn)
		
		if not GetSysConfig().UseXMods and env.SpeedMod.Type=="X" then env.SpeedMod.Type="M" end
--[[
		if not env.BPM then
			local speed=FindSpeedMod(pn)
			env.BPM=speed.BPM
			env.SpeedChanges=speed.SpeedChanges
		end
--]]
		--(A saved X-Mod will be converted to a M-Mod, which means waiting for the BPM field to be populated by the last picked song)
--[[
		local format=string.format
		local UsingModifier=UsingModifier
		local env=GetProfile(pn)
		local bpm=GetBPM()
		for speed=1,9999 do
			if UsingModifier(pn,'C'..speed) then env.BPM=speed env.SpeedChanges=env.SpeedChanges or false --tricky
			elseif UsingModifier(pn,format('%2.2fx',speed/100)) then
				env.SpeedChanges=true
				local maxbpm=bpm and (tonumber(bpm[2]) or tonumber(bpm[1])) or 0
				env.BPM=maxbpm~=0 and maxbpm*speed/100 or DefaultMods.BPM
			end
		end
--]]
--		print('saved bpm='..env.BPM)
--		ApplyModifier(pn,'1x,C'..env.BPM)
	end)
end

--Ending

function SaveProfile() --Save USB lua table here.
	local format=string.format
	ForeachPlayer(function(pn)
		if UsingUSB(pn) and GetProfile(pn) then
			local mods=GetProfile(pn).Mods
			for _,mod in next,ModsSaveList,nil do --Save named mods
				if mod.Type=='number' then
					for pc=mod.Min,mod.Max do if UsingModifier(pn,mod.Name,pc) then mods[mod.Name]=pc end end
				else
					mods[mod.Name]=UsingModifier(pn,mod.Name)
				end
			end
			SaveProfileAux(pn)
		end
	end)
end

function ProfileAux(pn,i,val) --Combine get and set into one function (neat idea from SM5)
	local p=PROFILEMAN:GetProfile(pNum[pn])
	local v=({"GoalType","GoalSeconds","GoalCalories"})[i]
	local out=Profile["Get"..v](p)
	if val~=nil then Profile["Set"..v](p,val) end
	return out
end

function WeightValue(pn,val) --Scale from 0,20-1000 (clamped by the game) to 0-981
	--This gets read from editable.ini. Use at own risk?
	local p=PROFILEMAN:GetProfile(pNum[pn])
	local out=p:GetWeightPounds()
	if val~=nil then p:SetWeightPounds(val>0 and val+19 or val) end
	return out>0 and out-19 or 0
end		

-- Alternate place to stash variables, should saved lua state fail to load.
-- Works in all versions of oITG + SM5
function LoadProfileAux(pn)
	local env=GetProfile(pn)

	if ProfileAux(pn,2)>=0 or ProfileAux(pn,3)>=0 then return end --because neg values are never normally written, use neg as a validation check

	--load the uuid, then immediately reset GoalType to a value that won't trip an assert in the game code.
	local uuid=ProfileAux(pn,1)
	env.UUID=uuid~=clamp(uuid,0,2) and uuid or math.floor(math.random()*2^32-2^31)
	ProfileAux(pn,1,GOAL_NONE)

	local bits={inttobits(ProfileAux(pn,2),31,0),inttobits(ProfileAux(pn,3),31,0)}

	local stype=bitstouint(bits[1],1,0)
	env.SpeedMod=env.SpeedMod or {}
	env.SpeedMod.Type=	stype==0 and "M" or stype==1 and "C" or "X"
	env.SpeedMod.BPM=(bitstouint(bits[1],10,2)+5)*5 -- 25-1300 bpm
	env.SpeedMod.XMod=(bitstouint(bits[1],18,11)+5)*0.05 --0.25x-13.00x
	env.Mods=env.Mods or {}
	env.Mods.Mini                =bitstouint(bits[1],26,19)-80
	env.Mods.Cover               =bitstouint(bits[1],30,27)*10
	env.HideCombo            =bitstouint(bits[2],0,0)~=0

	env.ComboColour              =bitstouint(bits[2],2,1)+1
	env.HideHoldJudge            =bitstouint(bits[2],3,3)~=0

	env.JudgeAnimation           =bitstouint(bits[1],5,4)+1
--TODO:	env.MeasureType              =({false,4,8,12,16,24,32,48})[bitstoint(bits[1],27,25)+1] or false
	env.StepsListPage=bitstouint(bits[1],10,9)+1

end

function SaveProfileAux(pn)
	local env=GetProfile(pn)

	local tab1=mergebits(
		inttobits(({M=0,C=1,X=2})[env.SpeedMod.Type] or 0,1,0),
		inttobits(math.floor(env.SpeedMod.BPM/5)-5,10,2),
		inttobits(math.floor(env.SpeedMod.XMod/0.05)-5,18,11),
		inttobits(math.floor((env.Mods.Mini or 0)+80),26,19),
		inttobits(math.floor((env.Mods.Cover or 0)/10),30,27),
		{[32]=true}
	)
	ProfileAux(pn,2,bitstoint(tab1,31,0))

	local tab2=mergebits(
		inttobits(env.HideCombo and 1 or 0,0,0),
		inttobits(env.ComboColour-1,2,1),
		inttobits(env.HideHoldJudge and 1 or 0,3,3),
		inttobits(env.JudgeAnimation-1,5,4),
		inttobits(env.StepsListPage-1,10,9),
		{[32]=true}
	)
	ProfileAux(pn,3,bitstoint(tab2,31,0))

--not yet; this would make oITG throw an assert with other themes lacking this check
--	ProfileAux(pn,1,type(env.UUID)=="number" and env.UUID or 0)

end
