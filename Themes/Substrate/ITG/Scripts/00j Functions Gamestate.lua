
function SetCourseSort(sort,reload) SetPref("CourseSortOrder",sort) if reload then SetScreen(Branch.SelectMusic()) end end
function SetStyle(style,reload) GameCommand("style,"..style) if reload then SetScreen(Branch.SelectMusic()) end end
function SetPlayMode(pm,reload) GameCommand("playmode,"..pm) if reload then SetScreen(Branch.SelectMusic()) end end
function SetSort(sort,reload) GameCommand("sort,"..sort) if reload then SetScreen(Branch.SelectMusic()) end end

function OptionOrder(list,dir) --returns for example "1,2:2,3:3,4:4,1" for a 4 item list
	local mod=math.mod
	local qty=table.getn(list)
	local out={}
	for i=1,qty do out[dir==1 and qty-i or i]=i..":"..(mod(i,qty)+dir) end
	return join(",",out)
end

function IsNetwork() return IsNetConnected() or IsNetSMOnline() end

function GameState.WasReset(GAMESTATE) return GAMESTATE:GetPreferredDifficulty(pNum[1])==DIFFICULTY_INVALID and GAMESTATE:GetPreferredDifficulty(pNum[2])==DIFFICULTY_INVALID end

function GameState.Reset(GAMESTATE)
	--any attract screen will do it I think
--	PrepareScreen("ScreenAttract") DeletePreparedScreens()
	
	--if not:
-- [[
	--local coinmode=GetPref("CoinMode")
	GAMESTATE:SetTemporaryEventMode(true)
	--SetPref("CoinMode",0) --take it out of pay mode or the game will force [Common] InitialScreen
	PrepareScreen("TitleMenu") DeletePreparedScreens()
	GAMESTATE:SetTemporaryEventMode(false)
	--SetPref("CoinMode",coinmode)
--]]

end
