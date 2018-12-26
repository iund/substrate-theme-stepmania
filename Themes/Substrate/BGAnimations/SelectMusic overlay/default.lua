return Def.ActorFrame{
        LoadActor(THEME:GetPathB(THEME:GetMetric("SelectMusic","Fallback"),"overlay")),

	Def.BitmapText {
		Font="_common bordered white",
		InitCommand=cmd(zoom,.75;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-88),
		OnCommand=function(s) 
--			local rate=GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate()
--			s:settext(rate~=1 and string.format("%1.1fx",rate) or "")
			s:settext(GAMESTATE:GetSongOptionsString())

		end
	},

	LoadActor("help popup")..{
		Condition=GAMESTATE:GetCurrentStageIndex()==0 and not GAMESTATE:IsAnyHumanPlayerUsingMemoryCard(),
		InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y)
	},
	
	Def.BitmapText {
		Font="_common white",
		OnCommand=cmd(shadowlength,0;zoom,.75;diffusealpha,0;finishtweening;
			x,SCREEN_CENTER_X;y,SCREEN_BOTTOM-12;settext,
			"&MENULEFT; Easier     &START; Change sort     &MENURIGHT; Harder"), --TODO L10n
		SelectMenuOpenedMessageCommand=cmd(stoptweening;linear,0.15;diffusealpha,1),
		SelectMenuClosedMessageCommand=cmd(stoptweening;linear,0.15;diffusealpha,0)
	}
}
--[[# upon BeginScreen:
OptionsMenuAvailable=true
ShowOptionsMessageSeconds=3
#eval on use:

return Def.ActorFrame{




}
#screen commands:
#"ShowEnteringOptions" upon hit start (ie, "Press START again for options" prompt)
#"ShowPressStartForOptions"
#"HidePressStartForOptions" - see above

#"SortChange"

#"unchoose" steps:
#"StepsUnchosen" message, with params: "Player"=pn

#Select+whatever button listener:
#"SelectMenuInput" message + params: "Player"=pn, "Button"=(game button string)

#when scrolling wheel: "PreviousSong"/"NextSong" messages

#when cycling groups: "PreviousGroup"/"NextGroup" messages

#two-part confirm: "TwoPartConfirmCanceled" message (when cancelling via change song/difficulty/group)

#"SongChosen" message (no params) when song selected (but still awaiting difficulty?)
#"SongUnchosen" message: params- Player

#"StepsChosen" msg + param "Player"

#mods codes via CodeDetector: "PlayerOptionsChanged" msg: params = PlayerNumber ; "SongOptionsChanged" msg

#select button update: "SelectMenuOpened" / "SelectMenuClosed" msg + param "Player"



#Change steps event: Message msg( "ChangeSteps" ); msg.SetParam( "Player", pn ); msg.SetParam( "Direction", dir );

#late join via Message_PlayerJoined: param - "Player"



#Lua calls: ScreenSelectMusic.
#	GetGoToOptions	if start pressed again and we're about to enter mods menu
#	GetMusicWheel	get musicwheel data??
#	OpenOptionsList	manually open OptionsList
#	CanOpenOptionsList	self explan
--]]
