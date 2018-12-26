--Per column tap/mine judge detection

NoteField={
	Init=function(s) --edit bar sprites
		receptors={}
		judgecounts={} for pn=1,2 do judgecounts[pn]={} for col=1,8 do judgecounts[pn][col]={} for j=1,10 do judgecounts[pn][col][j]=0 end end end
	end
}

Noteskin={
	InitReceptor=function(s) --starts from leftmost column, usually Left.
		--Assign neg col values for player 1, and pos vals for p2, to aux.
--[[
		local cursteps=CurSteps(Player(1) and 1 or 2)
		local cols=cursteps and StepsTypesNumLanes[cursteps:GetStepsType()+1] or 4 --assume 4
		local pn=math.floor(table.namedgetn(receptors)/cols)+(Player(1) and 1 or 2)
		local col=math.mod(table.namedgetn(receptors),cols)+1

		Trace("PN="..pn)
		Trace("Col="..col)

		receptors[s]=col

		s:aux(pn==1 and -col or col) s:finishtweening()
--]]
	end,
	ReceptorTween=function(s,j) --judge values: 0=none, 1-6=fantastic - miss, 9=mine hit, 10=mine miss
		--BUG: This doesn't run on miss. Why?
		
--		ScreenMessage("Noteskin.ReceptorTween("..j..")")

		s:z(1) s:finishtweening() if j<6 then s:zoom(0.75) s:linear(0.1) s:zoom(1) end

--[[
		local aux=s:getaux() if aux==0 or j==0 then return end

		local pn=aux<0 and 1 or 2
		local col=math.abs(s:getaux())

		judgecounts[pn][col][j]=judgecounts[pn][col][j]+1
--]]
	end
}
