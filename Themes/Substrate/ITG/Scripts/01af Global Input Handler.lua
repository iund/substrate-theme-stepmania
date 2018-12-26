-- Use with ScreenInputTestOverlay to provide global input messages for any version of oITG.

GlobalInput=(function()
	local inputnames={
		"Left",
		"Right",
		"Up",
		"Down",
		"UpLeft",
		"UpRight",
		"Start",
		"Select",
		"Back",
		"MenuLeft",
		"MenuRight",
		"MenuUp",
		"MenuDown",
		"Insert Coin",
		"Operator",
		
		--notITG extra inputs:
		"BullshitLeft",
		"BullshitRight",
		"BullshitUp",
		"BullshitDown",
		"Action1",
		"Action2",
		"Action3",
		"Action4",
		"Action5",
		"Action6",
		"Action7",
		"Action8",
		"DownLeft",
		"DownRight",
		"Center",
	}
	
	local numinputs=table.getn(inputnames)

	local inputstate={}
	for pn=1,2 do
		inputstate[pn]={}
		for i=1,numinputs do inputstate[pn][i]=false end
	end
	
	local cachedinputstate={}
	for pn=1,2 do
		cachedinputstate[pn]={}
		for i=1,numinputs do cachedinputstate[pn][i]=false end
	end

	return {
		Check=function()
			for pn=1,2 do
				local ispn=inputstate[pn]
				local cispn=cachedinputstate[pn]
				for i=1,numinputs do
					if ispn[i]~=cispn[i] then
						--input was changed
						
						local curstate=ispn[i]
						Broadcast(sprintf("P%d%s%sInput",pn,inputnames[i],curstate and "Press" or "Lift"))
						cispn[i]=curstate
					end
					ispn[i]=false			--clear for the next update
				end
			end
		end,
		
		Add=function(pn,i)
			inputstate[pn][i]=true
		end,
		
		GetInput=function(pn,i) --eg, GetInput(2,15) or GetInput(2,"Operator") would give you P2 Operator's state
			return inputstate[pn][IsString(i) and table.invert(inputnames)[i] or i]
		end,
	}
end)()
