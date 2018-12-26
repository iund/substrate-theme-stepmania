CourseContentsList={
	Capture = function(s,pn)
		local insert=table.insert
		local raw=Capture.ActorFrame.GetChildren(s)
		local rows={}
		local bar=raw.children[1].children and raw.children[1].children[1] or raw.children[1]
		local infotext=raw.children[table.getn(raw.children)].children[1]
		if SM_VERSION==3.95 then --raw.children[1].children then
			--itg
			for i=1,table.getn(raw.children) do
				local child=raw.children[i].children[1]
				rows[i]={
					self=child.self,
					meter=child.children[1].children[1],
					title=child.children[2].children[1],
					subtitle=child.children[3].children[1],
				}
			end
		else
			--sm5
			for i=1,table.getn(raw.children) do
				local child=raw.children[i]
				rows[i]={
					self=child.self,
					meter=child.children[1],
					title=child.children[2],
					subtitle=child.children[3],
				}
			end
		end
		CourseList=CourseList or {}
		CourseList[pn]={self=s,rows=rows}
	end,

	On=function(s) --CourseContentsList removes and re-adds its children when scrolling. Must be done only on refresh, from another hook.
		clItems={} clTexts={}
		s:visible(Bool[false])
		CourseContentsList.Refresh(s)
	end,
	
	Refresh=function(s) --3.95 and oITG gives you a maximum of 7 items.
		local rawentries=Capture.ActorFrame.GetChildren(s or GetScreen():GetChild("CourseContents")).children
		clItems={} clTexts={}
		for i=1,table.getn(rawentries) do
			local entry=rawentries[i]
			local ec=entry.children
			local sc=ec[3].children
			local new={
				self=entry.self,
				Bar=ec[1],
				Index=ec[2],
				Song={ self=ec[3].self, Title=sc[1], Subtitle=sc[2], Artist=sc[3] },
				Meter={}
			}
			local j=4
			ForeachPlayer(function(pn) new.Meter[pn]=ec[j+1] j=j+2 end) --skip Foot (always "!")
			new.Mods=ec[j]
			clItems[i]=new

			--grab the text. Foot is always "1" so don't bother with it.
			local sc=ec[3].children
			clTexts[i]={
				Song={
					Title=sc[1]:GetText(),
					Subtitle=sc[2]:GetText(),
					Artist=sc[3]:GetText()
				},
				Meter={}
			}
			ForeachPlayer(function(pn) clTexts[i].Meter[pn]=clItems[i].Meter[pn]:GetText() end)
			for n,obj in next,clItems[i],nil do if IsBitmapText(obj) then clTexts[i][n]=obj:GetText() end end
			CourseContentsList.Format(i,new.Index:GetWidth())
		end
		ForeachPlayer(CourseContentsList.SetPaneList)
	end,
	
	Format=function(i,maxwidth)
		--Formats the builtin course list.
	end,

	SetPaneList=function(pn) --Re-use CustomDifficultyList for this, might as well.
		if not (CourseList and CourseList[pn] and CourseList[pn].rows) then return end --got a crash so plugging it up.

		--TODO get it to scroll
		for i,row in next,CourseList[pn].rows,nil do row.self:visible(Bool[false]) end --clear the existing rows

		--copy contents list into player pane's list
		for i=1,table.getn(clTexts) do
			local rowtext=clTexts[i]
			local row=CourseList[pn].rows[i]
			row.self:visible(Bool[true])
			row.self:y(Metrics.SelectMusic.PaneDisplay.CourseList.SpacingY*(i-1))

			row.meter:settext(rowtext.Meter[pn])

			--Use this for now because I can't get the split text fields working right..
			row.title:horizalign("left") row.title:zoom(15/20) --TODO: move to tweens
			row.title:settext(rowtext.Song.Title.." "..rowtext.Song.Subtitle)
			row.title:maxwidth(192)
--[[
			row.title:horizalign("left") row.title:zoom(15/20) --TODO: move to tweens
			row.title:settext(rowtext.Song.Title)

			row.subtitle:horizalign("left") row.subtitle:zoom(15/20)
			row.subtitle:diffusealpha(0.75)
			row.subtitle:settext(" "..rowtext.Song.Subtitle)

			local maxwidth=256 --todo: metrics
			local totalwidth=row.title:GetWidth()+row.subtitle:GetWidth()
			local scale=math.min(1,maxwidth/totalwidth)*row.title:GetZoomX()
			
			row.title:zoomx(scale)
			row.subtitle:x(row.title:GetX()+(row.title:GetWidth()*row.title:GetZoomX()))
			row.subtitle:zoomx(scale)
--]]
			--since there's no lua bindings (in 3.95) to get the difficulty of each individual song, instead use the trail difficulty
			if CurTrail(pn) then row.meter:diffuse(unpack(difficultyColors[CurTrail(pn):GetDifficulty()])) end
		end
	end,

	Off=function(s)
	end,
}
