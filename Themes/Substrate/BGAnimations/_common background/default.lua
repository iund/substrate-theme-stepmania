local spriteattribs={}
local function coinanimation(s) s:finishtweening() local z=s:GetZoom() s:zoom(z*1.75) s:decelerate(0.45) s:zoom(z) end
local function init(s)
	local i=#spriteattribs
	local zoom=randomrange(0.5,2)

	local basew=s:GetWidth() --64
	local baseh=s:GetHeight() --64
	local w=basew*zoom
	local h=baseh*zoom

	s:blend("add") s:horizalign("center") s:vertalign("middle")

	local colorval=function(color) return math.mod(math.floor(i/4),3)==color and 0.1 or 0.05 end
	s:diffuse(colorval(0),colorval(1),colorval(2),1)

	local x=randomrange(-w/2,SCREEN_WIDTH+w/2)
	local y=randomrange(-h/2,SCREEN_HEIGHT+h/2)

	s:rotationz(90*math.mod(i,4)) s:zoom(zoom) s:finishtweening()

	spriteattribs[i+1]={
		self=s,
		x=x, y=y,
		xv=randomrange(-100,100), yv=randomrange(-20,-100),
		w=w/2, h=h/2,
	}
end
local out=Def.ActorFrame {
	OnCommand=function(s)
		s:effectperiod(math.huge)
		s:effectclock("music")
		s:SetUpdateFunction(function(r) --manual particle layer update (this runs on every frame so be efficient!)
			local sw=SCREEN_WIDTH
			local sh=SCREEN_HEIGHT
			local w=wrap
			local d=clamp(r:GetEffectDelta(),0,1/30)
			for _,o in next,spriteattribs,nil do
				local s=o.self
				o.x=w(o.x+(d*o.xv),-o.w,sw+o.w)
				o.y=w(o.y+(d*o.yv),-o.h,sh+o.h)
				s:x(o.x) s:y(o.y)
			end
		end)
	end
}

for i=1,12 do
	out[i]=Def.Sprite {
		Texture="arrow.png",
		InitCommand=init,
		CoinInsertedMessageCommand=coinanimation,
	}
end
return out
