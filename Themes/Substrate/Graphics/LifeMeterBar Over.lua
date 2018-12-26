  -- remember, this gets rotated ACW.

local height=THEME:GetMetric("LifeMeterBar","MeterWidth")
return Def.ActorFrame{
	Def.Sprite{
		Texture="LifeMeterBar frame/cap bot",
		OnCommand=cmd(x,-height/2;horizalign,right;diffuse,unpack(UIColors["LifebarCapBottom"]))
	},
	Def.Sprite{
		Texture="LifeMeterBar frame/cap top",
		OnCommand=cmd(x,height/2;horizalign,left;diffuse,unpack(UIColors["LifebarCapTop"]))
	}
}