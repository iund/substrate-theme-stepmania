function HighScoreListObject(pn,numentries,ranktextx,nametextx,scoretextx,datetextx,song,steps)
	local cols={}
	local set=function(s)
		local scores={}

		local songcourse=not IsCourseMode() and GetCurSong() or IsCourseMode() and GetCurCourse()
		local stepstrail=not IsCourseMode() and GetCurSteps(pn) or IsCourseMode() and GetCurTrail(pn)
		
		if songcourse and stepstrail then
			scores=songcourse and stepstrail and GetSortedScoresList(nil,songcourse,stepstrail)
		end

		local ranktext={}
		local nametext={}
		local scoretext={}
		local datetext={}

		local dateformat=function(datestr)
			local out={}
			for part in string.gfind(datestr,"%d+") do
				out[#out+1]=part
			end
			out[2]=MonthToLocalizedString(tonumber(out[2]-1))

			return join(" ",table.sub(out,2,3))

		end
		for i=1,numentries do
			ranktext[i]=tostring(i)
			nametext[i]=scores[i] and scores[i]:GetName() or "----"
			scoretext[i]=scores[i] and FormatPercentScore(scores[i]:GetPercentDP()) or "----"
			datetext[i]=scores[i] and dateformat(scores[i]:GetDate()) or "----"
		end

		cols.rank:settext(join("\n",ranktext))
		cols.name:settext(join("\n",nametext))
		cols.score:settext(join("\n",scoretext))
		cols.date:settext(join("\n",datetext))

	end
	return Def.ActorFrame{
		OnCommand=set,

		[IsCourseMode() and "CurrentTrailP"..PlayerIndex[pn].."ChangedMessageCommand"
		or "CurrentStepsP"..PlayerIndex[pn].."ChangedMessageCommand"]=set,

		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:x(ranktextx) s:zoom(.75) cols.rank=s end,
		},
		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:x(nametextx) s:zoom(.75) cols.name=s end,
		},
		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:x(scoretextx) s:zoom(.75) cols.score=s end,
		},
		Def.BitmapText{
			Font="_common white",
			InitCommand=function(s) s:x(datetextx) s:zoom(.75) cols.date=s end,
		},
	}
end
