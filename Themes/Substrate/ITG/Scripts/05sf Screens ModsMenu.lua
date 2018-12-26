Screens.ModsMenu={
		On=function(s) 
		end,
		FirstUpdate=function(s)
			ForeachPlayer(function(pn)
				if cursors[pn] then
					local cs=cursors[pn]
					for _,c in next,cs.children,nil do
						c:diffuseshift()
						c:effectcolor1(1,1,1,1)
						c:effectcolor2(1,1,1,.9)
						c:effectclock('beat')
					end
				end
				
				linehighlights[pn]:zoom(-(pn*2-3))
				linehighlights[pn]:x((pn*2-3)*56)
			end)
			Env().SelectedTab=nil
		end,
		Alarm=function()
			SetScreen(Branch.SelectMusicNext())
		end
	}
