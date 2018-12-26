function CurDifficulty(pn) return IsCourseMode() and CurTrail(pn) and CurTrail(pn):GetDifficulty() or CurSteps(pn) and CurSteps(pn):GetDifficulty() or GAMESTATE:GetPreferredDifficulty(pNum[pn]) end
function GetNearestDifficulty(song,pn,pdiff)
	local getn=table.getn
	local abs=math.abs
	--local cs=GAMESTATE:GetCurrentSteps(pNum[pn])
	local st=GetStepsType() --cs and cs:GetStepsType() or GetScreen():GetChild('MusicWheel') and GetScreen():GetChild('MusicWheel'):getaux()
	if not st then return false end
	local t=song:GetStepsByStepsType(st)
	local pd=pdiff or GAMESTATE:GetPreferredDifficulty(pNum[pn])
	local diff=false
	for i=1,getn(t) do if t[i]:GetDifficulty()==pd then return t[i] end end
	local closestDiff=999
	for i=1,getn(t) do local d=abs(pd-t[i]:GetDifficulty()) if d<closestDiff then diff=t[i] closestDiff=d end end
	return diff or false
end

function IsNovice(pn) return not IsCourseMode() and CurSteps(pn) and CurSteps(pn):GetDifficulty()==DIFFICULTY_BEGINNER and CurSteps(pn):GetMeter()==1 end
--function IsNovice(pn) return GAMESTATE:IsDemonstration() or not IsCourseMode() and CurSteps(pn):GetDifficulty()==DIFFICULTY_BEGINNER and CurSteps(pn):GetMeter()==1 end
function GetEasiestStepsMeter() return math.min(CurSteps(1) and CurSteps(1):GetMeter() or CurSteps(2):GetMeter(),CurSteps(2) and CurSteps(2):GetMeter() or CurSteps(1):GetMeter()) end

function GameState.SetPreferredDifficulty(GAMESTATE,pn,diff) GameCommand("difficulty,"..DifficultyNames[diff+1],pText[pn]) end