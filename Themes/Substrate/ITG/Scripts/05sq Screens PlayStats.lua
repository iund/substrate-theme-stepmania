Screens.PlayStats={
	GetPackCounts=function()
		local ps=GetSysProfile().PlayStats
		local count={}

		for songdir,song in next,ps,nil do
			local folder=split("/",songdir)[3]
			count[folder]=count[folder] or 0
			for style,charts in next,song,nil do
				for chart,stats in next,charts,nil do
				        count[folder]=count[folder]+stats.PlayCount
				end
			end
		end

		local counti={} for folder,count in next,count,nil do table.insert(counti,{Folder=folder,Count=count}) end

		DumpTable(counti,"GetPackCounts")		
		return counti
	end,
	GetMostPlayedPacks=function()
		local counts=Screens.PlayStats.GetPackCounts()

		table.sort(counts,function(a,b) return a.Count<b.Count end)
		local top=table.sub(counts,1,10)
		DumpTable(top,"GetMostPlayedPacks")
	end,
	GetLeastPlayedPacks=function()
		local counts=Screens.PlayStats.GetPackCounts()

		table.sort(counts,function(a,b) return a.Count>=b.Count end)
		local bot=table.sub(counts,1,10)
		DumpTable(bot,"GetLeastPlayedPacks")
	end
}
--[[
      [&quot;PlayStats&quot;]={
                [&quot;/Songs/Notice Me Benpai/Gloss (Niteloop Flip)/&quot;]={
                        [&quot;dance-single&quot;]={
                                [&quot;Challenge&quot;]={
                                        [&quot;LastPlayedTime&quot;]=&quot;2017/12/09 18:18:18&quot;,
                                        [&quot;PlayCount&quot;]=2,
                                },
                        },
                },
                [&quot;/Songs/Eurobeat Is Fantastic/Let It Burn - [Rems]/&quot;]={
                        [&quot;dance-single&quot;]={
                                [&quot;Challenge&quot;]={
                                        [&quot;LastPlayedTime&quot;]=&quot;2017/12/09 18:23:34&quot;,
                                        [&quot;PlayCount&quot;]=4,
                                },
                        },
                },
        },
--]]




