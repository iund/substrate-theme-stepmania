local labeloffset=28

--TODO make these configurable:
local zoombase=0.5
local zoomfactor=1.1

local tween=function(s,fade,zb)
	s:stoptweening()
	s:diffusealpha(fade) -- Fade in combo from "3 combo"
	s:zoom(zoomfactor*zb) s:decelerate(1/30) s:zoom(zb)

	s:sleep(.6) s:accelerate(.25) s:diffusealpha(0) s:zoom(0.25)
end
local colours=ComboColours
local colorapply=function(c,n)
	c:diffusecolor(1,1,1,1)
	c:diffuseshift()
	c:effectcolor1(unpack(colours[1][n]))
	c:effectcolor2(unpack(colours[2][n]))
	c:effectperiod(0.8)
end
local colorcancel=function(c,n)
	c:stopeffect()
	local red=n==6 and 0 or 1
	c:diffusecolor(1,red,red,1) --miss
end

local number,combolabel,misseslabel
local worstjudge=1

local setcombo=function(s,p)
	if p.Combo then
		number:settext(tostring(p.Combo))

		combolabel:visible(true)
		misseslabel:visible(false)
	
		worstjudge=4
		for i=4,1,-1 do
			if p["FullComboW"..tostring(i)] then
				worstjudge=i
			end
		end

		if worstjudge<=3 then
			colorapply(number,worstjudge)
			colorapply(combolabel,worstjudge)
		else
			colorcancel(number,worstjudge)
			colorcancel(combolabel,worstjudge)
		end

		tween(number,math.min(10,p.Combo)/10,zoombase)
		tween(combolabel,math.min(10,p.Combo)/10,1)

	elseif p.Misses then
		number:settext(tostring(p.Misses))

		combolabel:visible(false)
		misseslabel:visible(true)

		colorcancel(number,6)
		colorcancel(misseslabel,6)

		tween(number,math.min(10,p.Misses)/10,zoombase)
		tween(combolabel,math.min(10,p.Misses)/10,1)

	else
		--zero combo, ie on the first song
		number:settext("")

		combolabel:visible(false)
		misseslabel:visible(false)
	end

end

return Def.ActorFrame{
	ComboMessageCommand=setcombo,
	Def.BitmapText{
		Font="Combo numbers",
		InitCommand=function(s) number=s end,
	},
	Def.Sprite{
		Texture="Combo label",
		InitCommand=function(s) combolabel=s s:y(labeloffset) end,
	},
	Def.Sprite{
		Texture="Combo misses",
		InitCommand=function(s) misseslabel=s s:y(labeloffset) end,
	},
}
