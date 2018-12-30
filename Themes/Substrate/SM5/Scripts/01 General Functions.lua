--General
function IsBoolean(val) return type(val)=='boolean' end
function IsString(val) return type(val)=='string' end
function IsTable(val) return type(val)=='table' end
function IsNumber(val) return type(val)=='number' end
function IsFunction(val) return type(val)=='function' end

-- numbers
function randomrange(min,max) return min+(math.random()*(max-min)) end
function within(num,min,max) return num>=min and num<=max end
function wrap(val,m,max) local min=m or 0 return within(val,min,max) and val or math.mod(val+(max-min+1)-min,max-min+1)+min end

-- trig
MATH_PI_TRIG=math.pi/360
math.dtan=function(deg) return math.tan(deg*MATH_PI_TRIG) end
math.dcos=function(deg) return math.cos(deg*MATH_PI_TRIG) end
math.dsin=function(deg) return math.sin(deg*MATH_PI_TRIG) end

math.adcos=function(deg) return math.abs(math.dcos(deg)) end
math.adsin=function(deg) return math.abs(math.dsin(deg)) end
math.adtan=function(deg) return math.abs(math.dtan(deg)) end

-- tables
table.concati=function(...) local out={} local ins=table.insert for i=1,arg.n do for _,v in next,arg[i],nil do ins(out,v) end end return out end
table.rep=function(o,n) local out={} for i=1,n do out[i]=o end return out end --like string.rep but spit out a table repeating the object n times
table.sub=function(t,first,last) local out={} for i=first,last do out[i+1-first]=t[i] end return out end
table.invert=function(t) local out={} for k,v in next,t,nil do out[v]=k end return out end

-- strings
function explode(str) local out={} local i=1 for c in string.gfind(str,".") do out[i]=c i=i+1 end return out end
function string.capitalize(str) return string.upper(string.sub(str,1,1))..string.sub(str,2) end

-- theme
function ThemeVersionString() return not THEME_VERSION and "v?" or string.format("v%d.%d%s",THEME_VERSION.MAJOR or 0, THEME_VERSION.MINOR or 0, THEME_VERSION.SUFFIX_STR or "") end

function IsWidescreen() return (SCREEN_HEIGHT/SCREEN_WIDTH)>(4/3) end

-- actors
function GetDimmedColor(color,dimfactor) local out={} for i=1,3 do out=color[i]*dimfactor end out[4]=color[4] return out end

-- settings
function GetPref(str) return PREFSMAN:GetPreference(str) end
function SetPref(str,val) return PREFSMAN:SetPreference(str,val) end
function GetMetric(sec,val) return THEME:GetMetric(sec,val) end

function GetSysConfig() return {} end --TODO implement this

-- input debugging

function DumpMouse() --Mouse doesn't seem to work on Mac. Works in Windows. Will it work in GNU/Linux?
	Trace(string.format("MouseDebug(): %d %d %d",
		INPUTFILTER:GetMouseX(),
		INPUTFILTER:GetMouseY(),
		INPUTFILTER:GetMouseWheel() -- When the wheel is moved, this value stays at either -120 or +120 depending on direction.
	))
end
--[[
mouse events:
	"LeftClick",
	"RightClick",
	"MiddleClick",
	"MouseWheelUp",
	"MouseWheelDown",
--]]

-- game state

function GetCurSong() return GAMESTATE:GetCurrentSong() end
function GetCurSteps(pn) return GAMESTATE:GetCurrentSteps(pn) end
function SetCurSteps(pn,steps) return GAMESTATE:SetCurrentSteps(pn,steps) end
function GetCurCourse() return GAMESTATE:GetCurrentCourse() end
function GetCurTrail(pn) return GAMESTATE:GetCurrentTrail(pn) end
function SetCurTrail(pn,trail) return GAMESTATE:SetCurrentTrail(pn,trail) end
function GetProfile(pn) return PROFILEMAN:GetProfile(pn) end
function GetSysProfile() return PROFILEMAN:GetMachineProfile() end
function UsingUSB(pn) return PROFILEMAN:IsPersistentProfile(pn) end
function IsCourseMode() return GAMESTATE:IsCourseMode() end
function IsDemonstration() return GAMESTATE:IsDemonstration() end

function GetPlayableTrails(course,stepstype)
	local st=stepstype or GAMESTATE:GetCurrentStyle():GetStepsType()
	local alltrails=course:GetAllTrails()
	local trails={}
	for i,t in next,alltrails,nil do
		if t:GetStepsType()==st then table.insert(trails,t) end
	end
	return trails

end

function CanPlayMarathons() return
	SONGMAN:GetNumCourses()>0 
	and (GAMESTATE:IsEventMode() or GetPref('SongsPerPlay')>2 
		and STATSMAN:GetStagesPlayed()==0)
end

function GetTitleMenuStageText()
	return
		GetPref('EventMode') and "Event Mode"
		or string.format("up to %d stages",GetPref('SongsPerPlay')) --TODO L10n
end

function GetStageText(ioffs) --This is run on Stage objects load in SWME. (ioffs offsets the stage index to be correct in Evaluation)
	if IsCourseMode() and GAMESTATE:GetCourseSongIndex()>=0 then
		return string.format("Stage %d/%d",
			GAMESTATE:GetLoadingCourseSongIndex()+1,
			GetCurCourse():GetEstimatedNumStages())
	elseif IsCourseMode() and GAMESTATE:GetCourseSongIndex()<0 then
		return GetCurCourse() and string.format("%d stages",GetCurCourse():GetEstimatedNumStages()) or ""
	elseif not IsCourseMode() and not IsDemonstration() and not GAMESTATE:IsEventMode() then
		return string.format("Stage %d/%d",
			GAMESTATE:GetCurrentStageIndex()+GAMESTATE:GetNumStagesForCurrentSongAndStepsOrCourse()+(ioffs or 0),
			GetPref('SongsPerPlay'))
	elseif GAMESTATE:IsEventMode() then
		return string.format("Stage %d",STATSMAN:GetStagesPlayed()+1+(ioffs or 0))
	else
		return ""
	end
end

-- song/chart

function GetTempoString(song,rate)
	local r=rate or GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
	local tempo=song and song:GetDisplayBpms() or {}

	for i,v in next,tempo,nil do tempo[i]=math.round(v*r) end

	return
		song and 
		(song:IsDisplayBpmConstant() and tostring(math.round(tempo[1]))
		or join("-",tempo)).." bpm" or ""
end

function GetCourseTempoString(course,rate)
	local r=rate or GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()

	local mintempo
	local maxtempo

	local hidetempo=false

	local entries=GetCurCourse():GetCourseEntries()
	
	for i,entry in next,entries,nil do
		local song=entry:GetSong()
		local tempos=song:GetDisplayBpms() or {}
		
		mintempo=not mintempo and tempos[1] or math.min(mintempo,tempos[1])
		maxtempo=not maxtempo and tempos[2] or math.max(maxtempo,tempos[2])

		hidetempo=hidetempo or song:IsDisplayBpmSecret()		
	end

	return hidetempo and "---" or
		mintempo==maxtempo
			and string.format("%.0f bpm",
				math.round(maxtempo*r))
			or string.format("%.0f-%.0f bpm",
				math.round(mintempo*r),
				math.round(maxtempo*r))

end


function GetNearestDifficulty(song,pn)
	local abs=math.abs
	if not GetCurSteps(pn) then return false end
	local st=GetCurSteps(pn):GetStepsType()
	local t=song:GetStepsByStepsType(st)
	local pd=DifficultyIndex[GAMESTATE:GetPreferredDifficulty(pn)]
	local diff=false
	local closestDiff=7
	for i=1,table.getn(t) do
		if t[i]:GetDifficulty()==pd then return t[i] end
		local d=abs(pd-DifficultyIndex[t[i]:GetDifficulty()])
		if d<closestDiff then diff=t[i] closestDiff=d end
	end
	return diff
end

function GetSortedStepsList(steps) return SortStepsList(GetCurSong():GetStepsByStepsType(steps:GetStepsType())) end

function SortStepsList(list) --Replicate StepsUtil::SortNotesArrayByDifficulty() to match the sort
	--we have to sort it because GetStepsByStepsType and co returns it in whatever order the charts appear in the .sm
	local c={"GetStepsType","GetDifficulty","GetMeter","GetDescription"}
	table.sort(list,function(a,b)
	--table.stablesort(list,function(a,b)
		--ScreenEdit only stable_sorts by difficulty slot for F5/F6 switching.
		local i=1
		while i<table.getn(c) and Steps[c[i]](a)==Steps[c[i]](b) do i=i+1 end --skip over any equal attributes
		return Steps[c[i]](a)<Steps[c[i]](b)
	end)
	return list
end

-- players

function GetPlayerName(pn)
	local name=MEMCARDMAN:GetName(pn)
	return name~="" and name or ("Player "..PlayerIndex[pn])
end

function ForeachPlayer(func) for i=1,2 do func(PlayerIndex[i]) end end
function ForeachEnabledPlayer(func) for i=1,2 do if GAMESTATE:IsPlayerEnabled(PlayerIndex[i]) then func(PlayerIndex[i]) end end end

function GetCurDifficulty(pn) return GetCurSteps(pn) and GetCurSteps(pn):GetDifficulty() or GAMESTATE:GetPreferredDifficulty(pn) end

function IsNovice(pn) return GetCurDifficulty(pn)=="Difficulty_Beginner" end

function GetSortedScoresList(pn,song,steps) --Replicate StepsUtil::SortNotesArrayByDifficulty() to match the sort
	local list={}
	local p=not pn and PROFILEMAN:GetMachineProfile() or PROFILEMAN:GetProfile(pn)
	local hsl=p:GetHighScoreList(song,steps)
	if hsl then 
		list=hsl:GetHighScores()
		local c={"GetPercentDP","GetDate","GetName"}
		table.sort(list,function(a,b)
		--table.stablesort(list,function(a,b)
			--ScreenEdit only stable_sorts by difficulty slot for F5/F6 switching.
			local i=1
			while i<table.getn(c) and HighScore[c[i]](a)==HighScore[c[i]](b) do i=i+1 end --skip over any equal attributes
			return HighScore[c[i]](a)>HighScore[c[i]](b)
		end)
	end
	return list
end

