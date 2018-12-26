Capture.ExtraInfo={

	UpdateScoreList=function(s,pn)
		r=Capture.ActorFrame.GetChildren(s).children

		local list=GetScores()

		for i,score in next,list,nil do
			local entry=r.children[i].children[1]
			local oname=entry.children[1].children[1].self
			local oscore=entry.children[2].children[1].self
			local ojudge=entry.children[3].children[1].self

			local name=score.Name
			local percent=score.Percent
			local judge=join("\n",score.Judge)

		end
	end
}