return Def.ActorFrame {
	LoadActor("pane")..{
		OnCommand=function(s) Actor.xy(s,unpack(Metrics.EditMenu.PaneXY)) end,
	},
	LoadActor("highlight")..{
		MoveHighlightMessageCommand=function(s) s:y(TopScreen:GetChild("EditMenu"):GetChild(""):GetY()) end,
		OnCommand=function(s) s:x(Metrics.EditMenu.HighlightX) s:y(Metrics.EditMenu.RowStartY) end,
	},
}