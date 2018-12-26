local tnsindex={
	TapNoteScore_W1=0,
	TapNoteScore_W2=1,
	TapNoteScore_W3=2,
	TapNoteScore_W4=3,
	TapNoteScore_W5=4,
	TapNoteScore_Miss=5
}

local jts={x=1.2, y=1.3}
local basezoom=.75

local pn=lua.GetThreadVariable("Player")

return Def.ActorFrame{ Def.Sprite{ --NOTE: for whatever reason, the judge sprite only works correctly inside an actorframe
	Texture=THEME:GetPathG("","_Judge Fonts/Default"),
	InitCommand=cmd(animate,false;diffusealpha,0;aux,self:GetNumStates();basezoom,basezoom),
	ResetCommand=cmd(finishtweening),

	JudgmentMessageCommand=function(s,p) --NOTE: This message is a broadcast- check the pn
		local tns=tnsindex[p.TapNoteScore]
		if p.Player==pn and not p.HoldNoteScore and tns then
			--there are 6 or 12 possible (0-indexed) states. even states are early, odd states are late.
			local numstates=s:getaux()

			s:setstate(numstates/6*tns+(numstates>6 and not p.Early and 1 or 0))

			--judge tween:

			s:stoptweening() s:diffusealpha(1)
			s:zoomx(jts.x) s:zoomy(jts.y) s:decelerate(1/30) s:zoom(1)
			s:sleep(.6) s:accelerate(.25) s:diffusealpha(0) s:zoom(0.25)
		end
	end
}}
