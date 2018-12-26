MenuTimerWarn=function(s)
	local val=tonumber(s:GetText())

	s:finishtweening()
	if val and val<=15 then
		local z=s:GetZoom()
		s:zoom(z*1.2) s:linear(0.3) s:zoom(z)
		
		s:diffuseblink()
		local m=val/15
		s:effectperiod(m)
		s:effectcolor1(1,1,1,1)
		s:effectcolor2(1,m,m,1)
	elseif val==0 then
		s:stopeffect()
	end
end


Sweep={ --Shared tween lateral slide-in for most actors
	In=function(s,pn) local dir=(pn-1.5)*2 s:addx(dir*SCREEN_WIDTH/2) s:decelerate(0.5) s:addx(-dir*SCREEN_WIDTH/2) end,
	Out=function(s,pn) local dir=(pn-1.5)*2 s:stoptweening() s:accelerate(0.5) s:addx(dir*SCREEN_WIDTH/2) end,

	InCenter=function(s,dir) s:addy(dir*SCREEN_HEIGHT/2) s:decelerate(0.5) s:addy(-dir*SCREEN_HEIGHT/2) end,
	OutCenter=function(s,dir) s:stoptweening() s:accelerate(0.5) s:addy(dir*SCREEN_HEIGHT/2) end,
}
