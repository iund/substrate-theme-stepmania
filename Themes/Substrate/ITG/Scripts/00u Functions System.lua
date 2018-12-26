---System
function CurLanguage() return Languages[GetPref("Language")] and GetPref("Language") or "english" end
function IsArcade() return GetSysConfig().ForceArcadeMode or SM_VERSION==3.95 and not GetPref("AllowOldKeyboardInput") end --AllowOldKeyboardInput is only used for onscreen keyboard in ScreenTextEntry (popup keyboard in edit menu)
function IsPS2() return not not AnyControllersAreConnected end
function GetArchName() return (not not GetPref('LastSeenMemory')) and 'windows' or IsArcade() and 'arcade' or IsPS2() and 'ps2' or 'unix' end

function IsSelectButtonAvailable() return GetPref("BreakComboToGetItem") and true end
function IsBackShortcutEnabled() return GetPref("TexturePreload") and true end
function IsMenuDpadAvailable() return GetPref("LightsChartsInMenus") and true end

function CreditTextChangedEvent(s)
	--Center the credit text on the attract
	local coins=GAMESTATE:GetCoins()
	if System.Coins~=coins then print('coins changed '..coins-System.Coins) System.Coins=coins end

	s:x(
		(IsAnyPlayerUsingMemoryCard() or SystemOverlay.CreditText[1]:GetText()~=SystemOverlay.CreditText[2]:GetText())
		and Metric('SystemOverlay','CreditsP'..s:getaux()..'X')
		or SCREEN_CENTER_X
	)

end


function IsArcadeInitialised()
	local descriptions=INPUTMAN:GetDescriptions()
	return
		--arcade drivers: (GetInputType's behaviour has changed in newest builds and it's not clear if P3IO/MM appears there)
		GetInputType and GetInputType()~=""
		or table.find(descriptions,"PIUIO")
		or table.find(descriptions,"ITGIO")
		or table.find(descriptions,"P3IO")
		or table.find(descriptions,"MiniMaid")
		--in case some people are using jpac for input
		or table.find(descriptions,"Keyboard") and string.find(GetPref('InputDrivers'),"X11")
end

--I could just use GAMESTATE:GetCoinsNeededToJoin()
function GameState.GetCoinsNeeded(GAMESTATE)
	local sides=GAMESTATE:GetNumSidesJoined()
	return (GAMESTATE:GetCoinMode()~=COIN_MODE_PAY or sides==2 or GetPref("EventMode") or GAMESTATE:GetPremium()==PREMIUM_JOINT and sides>0) and 0
	or math.max(0,GetPref("CoinsPerCredit")-GAMESTATE:GetCoins())
end

function AttractCreditText()
	--Gamestate's coin mode gives you "free play" if temp event is enabled. Read pref instead for the correct value.
	local cm=GetPref("CoinMode") --GAMESTATE:GetCoinMode()
	return 
		GetPref("EventMode") and Languages[CurLanguage()].SystemOverlay.CreditText.EventMode
		or cm==COIN_MODE_HOME and Languages[CurLanguage()].SystemOverlay.CreditText.PressStart
		or cm==COIN_MODE_PAY and GetPref("CoinsPerCredit")>0 and (
			math.mod(GAMESTATE:GetCoins(),GetPref("CoinsPerCredit"))>0
			-- Credits: 0 (1/2)
			and sprintf(Languages[CurLanguage()].SystemOverlay.CreditText.CreditsCoins, 
				GAMESTATE:GetCoins()/GetPref("CoinsPerCredit"),
				math.mod(GAMESTATE:GetCoins(),GetPref("CoinsPerCredit")), GetPref("CoinsPerCredit"))
			-- Credits: 1
			or sprintf(Languages[CurLanguage()].SystemOverlay.CreditText.Credits, GAMESTATE:GetCoins()/GetPref("CoinsPerCredit"))
		)
		-- Freeplay
		--or cm==COIN_MODE_FREE and 
		or Languages[CurLanguage()].SystemOverlay.CreditText.FreePlay
		or "AttractCreditText() - fix this bug"
end

function InsertCoinText()
	--"Insert 2 coins" / "Press Start"
	local coinsneeded=GAMESTATE:GetCoinsNeeded() --(GetPref("EventMode") or GetPref("CoinMode")~=COIN_MODE_PAY) and 0 or math.max(0,GetPref("CoinsPerCredit")-GAMESTATE:GetCoins())
	return coinsneeded<1 and Languages[CurLanguage()].Attract.PressStart
	or sprintf(Languages[CurLanguage()].Attract.InsertCoins,coinsneeded,Languages[CurLanguage()].Attract[coins~=1 and "Coins" or "Coin"]) or ""
end

function RefreshCardText(s,pn) if not Player(pn) or GetEnv("ProfileLoaded") and not UsingUSB(pn) then s:settext("") end end
