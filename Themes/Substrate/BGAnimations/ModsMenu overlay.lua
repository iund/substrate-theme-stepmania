return Def.ActorFrame{
	OnCommand=function(s)
		SOUND:PlayOnce(THEME:GetPathS("Options","open"))
	end,
	LoadActor(THEME:GetPathB(THEME:GetMetric("ModsMenu","Fallback"),"overlay")),
	ModsMenu(ModsMenuEntries())
}
