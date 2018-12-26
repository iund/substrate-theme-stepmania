


	RecordsMenu=function()
		local menutab={}
		for pm,playmode in next,{"Regular","Nonstop","Survival"},nil do
			menutab[pm]={ Name=playmode, Contents={} }
			local stepstypestohide={}
			for i,stepstype in next,ValidStepsTypes[CurGame],nil do
				stepstypestohide[i]={}
				local stt=stepstypestohide[i]
				for j,st in next,ValidStepsTypes[CurGame],nil do
					if st~=stepstype then table.insert(stt,st) end
				end
				menutab[pm].Contents[i]={
					Name=stepstype,
					Action=sprintf("setenv,StepsTypesToHide,%s;setenv,PlayMode,%s",join(":",stt),playmode),
					--Action=function() GAMESTATE:SetEnv("StepsTypesToHide",join(",",stt)) GAMESTATE:SetEnv("PlayMode",playmode) end,
					Screen="ScreenRecords"
				}
			end
		end
		return { Name="View Records", Contents=menutab }
	end