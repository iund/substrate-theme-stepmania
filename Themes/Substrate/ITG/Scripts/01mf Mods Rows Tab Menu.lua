-- Misc

RowType.TabList=function(page,readonly) --tab list for current menu with Back option
	local handler = {
		getchoices = function() --Tab names (localised)
			local headings={table.getn(Env().MenuStack)==1 and "Done" or "Back"} --go "Back" if we are in a tab submenu.
			for i,v in next,page.Contents,nil do headings[i+1]=v.Name end
			return RowType.ListNames(headings,Languages[CurLanguage()].Menus[name])
		end,
		get = function(r,pn) local out={} for i=1,table.getn(r.Choices) do out[i]=i==(Env().SelectedTab or 1) end return out end,
		set = function(r,pn,i,flag)
			if not (rows and flag) then return end --on screen exit, rows is gone then SaveSelections is called.
			r.settabs(r,pn,i)
		end
	}
	local r=RowType.ListBase(page.Name or " ",handler,false,false,true)
	if readonly then r.EnabledForPlayers={} end
	r.LayoutType="ShowAllInRow"
	r.settabs=function(r,pn,i) --moving the cursor will run this routine
		for j,o in next,rows[r.Line].items.text,nil do local c=j==i and 0 or 1 o:diffuse(c,c,c,1) end --update tab text colours (highlighted = black text)
		for i=2,table.getn(rows) do rows[i].title:settext(" ") rows[i].icons[pn].text:settext(" ") end --clear old contents text

		local sel=i-1 --because Back comes first
		Frame:aux(sel) --used to select NextScreen.

		if i==1 or not page.Contents then --Back is selected
			--rows[3].title:settext("Go Back") --debug test
		
			--Mods summary:
			
			do
				local text=rows[3].icons[pn].text
				text:settext(PlayerMods(pn))
				text:diffuse(unpack(PlayerColor(pn)))	
			end

			if not GetEnv("WorkoutMode") then
				local text=rows[5].icons[pn].text
				text:diffuse(unpack(PlayerColor(pn)))	

				text:settext(IsCourseMode() and
					sprintf("%s (%d)",Languages[CurLanguage()].CourseDifficultyNames[CurTrail(pn):GetDifficulty()],playerMeter[pn] or 0)
					or
					sprintf("%s (%d)", Languages[CurLanguage()].Difficulty[DifficultyNames[dText[CurSteps(pn):GetDifficulty()]+1]], playerMeter[pn])
				)
			else
				local text=rows[5].icons[pn].text
				text:diffuse(unpack(PlayerColor(pn)))	

				text:settext(sprintf("%d songs, %d-%d",
					GetSysConfig().WorkoutSongsToPlay,
					GetSysConfig().WorkoutDifficultyMin,
					GetSysConfig().WorkoutDifficultyMax
				))
			end

			return
		else
			local submenu=page.Contents[sel]

			--populate preview rows
			if submenu.Contents then
				for line,rowdata in next,submenu.Contents,nil do
					local row=rows[line+1] --start on row after tab bar (obviously)

					Env()._tabline=line
					local r=ModsMenu.ModLineRaw(rowdata)

					row.title:settext(IsString(r) and split(",",r)[2] or r.Name) --builtins need titles too (eg, "list,Characters")
					row.title:diffuse(1,1,1,1)

					local textobj=row.icons[pn].text
					textobj:settext(ModsMenu.GetInfoText(pn,r) or "?")
					textobj:diffuse(unpack(PlayerColor(pn)))
				end
				Env()._tabline=nil
			end
		end
	end
	return r
end
