Capture.NameEntry={
		Init=function(s) Feat={Objects={},CurEntry={},Scores={}} end,

		--If player didn't get a high score:
		OutOfRanking=function(s,pn) Feat.Objects[pn]={} Feat.CurEntry[pn]={} Feat.Scores[pn]={} end, 
		--Or, if player got a highscore:
		EntryFrame=function(s,pn) Feat.Objects[pn]={} Feat.CurEntry[pn]={} Feat.Scores[pn]={} s:zbias(1) s:zbuffer(1) end, --stop the letters spilling outside the box

		Keyboard=function(s,pn) end,
		Letters=function(s) local pn=GetScreen():getaux() s:ztestmode("writeonfail") end,
		LettersSpecial=function(s) local pn=GetScreen():getaux() s:ztestmode("writeonfail") end,
		Selection=function(s,pn) s:ztestmode("writeonfail") end, --Name box

		-- Get each component. It has to be done this way, to avoid relying on screen root capture that's oITG and up.

		--Highscore wheel capture is run just before Wheel On.
		WheelText=function(s) WheelTextRoot=s end,
		WheelItem={Rank=function(s) end, Name=function(s) end, Score=function(s) end, Date=function(s) end},
		Wheel=function(s,pn) Feat.CurEntry[pn]={} Feat.CurEntry[pn].Wheel=s end,
		Banner=function(s,pn) Feat.CurEntry[pn].Banner=s end,
		Grade=function(s,pn) Feat.CurEntry[pn].Grade=s end,
		DifficultyIcon=function(s,pn) Feat.CurEntry[pn].DifficultyIcon=s end,
		DifficultyMeter=function(s,pn) Feat.CurEntry[pn].DifficultyMeter=s end,
		Score=function(s,pn) Feat.CurEntry[pn].Score=s end,
		BannerFrame=function(s,pn) Feat.CurEntry[pn].BannerFrame=s
			--Now that all the objects are here, let's GetText and populate Feat.Scores[pn]
			s:draworder(0)
			Capture.ActorFrame.ApplyPNToChildren(Feat.CurEntry[pn].Wheel,pn)
			--get score list
			local scorelist={}
			for i,w in next,Capture.ActorFrame.GetChildren(Feat.CurEntry[pn].Wheel).children,nil do
				local wc=w.children
				--if wc[4]:GetText()~="01/00" then
					scorelist[i]={rank=wc[1]:GetText(),name=wc[2]:GetText(),score=wc[3]:GetText(),date=wc[4]:GetText()}
				--end
			end
			--save to table for elsewhere use
			table.insert(Feat.Scores[pn],{
				List=scorelist,
				Meter=Feat.CurEntry[pn].DifficultyMeter:GetChild("Meter"):GetText(),
				--Score=Feat.CurEntry[pn].Score:GetChild("PercentP"..pn):GetText()
				--Score=Feat.CurEntry[pn].Score:GetChild("DancePointsP"..pn):GetText()
				Score=(Feat.CurEntry[pn].Score:GetChild("DancePointsP"..pn) or Feat.CurEntry[pn].Score:GetChild("PercentP"..pn)):GetText()


			})
			Feat.Objects[pn][table.getn(Feat.Objects[pn])+1]=Feat.CurEntry[pn]
			local getn=table.getn
			for n,s in next,Feat.CurEntry[pn],nil do --vertically position the entries ready for scrolling
				s:aux(table.getn(Feat.Objects[pn]))
				s:finishtweening()
				s:ztestmode("writeonfail")
				s:addy(Metrics.NameEntry.FeatHeight*(getn(Feat.Objects[pn])-1))
				
				s:visible(Bool[IsCourseMode() and not Course.GetCourseDir]) --This built-in feat scroller is no longer being used, in favour of my custom one that's more flexible. Hide it.
			end
			Feat.CurEntry[pn]=nil
		end,
		Off=function(s) Feat=nil WheelTextRoot=nil end,
	}
Capture.Summary={
		UpdateWheelText=function(s,row)
			--TODO
		end,
	}

