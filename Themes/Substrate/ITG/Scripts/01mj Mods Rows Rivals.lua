--------------------------------
-- Rival mods menu page
--------------------------------

--Select rival:

--Mods Menu functions:
RowType.RivalList=function(name,updaterow)
	local handler = {
		getchoices = function(pn)
			--[[
		
				Returns a table of format:
					None
					Self
					Opponent
					(list of rivals)
		
				TODO: Add machine best
				TODO: Add quad option (will need work mind you)
		
			--]]
		
			local rivals=GetProfile(pn).Rival.Profiles or {}
			--local rivals=GetProfile(pn).Rival.Profiles or {}
			local insert=table.insert

			local list={"None","Self"} --TODO lang strings for these choices

	--		local otherpn=math.mod(pn,2)+1
	--		if Player(otherpn) then insert(list,PlayerName(otherpn).." (opponent)") end
			--List of rivals
			for r,e in next,rivals,nil do insert(list,e.Name) end
			return list
		end, --function(pn) assert(pn) return Rival.GetNames(pn) end,		
		get = function(r,pn) --Get index to Rival.GetNames(pn) table.
			return (CurRival[pn] and CurRival[pn].UUID and (
				CurRival[pn].UUID==GetProfile(pn).UUID and 0 or
				Rival.FindUUID(GetProfile(pn).Rival.Profiles,CurRival[pn].UUID)) or -1
				)+2
		end,
		set = function(r,pn,i)
			local rivals=GetProfile(pn).Rival.Profiles

			--[[
			local otherpn=math.mod(pn,2)+1
			local namesoffset=Player(otherpn) and 2 or 1
		
			local rival=Rival.GetNames(pn)[i]
			CurRival[pn]=i>namesoffset and i-namesoffset
			--]]
			local self=GetProfile(pn) --only UUID is read

			CurRival[pn]=i>2 and rivals[i-2] or i==2 and self or nil
		
			--CurRival[pn]=i>1 and rivals[i-1] or nil --Off + List of rivals

			GetProfile(pn).Rival.Current=CurRival[pn] and CurRival[pn].UUID or false

			if updaterow then ModsMenu.UpdateInfoLine(r,pn,updaterow) end
		end
	}
	local r=RowType.UnsharedListBase(name,handler)
--	local r=RowType.ListBase(name,handler,false,true,false)

	r.EnabledForPlayers={}
--	if not GetEnv("CrippledProfiles") then --keep the rival picker greyed out on builds that throw away the profile lua table on load
		ForeachPlayer(function(pn)
			if UsingUSB(pn) then table.insert(r.EnabledForPlayers,pNum[pn]) end
		end)
--	end
	return r
end

--Select Most recent / best:
RowType.RivalGhostType=function(name)
	assert(false,"TODO")
end

RowType.Rival={
	GhostInfoPlayer=function(name)
		local handler={
			gettext=function(pn)
				return Rival.GetScoreSelf(pn) or "no data"
			end,
		}
		return RowType.Info(name,handler)
	end,

	GhostInfoRival=function(name)
		local handler={
			gettext=function(pn)
				return Rival.GetScore(pn) or "no data"
			end,
		}
		return RowType.Info(name,handler)
	end
}
