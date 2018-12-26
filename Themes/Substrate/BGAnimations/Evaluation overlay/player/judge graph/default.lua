return Def.ActorFrame {
	Def.Actor {
		OnCommand=%function(s) Capture.ActorFrame.ApplyPNToChildren(s,s:getaux()) end,
		CaptureCommand=%Capture.ActorFrame.CaptureInternal,
	},
	LoadActor("judgegraph")..{
	},
}