-----------------------
-- Compatibility
-----------------------

--Player indexes
pNum={PLAYER_1,PLAYER_2} -- pNum[pn] - eg: pNum[1] -> PLAYER_1 -> "PlayerNumber_P1" on SM5, 0 on 3.95.
pText={[PLAYER_1]=1, [PLAYER_2]=2} -- eg, pText["PlayerNumber_P1"] -> 1

--Tween bools
Bool=SM_VERSION>=5 and {[true]=true,[false]=false} or setmetatable({[true]=1,[false]=0},{__index=function(s,k) return 0 end}) -- Bool[cond]

--Difficulty slots
dNum={} dText={} for d,v in next,DifficultyNames,nil do local name=SM_VERSION==5 and "Difficulty_"..v or d-1 dText[name]=d-1 dNum[d-1]=name end

--Steps type
local adjustedststr={} for st,v in next,StepsTypeString,nil do local parts=split("-",v) for i=1,2 do parts[i]=string.capitalize(parts[i]) end adjustedststr[st]=join("_",parts) end --"dance-single" -> "Dance_Single"
stNum={} stText={} for st,v in next,adjustedststr,nil do local name=SM_VERSION==5 and "StepsType_"..v or st-1 stText[name]=st-1 stNum[st-1]=name end


--[[
StepsTypeString = {
	"dance-single","dance-double","dance-couple","dance-solo",
	"pump-single","pump-halfdouble","pump-double","pump-couple",
	"ez2-single","ez2-double","ez2-real","para-single","para-versus","ds3ddx-single",
	"bm-single5","bm-double5","bm-single7","bm-double7","maniax-single","maniax-double",
	"techno-single4","techno-single5","techno-single8","techno-double4","techno-double5",
	"pnm-five","pnm-nine","lights-cabinet"
}
]]

--Get



-----------------------
-- 5.* -> 3.95 Lua
-----------------------


-----------------------
-- 3.9 -> 3.95 Lua
-----------------------

-- Difficulty
--DifficultyToThemedString(diff) --3.95
--CourseDifficultyToThemedString(diff) --3.95

-- GameState
--NumStagesLeft()
--IsFinalStage()
--IsExtraStage()
--IsExtraStage2()
--CourseSongIndex()
--PlayModeName()
if GameState.GetPlayMode then PlayModeName=function() return PlayModeSM5Names[GAMESTATE:GetPlayMode()] end end --SM5
--CurStyleName()
CurStyleName=CurStyleName or function() return GAMESTATE:GetCurrentStyle():GetName() end
GetNumPlayersEnabled=GetNumPlayersEnabled or function() return GAMESTATE:GetNumPlayersEnabled() end
function PlayerUsingBothSides() return GameState.PlayerUsingBothSides and GAMESTATE:PlayerUsingBothSides()
	or not GameState.PlayerUsingBothSides and GAMESTATE:GetCurrentStyle():GetStyleType()=="StyleType_OnePlayerTwoSides" end

--GetEasiestNotesDifficulty()
GetEasiestNotesDifficulty=GetEasiestNotesDifficulty or function() return GAMESTATE:GetEasiestStepsDifficulty() end
--GetStageText() --3.95 only
function GetEnv(var) local v=GameState.GetEnv and GAMESTATE:GetEnv(var) or GameEnv[var] return v and tonumber(v) or v~='false' and v end --Gamestate GetEnv only returns strings (because env is a string map) - wrap bools in a string
function SetEnv(var,val) local str=tostring(val) or 'false' if GameState.SetEnv then GAMESTATE:SetEnv(var,str) else GameEnv[var]=str end end
function CurSong() return GAMESTATE:GetCurrentSong() end
function CurSteps(pn) return GAMESTATE:GetCurrentSteps(pNum[pn]) end

function IsWinner(pn) return GAMESTATE:IsWinner(pNum[pn]) end
function IsCourseMode() return GAMESTATE:IsCourseMode() end
function IsDemonstration() return GAMESTATE:IsDemonstration() end

-- Grade
--GradeToString(g)

-- LuaHelpers (3.9) / DateTime (3.95)
--MonthToString(month) --3.95
--MonthOfYear()
--DayOfMonth()
--Hour()
--Minute()
--Second()
--Year()
--Weekday()
--DayOfYear()

-- MemoryCardManager
--IsAnyPlayerUsingMemoryCard() --(3.95 only; removed in SM5)
IsAnyPlayerUsingMemoryCard=IsAnyPlayerUsingMemoryCard or function() return MEMCARDMAN:GetCardState(pNum[1])==MEMORY_CARD_STATE_READY or MEMCARDMAN:GetCardState(pNum[2])==MEMORY_CARD_STATE_READY end

-- NetworkSyncManager
--IsNetConnected()
--IsNetSMOnline() --3.95 only
--ReportStyle() --3.95 only
--ConnectToServer(server) --3.95 only?
--IsSMOnlineLoggedIn(int) --395 only

-- PercentageDisplay
--FormatPercentScore(num) --3.95

-- PlayerStageStats
--GetGradeFromPercent(num) --3.95

-- RageUtil
--SecondsToMSSMsMs(sec) --3.95

-- SongManager
--Song in 3.9 is Song(name), in 3.95+ it changed to be the Song metatable (ie, Song.GetSongDir)
--Note: It's GetSong now. Song is already a method table for song objects.
if MUSICWHEEL_EXTRA_FEATURES then
	function GetSong(dir) print('Song('..dir..')') return MasterSongList[dir] end
else
	function GetSong(name) return SONGMAN:FindSong(name) end
end
function SongFullDisplayTitle(song) return song:GetDisplayFullTitle() end  --how would you use it? There is no settext in 3.9.
function StepsMeter(steps) return steps:GetMeter() end

-- StageStats
function GetStagesPlayed() return STATSMAN:GetStagesPlayed() end --Surely that's just StageIndex()+1 ? (not necessarily; what about long songs?)
function GetBestGrade() return STATSMAN:GetBestGrade() end
function GetWorstGrade() return STATSMAN:GetWorstGrade() end
--OnePassed()
function FullCombo(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pNum[pn]):FullCombo() end
function MaxCombo(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pNum[pn]):GetMaxCombo() end
function GetGrade(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pNum[pn]):GetGrade() end
--Grade(str)
function OneGotGrade(g) return GetGrade(1)==g or GetGrade(2)==g end
function GetFinalGrade(pn) return STATSMAN:GetFinalGrade(pNum[pn]) end
--GetBestFinalGrade()

-----------------------
-- Aliases for 5.* Metrics
-----------------------

--blend mode names
noeffect = "BlendMode_NoEffect"
writeonpass = "ZTestMode_WriteOnPass"
writeonfail = "ZTestMode_WriteOnFail"