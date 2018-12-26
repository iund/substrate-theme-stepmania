
function UIColor(objname,bright)
	local color=GetSysConfig().Colour or "default"
	local cols=UIColors[UIColors[color] and color or "default"][objname]
	--assert(cols,objname.." "..color..table.dump(UIColors))
	local out={}
	local b=bright or 1
	for i,c in next,cols,nil do out[i]=i==4 and 1 or c*b end
	return out
end

--function PlayerColor(pn) return PlayerColors[GetProfile(pn).Colour] or {.75,.75,.75,1} end
function PlayerColor(pn,bright) local pcols=PlayerColors[GetProfile(pn).Colour] or {.75,.75,.75,1} local out={} for i,c in next,pcols,nil do out[i]=i==4 and 1 or c*(bright or 1) end return out end
function PlayerTextColor(pn,bright) local pcols=PlayerTextColors[GetProfile(pn).Colour] or {1,1,1,1} local out={} for i,c in next,pcols,nil do out[i]=i==4 and 1 or c*(bright or 1) end return out end

--TODO: colours for white and black text objects
--also Todo: RGB colour sliders (or pick a hue?)
function SetPlayerColour(pn,c) GetProfile(pn).Colour=c end

function GetPlayerColorList()
	local out={}
	for c,_ in next,PlayerColors,nil do out[table.getn(out)+1]=c end
	return out
end


--[[

Colour={
	HSLtoRGB=function(h,s,l)
	--hue, saturation, luminosity
	
	--max L = all white
	
	
	
	clamp(v,0,1)

		
		math.mod(v,1)-0.5
	
	
	
		return r,g,b
	end
function 





for v=0,5,0.1 do
	local i=math.mod(v,1)-0.5
	print(string.format("%.1f",i))
end




----


n = wrap


v = input




same:				-n < v < n

inverted:		n < v+n < 3*n

for v=0,5,0.1 do
print( math.sin(math.pi/4) - 0.5 )


--]]
