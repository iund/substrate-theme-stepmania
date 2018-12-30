local screenname=lua.GetThreadVariable("LoadingScreen")

local env={}

local function updatestyles()
	local game=GAMESTATE:GetCurrentGame():GetName()
	local styles=GAMEMAN:GetStylesForGame(game)

	local stepstypestohide=split(",",THEME:GetMetric("Common","StepsTypesToHide"))

	for i=1,#stepstypestohide do
		-- eg; "dance-single" -> "StepsType_Dance_Single". Remove all extraneous stepstypes I don't want like "threepanel" or "couple-edit"
		local parts=split("-",stepstypestohide[i])
		stepstypestohide[i]=string.format("StepsType_%s_%s",
			string.capitalize(parts[1]),string.capitalize(parts[2]))
	end

	env.styles={}

	--Rebuild the valid styles list
	env.curstyleindex=1
	for i=1,#styles do
		local style=styles[i]
		if not table.find(stepstypestohide,style:GetStepsType()) then --yeah; why is solo there?
			local styletype=style:GetStyleType()
				if	GAMESTATE:GetNumPlayersEnabled()==1 and
					(styletype=="StyleType_OnePlayerOneSide"
					or styletype=="StyleType_OnePlayerTwoSides" and (GAMESTATE:EnoughCreditsToJoin() or GetPref("Premium")=="Premium_DoubleFor1Credit"))
				or GAMESTATE:GetNumPlayersEnabled()==2 and styletype=="StyleType_TwoPlayersTwoSides"
			then
				env.styles[#env.styles+1]=style
			end
			if GAMESTATE:GetNumPlayersEnabled()==2 and style:GetName()=="versus" then --default to versus
				env.curstyleindex=#env.styles
			end
		end
	end
	Broadcast("StylesUpdated")
end
local input
input=function(attr)
	if attr.type=="InputEventType_FirstPress" then
		local pn=attr.PlayerNumber
		if attr.GameButton=="Start" then --is side joined? Use player functions, because Double might mean both sides.
			if not GAMESTATE:IsPlayerEnabled(pn) and GAMESTATE:EnoughCreditsToJoin() then
				SCREENMAN:PlayStartSound()
				GAMESTATE:JoinPlayer(pn) --not JoinInput (does nothing without style set)
				Broadcast("RefreshCreditText")
				updatestyles()
			elseif GAMESTATE:IsPlayerEnabled(pn) then
				SCREENMAN:PlayStartSound()
				GetScreen():StartTransitioningScreen("SM_GoToNextScreen")
			end
--[[
		elseif attr.GameButton=="Select" and GAMESTATE:IsPlayerEnabled(pn) and GAMESTATE:GetNumPlayersEnabled()>1 then
			GAMESTATE:UnjoinPlayer(pn)
			SCREENMAN:PlayCancelSound()
			Broadcast("RefreshCreditText")
			updatestyles()
--]]
		elseif attr.GameButton=="MenuLeft" and GAMESTATE:IsPlayerEnabled(pn) then
			env.curstyleindex=clamp(env.curstyleindex-1,1,#env.styles)
			Broadcast("MoveSelection")
		elseif attr.GameButton=="MenuRight" and GAMESTATE:IsPlayerEnabled(pn) then
			env.curstyleindex=clamp(env.curstyleindex+1,1,#env.styles)
			Broadcast("MoveSelection")
		elseif attr.GameButton=="Back" then --Handle back. Clean up then leave the screen.
			GetScreen():StartTransitioningScreen("SM_GoToPrevScreen")
		end
	end
end

local out=Def.ActorFrame {
	LoadActor(THEME:GetPathB(THEME:GetMetric(screenname,"Fallback"),"overlay")),

	OnCommand=function(s)
		GetScreen():AddInputCallback(input)
		--Then set-up env variables to help keep track of styles.
		local env=GAMESTATE:Env()
		env.PlayerEntry={}
		updatestyles()
	end,

	OffCommand=function(s)
		GAMESTATE:SetCurrentStyle(env.styles[env.curstyleindex]:GetName()) --Make sure style is set before entering SelectMusic.
		GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
		--clean up
		GetScreen():RemoveInputCallback(input)
	end,

	CoinInsertedMessageCommand=function(s)
		Broadcast("RefreshCreditText")
		updatestyles()
	end,

	MoveSelectionMessageCommand=function(s)
		SOUND:PlayOnce(THEME:GetPathS(screenname,"change"))
	end

}


for pi,pn in next,{PLAYER_1,PLAYER_2},nil do
	local startprompttext,joinprompttext
	out[#out+1]=Def.ActorFrame {
		InitCommand=function(s)
			s:x(SCREEN_CENTER_X+(pi*2-3)*SCREEN_WIDTH/4)
			s:y(SCREEN_CENTER_Y)
		end,

--[[ NOTE: Commented out since itg's effectclock is broken and we want parity between itg and SM5 themes.
			OnCommand=cmd(SetUpdateFunction,function(s)
			startprompttext:UpdateDiffuseCos(.5)
			joinprompttext:UpdateDiffuseCos(.5)
		end),
--]]
		Def.ActorFrame { --joined
			PlayerJoinedMessageCommand=function(s,p) s:playcommand("SetVisibility") end,
			PlayerUnjoinedMessageCommand=function(s,p) s:playcommand("SetVisibility") end,
			SetVisibilityCommand=cmd(visible,GAMESTATE:IsPlayerEnabled(pn)),
			InitCommand=cmd(playcommand,"SetVisibility"),

			LoadActor("pane/joined")..{
				InitCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha;diffusecolor,unpack(UIColors["PlayerEntryPaneJoined"]))
			},
			Def.BitmapText { --Player name
				Font="_common white",
				InitCommand=cmd(y,-168;shadowlength,0;zoom,3/2),
				RefreshCreditTextMessageCommand=cmd(playcommand,"SetText"),
				SetTextCommand=cmd(settext,GetPlayerName(pn))
			},
			Def.BitmapText {
				Font="_common white",
				InitCommand=cmd(y,-120;zoom,5/4;shadowlength,0),
				Text="Play mode:"
			},
			Def.ActorFrame { --Selector
				InitCommand=cmd(y,-64),
				LoadActor("pane/selector/box")..{
				},
				LoadActor("../../Graphics/_arrow left")..{
					TweenCommand=cmd(stoptweening;zoom,1;decelerate,0.2;zoom,.75),
					InitCommand=cmd(x,-90;zoom,0.75),
				},
				LoadActor("../../Graphics/_arrow right")..{
					TweenCommand=cmd(stoptweening;zoom,1;decelerate,0.2;zoom,.75),
					InitCommand=cmd(x,90;zoom,0.75),
				},
				Def.BitmapText {
					OnCommand=cmd(zoom,3/2;shadowlength,0;playcommand,"SetText"),
					Font="_common black",
					SetTextCommand=function(s)
						local style=env.styles[env.curstyleindex]
						s:settext(string.capitalize(style:GetName())) --TODO l10n
					end,
					MoveSelectionMessageCommand=cmd(playcommand,"SetText"),
					StylesUpdatedMessageCommand=cmd(playcommand,"SetText")
				}
			},
			Def.ActorFrame { --Platforms
				OnCommand=cmd(playcommand,"SetStyle"),
				StylesUpdatedMessageCommand=cmd(playcommand,"SetStyle"),
				MoveSelectionMessageCommand=cmd(playcommand,"SetStyle"),
				SetStyleCommand=function(s)
					local st=env.styles[env.curstyleindex]:GetStyleType()
					s:RunCommandsOnChildren(function(s) s:stoptweening() s:playcommand(st) end)
				end,
				LoadActor("../../Graphics/_platform small")..{ --this side (always visible)
					InitCommand=cmd(aux,pi;y,32;diffusealpha,1;playcommand,"PlayerEntrySetActiveColour"),
					OnCommand=cmd(playcommand,"PanelsShow";playcommand,env.styles[env.curstyleindex]:GetStyleType();finishtweening),
					StyleType_OnePlayerOneSideCommand=cmd(sleep,0.3;decelerate,0.3;x,0),
					StyleType_OnePlayerTwoSidesCommand=cmd(decelerate,0.3;x,(pi*2-3)*54),
					StyleType_TwoPlayersTwoSidesCommand=cmd(playcommand,"StyleType_OnePlayerTwoSides")
				},
				LoadActor("../../Graphics/_platform small")..{ --other side - double
					InitCommand=cmd(aux,pi==1 and 2 or 1;y,32;x,(pi*2-3)*-54;playcommand,"PlayerEntrySetActiveColour"),
					OnCommand=cmd(playcommand,"PanelsHide";playcommand,env.styles[env.curstyleindex]:GetStyleType();finishtweening),

					StyleType_OnePlayerOneSideCommand=cmd(playcommand,"PadFadeOut";playcommand,"PanelsHide"),
					StyleType_OnePlayerTwoSidesCommand=cmd(playcommand,"PadFadeInDelayed";playcommand,"PanelsShowDelayed"),
					StyleType_TwoPlayersTwoSidesCommand=cmd(playcommand,"PadFadeOut";playcommand,"PanelsHide")
				},
				LoadActor("../../Graphics/_platform dark small")..{ --other side - versus
					InitCommand=cmd(y,32;x,(pi*2-3)*-54;diffusealpha,0;diffusecolor,unpack(UIColors["PlayerEntryPanePlatformInactive"])),
					StyleType_OnePlayerOneSideCommand=cmd(accelerate,0.3;diffusealpha,0),
					StyleType_OnePlayerTwoSidesCommand=cmd(accelerate,0.3;diffusealpha,0),
					StyleType_TwoPlayersTwoSidesCommand=cmd(sleep,0.3;decelerate,0.3;diffusealpha,1)
				},
			},
			Def.BitmapText { --Guide text
				Font="_common white",
				InitCommand=cmd(y,152;shadowlength,0;zoom,5/4;effectclock,"beat";playcommand,"SetText"),
				SetTextCommand=function(s)
					startprompttext=s
					s:settext(string.format("Press &START; to play\na %d player game",GAMESTATE:GetNumPlayersEnabled()))
				end, --TODO l10n
				RefreshCreditTextMessageCommand=cmd(playcommand,"SetText")
			},
			Def.BitmapText { --Coin prompt
				Font="_common white",
				RefreshCreditTextMessageCommand=cmd(effectclock,"beat";playcommand,"SetText"),
				InitCommand=cmd(y,98;shadowlength,0;zoom,.75),
				SetTextCommand=function(s)
					joinprompttext=s
					local coins=GAMESTATE:GetCoinMode()=="CoinMode_Pay" and GAMESTATE:GetPremium()=="Premium_Off" and GetPref("CoinsPerCredit")-GAMESTATE:GetCoins() or 0
					s:settext(coins>0 and string.format("Insert %d more %s to select Double",coins,coins~=1 and "coins" or "coin") or "") --TODO l10n
				end
			}
		},
		Def.ActorFrame { --unjoined
			PlayerJoinedMessageCommand=function(s,p) s:playcommand("SetVisibility") end,
			PlayerUnjoinedMessageCommand=function(s,p) s:playcommand("SetVisibility") end,
			SetVisibilityCommand=cmd(visible,not GAMESTATE:IsPlayerEnabled(pn)),
			InitCommand=cmd(playcommand,"SetVisibility"),

			LoadActor("pane/unjoined")..{
				InitCommand=cmd(diffusealpha,CommonPaneDiffuseAlpha;diffusecolor,unpack(UIColors["PlayerEntryPaneUnjoined"])),
			},
			Def.BitmapText {
				Font="_common white",
				OnCommand=cmd(shadowlength,0;zoom,5/4;playcommand,"SetText"),
				SetTextCommand=function(s)
					local coins=GAMESTATE:GetCoinsNeededToJoin()-GAMESTATE:GetCoins()
					s:settext(
						coins<1 and "Press &START; to join" --TODO l10n
						or string.format("Insert %d more %s\nto join", coins, coins~=1 and "coins" or "coin") --TODO l10n
					)
				end,
				RefreshCreditTextMessageCommand=cmd(playcommand,"SetText")
			}
		}
	}
end
return out
