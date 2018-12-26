Tweens.MenuTimer = {
		On = function(s,i)
			if i==2 then s:visible(Bool[false]) end
			
			s:shadowlength(0)
			s:horizalign("right")
		end,
		Warning=function(s)
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
	
	}
