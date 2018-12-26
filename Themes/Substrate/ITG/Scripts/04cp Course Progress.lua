-- List songs + difficulty meters left to play in a course

CourseProgressDisplay={
	Current=function(s,pn)
		--if not Env().SongMods.CourseProgress then s:settext("") return end

		local i=GAMESTATE:GetCourseSongIndex()+1

		if not clTexts[i] then s:settext("") return end
	
		local sub=clTexts[i].Song.Subtitle
		local title=clTexts[i].Song.Title..(sub~="" and " "..sub or "")
	
		s:settext(pn and clTexts[i].Meter[pn] or title)
	end,
	
	Next=function(s,pn)
		--if not Env().SongMods.CourseProgress then s:settext("") return end

		local ii=GAMESTATE:GetCourseSongIndex()+2
		local out={}

		for i=ii,table.getn(clTexts) do
			--TODO: dimmed subtitle
			local sub=clTexts[i].Song.Subtitle
			local title=clTexts[i].Song.Title..(sub~="" and " "..sub or "")

			out[i-ii+1]=pn and clTexts[i].Meter[pn] or title
		end

		s:settext("\n"..join("\n",out))
	end
}
