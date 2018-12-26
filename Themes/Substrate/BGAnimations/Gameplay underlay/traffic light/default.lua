--NOTE: Lazily converted with a script then cleaned up - it's not this messy everywhere else!!

return Def.ActorFrame {
	Def.Sprite{
		Texture="frame",
		OnCommand=cmd(diffusealpha,0.75), --TODO: control with UIColors
	},
	LoadActor("component")..{
		InitCommand=cmd(aux,0;y,-96),
		NoteCrossedMessageCommand=cmd(playcommand,"Flash"),
	},
	LoadActor("component")..{
		InitCommand=cmd(aux,1;y,-32),
		NoteWillCrossIn400MsMessageCommand=cmd(playcommand,"Flash"),
	},
	LoadActor("component")..{
		NoteWillCrossIn800MsMessageCommand=cmd(playcommand,"Flash"),
		InitCommand=cmd(aux,2;y,32),
	},
	LoadActor("component")..{
		InitCommand=cmd(aux,3;y,96),
		NoteWillCrossIn1200MsMessageCommand=cmd(playcommand,"Flash"),
	},
}