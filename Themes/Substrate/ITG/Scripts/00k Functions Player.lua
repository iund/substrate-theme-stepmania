---Player
function IsPlayerEnabled(pn) return GAMESTATE:IsPlayerEnabled(pNum[pn]) end
function IsHumanPlayer(pn) return GAMESTATE:IsHumanPlayer(pNum[pn]) end
--function IsPlayerUsingProfile(pn) return PROFILEMAN:IsUsingProfile(pNum[pn]) end --not in 3.95?? Use UsingUSB(pn) instead.
function Player(pn) return IsPlayerEnabled(pn) or IsHumanPlayer(pn) end
function PlayerName(pn) return Player(pn) and GAMESTATE:GetPlayerDisplayName(pNum[pn]) or "" end
function MasterPlayer() return pText[GAMESTATE:GetMasterPlayerNumber()] end
function GetPN(p1cond) return GetNumPlayersEnabled()==2 and (p1cond and 2 or 1) or Player(1) and 1 or 2 end --used on various object initialisation functions
function ForeachPlayer(action) for pn=1,2 do if Player(pn) then action(pn) end end end
function UsingUSB(pn) return PROFILEMAN:IsPersistentProfile(pNum[pn]) end
function Env() return EnvTable end --function Env() return GAMESTATE:Env() or {} end --Env() is a LuaTable that doesn't get cleared on exit. The other Env functions are in Compatibility.lua

function GetNumSongsTotal(pn) return PROFILEMAN:GetProfile(pNum[pn]):GetTotalNumSongsPlayed() end
function GetGradeCount(pn,grade)
	local out=0
	local pr=PROFILEMAN:GetProfile(pNum[pn])
	local st=GetStepsType()
	local tg=Profile.GetTotalStepsWithTopGrade
	for d=0,6 do out=out+tg(pr,st,d,grade) end
	return out
end

if SM_VERSION==5 then --DEBUG: Revert this back as soon as I figure out why it's refusing to load stats.xml's lua table.
	function GetProfile(pn) return Env()[pn] or {} end
	SysProfiledebug={}
	function GetSysProfile() return SysProfiledebug or {} end
else
	function GetProfile(pn) return PROFILEMAN and UsingUSB(pn) and (Profile.GetUserTable or Profile.GetSaved)(PROFILEMAN:GetProfile(pNum[pn])) or Env()[pn] or {} end
	function GetSysProfile() return PROFILEMAN and (Profile.GetUserTable or Profile.GetSaved)(PROFILEMAN:GetMachineProfile()) or {} end
end
function GetSysConfig() local p=GetSysProfile() p.Options=p.Options or {} return p.Options end

function IsAnyPlayerUsingProfile() return Player(1) and UsingUSB(1) or Player(2) and UsingUSB(2) end

function PlayerX(pn)
	local ret=math.floor(0.5+((PlayerUsingBothSides() or GetPref('SoloSingle') and GetNumPlayersEnabled()==1) and SCREEN_CENTER_X
		or pn==1 and SCREEN_CENTER_X-(SCREEN_WIDTH/4)
		or pn==2 and SCREEN_CENTER_X+(SCREEN_WIDTH/4)))
	return ret
end

function JoinBothPlayers()
	--(in 3.95) Init any of these screens to join both players:

		--ScreenPackages
		--ScreenSetTime
		--ScreenOptionsMaster (with forceallplayers)
		--ScreenEditMenu
		--ScreenEditCoursesMenu
		--ScreenEdit (also gives the edit bars)
	
	--Or set double/versus (deducts credits though)
	
	PrepareScreen("JoinBothPlayers") DeletePreparedScreens()
end

function JoinPlayer1(allinputs)
	--ScreenSelectMusic force joins P1 and forces style=Versus, playmode=Regular if ScreenTestMode is set

	if SM_VERSION==3.95 then
		local coursemode=IsCourseMode()
		SetPref("ScreenTestMode",true)
		PrepareScreen("SelectMusic") DeletePreparedScreens() --Forces versus, change the style immediately afterward.
		GameCommand("playmode,"..(coursemode and "nonstop" or "regular")..";style,"..(allinputs and "double" or "single"))
		SetPref("ScreenTestMode",false)
	else
		--put sm5 code here
	end
end
function UnjoinPlayers(refund)
	--Might be useful somewhere?
	if SM_VERSION==3.95 then
		--refund credits if the player unjoined on the player entry screen
		if refund==true and GAMESTATE:GetCoinMode()==COIN_MODE_PAY then
			local creditstorefund=GAMESTATE:GetPremium()==PREMIUM_JOINT and math.min(1,GAMESTATE:GetNumSidesJoined()) or GAMESTATE:GetNumSidesJoined()
			for i=1,creditstorefund do GAMESTATE:ApplyGameCommand("insertcredit") end
		end
		PrepareScreen("UnjoinPlayers") DeletePreparedScreens()
	else
		--put sm5 code here
	end
end

--[[
math.mod = sawtooth
math.abs = V

   __
  /  \
_/    \_


math.min(1,
3*(1.5-math.abs(self:GetSecsIntoEffect()-1.5))


3*(math.abs(hueR-


)


math.abs(hue

RYGCBP
======
RR   R
 GGG
   BBB

r5 b3 g1


clamp(h*3,0,1)

0 r
1 y
2 g
3 c
4 b
5 p

hue = math.mod(hue,6)


math.abs(hue

math.mod(h,6)-3


--]]
