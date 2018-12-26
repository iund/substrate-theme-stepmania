local input
return Def.ActorFrame {
	ReadyCommand=function(s) GetScreen():AddInputCallback(input) end,
	HideAllCommand=cmd(visible,false),
	OnCommand=function(s)
		input=function(attr)
			s:playcommand("TweenOut") s:sleep(1) s:queuecommand("HideAll")
			GetScreen():RemoveInputCallback(input)
		end
		s:sleep(0.5) s:queuecommand("TweenIn") s:queuecommand("Ready")
	end,

	Def.Quad {
		InitCommand=cmd(zoomto,256,96;clearzbuffer,1;blend,"noeffect";zwrite,1),
	},
	LoadActor("box")..{
		InitCommand=cmd(ztestmode,"writeonfail";y,-96;diffuse,unpack(UIColors["SelectMusicHelpPopup"])),
		TweenOutCommand=cmd(stoptweening;accelerate,0.5;y,-96),
		TweenInCommand=cmd(decelerate,0.5;y,0),
	},
	Def.BitmapText {
		InitCommand=cmd(shadowlength,0;ztestmode,"writeonfail";y,-96;diffuseshift;effectcolor1,1,1,1,1;effectcolor2,1,1,1,0.75;effectclock,"beat"),
		Font="_common semibold white",
		TweenOutCommand=cmd(stoptweening;accelerate,0.5;y,-96),
		Text="Pick a song using &MENULEFT; or &MENURIGHT;\nthen press &START; to play",
		TweenInCommand=cmd(decelerate,0.5;y,0),
	},
}
