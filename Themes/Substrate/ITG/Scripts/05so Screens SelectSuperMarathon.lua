-- For whatever reason this screen is doing strange things.
-- Evaluation crashes if you fail, the list doesn't appear when using xml screen layouts

-- ALSO why is the list displsy invisible?

Screens.SuperMarathon={}
Screens.SuperMarathon={
	List={
		On=function(s)
			LoadProfile() --I'd do it in PlayersFinalized but that message gets fired *before* profile loading happens.

			Env().SuperMarathon=Env().SuperMarathon or {} --don't clear it; we might be backing out of gameplay and need to land on whatever was last picked
			Env().SuperMarathon.PaneValues={}

			Env().Cache={}
			Env().Cache.Folders={}

			--fill song data, but only for songs with stepcharts valid for the current style.
			local fcache=Env().Cache.Folders
			local foldertmp={}
			for i,song in next,SONGMAN:GetAllSongs(),nil do
				local folder=GetFolder(song)
				local stepslist=song:GetStepsByStepsType(GetStepsType())
				if table.getn(stepslist or {})>0 then
					fcache[folder]=fcache[folder] or {}
					table.insert(fcache[folder],song)
					foldertmp[i]=folder
				end
			end
			Env().Cache.FolderNames={}
			local foldernames=Env().Cache.FolderNames
			for i,f in next,foldertmp,nil do
				if not table.find(foldernames,f) then table.insert(foldernames,f) end
			end
	
			--get which folder "course" was last picked
			ForeachPlayer(function(pn) Env().SuperMarathon.CurFolder=table.findkey(foldernames,UsingUSB(pn) and GetProfile(pn).SuperMarathonCurFolder or GetSysConfig().DefaultFolder) end)

			--grab objects
			local list=Capture.ActorFrame.GetChildren(s)

			Env().SuperMarathon.List={}
			Env().SuperMarathon.List.Column={}

			for i,col in next,list.children,nil do
				local songlist={}
----
				for r,row in next,col.children[5].children,nil do
					local song=row.children[1]
					local diffs={row.children[2],row.children[3]}
--[[
				for r,row in next,col.children[1].children[4].children[1].children,nil do
					local song=sl[r].children[1].children[1]
					local diffs={sl[r].children[2].children[1],sl[r].children[3].children[1]}
--]]
					--format
					local m=Metrics.SelectSuperMarathon.Column

					local sp=12 --TODO: Spacing
					row.self:y(sp*r)

					Actor.xy(song,unpack(m.SongsXY)) song:shadowlength(0) song:maxwidth(240) song:zoom(0.5)
					for d=1,2 do Actor.xy(diffs[d],m.DiffsX[d],m.DiffsY) diffs[d]:shadowlength(0) diffs[d]:zoom(0.5) end

					songlist[r]={ song=song, diff=diffs}
				end

				Env().SuperMarathon.List.Column[i]={
					self=col.self,
----
					pane=col.children[1],
					folder=col.children[2],
					length=col.children[3],
					numsongs=col.children[4],
--[[
					pane=col.children[1].children[1].children[1],
					folder=col.children[1].children[2].children[1],
					length=col.children[1].children[3].children[1],
--]]
					songlist=songlist
				}
			end

			--format columns
			local numcols=table.getn(list.children)
			local colspacing=Metrics.SelectSuperMarathon.Column.PaneSpacingX
			Actor.xy(list.self,unpack(Metrics.SelectSuperMarathon.Column.PaneXY))
			local ceil=math.ceil
			local cols=Env().SuperMarathon.List.Column
			for c=1,numcols do
				local col=cols[c]
				col.self:x(colspacing*(c-ceil(numcols/2)))
				for _,b in next,{col.folder,col.length,col.numsongs},nil do b:zoom(0.5) end
			end
			
			--start on middle column
			Env().SuperMarathon.List.CurPane=math.ceil(numcols/2) --middle

			Screens.SuperMarathon.List.UpdateAllCols()
		end,
		UpdateAllCols=function()
			local numcols=table.getn(Env().SuperMarathon.List.Column)
			local curfolderi=Env().SuperMarathon.CurFolder
			local upd=Screens.SuperMarathon.List.UpdateCol

			local ceil=math.ceil
			for i=1,numcols do upd(i,wrap(i+curfolderi-1,1,ceil(numcols/2))) end
		end,
		UpdateBanner=function()
			local banner=Env().SuperMarathon.List.Banner
			banner:Load(GetFolderBannerPath(Env().Cache.FolderNames[Env().SuperMarathon.CurFolder]))
			banner:scaletoclipped(unpack(Metrics.SelectSuperMarathon.List.BannerSize))
		end,
		UpdateCol=function(col,folderi)
			local upd=Env().SuperMarathon.List.Column[col]
			local foldername=Env().Cache.FolderNames[math.mod(folderi,table.getn(Env().Cache.FolderNames))+1]
			local folder=Env().Cache.Folders[foldername] or {}
			local diffs={{},{}}
			local totallength=0
			local pdiff={}
			ForeachPlayer(function(pn) pdiff[pn]=GAMESTATE:GetPreferredDifficulty(pNum[pn]) end)

			for i,r in next,upd.songlist,nil do r.song:settext("") for d=1,2 do r.diff[d]:settext("") end end
			for i,song in next,folder,nil do
				if Song.MusicLengthSeconds then totallength=totallength+song:MusicLengthSeconds() end
				if upd.songlist[i] then
					ForeachPlayer(function(pn)
						local d=GetNearestDifficulty(song,pn,pdiff[pn])
						local dtext=upd.songlist[i].diff[pn]
						dtext:settext(tostring(d and d:GetMeter() or ""))
						dtext:diffuse(unpack(difficultyColors[d and d:GetDifficulty() or 1]))
					end)

					upd.songlist[i].song:settext(GetSongName(song))
				end
			end
			local columns=Env().SuperMarathon.List.Column
			upd.folder:settext(foldername)
			upd.length:settext(SecondsToMSS(totallength))
			upd.numsongs:settext(sprintf("%d songs",table.getn(folder)))
		end,
		Move=function(pn,dir)
			local autorepeat=GetScreen():getaux()==0
			GetScreen():aux(0)
			
			local tweentime=0.25 --Metrics.MusicWheel.SwitchSpeed
			local repeattweentime=0.125
			local numcols=table.getn(Env().SuperMarathon.List.Column)
			Env().SuperMarathon.CurFolder=wrap(Env().SuperMarathon.CurFolder+dir,1,table.getn(Env().Cache.FolderNames))
			Env().SuperMarathon.List.CurPane=wrap(Env().SuperMarathon.List.CurPane+dir,1,numcols)
			local edge=wrap( Env().SuperMarathon.List.CurPane+dir*math.floor(numcols/2) ,1,numcols)
			local col=Env().SuperMarathon.List.Column
			local updfolder=wrap( Env().SuperMarathon.CurFolder+dir*math.floor(numcols/2)-1 ,1,table.getn(Env().Cache.FolderNames))
			local spacing=Metrics.SelectSuperMarathon.Column.PaneSpacingX
			for i,c in next,col,nil do
				if i==edge then c.self:finishtweening()
				else
					c.self:stoptweening()
					if autorepeat then c.self:linear(repeattweentime) else c.self:decelerate(tweentime) end
				end
				c.self:x(spacing*wrap(i-Env().SuperMarathon.List.CurPane,-numcols/2,numcols/2-1)) end
			Screens.SuperMarathon.List.UpdateCol(edge,updfolder)
			
			ForeachPlayer(Screens.SuperMarathon.PlayerPane.Update)
			Screens.SuperMarathon.List.UpdateBanner()
		end,
		ChangeDifficulty=function(pn,dir)
			Trace("SuperMarathon ChangeDifficulty("..tostring(pn)..")")
			GAMESTATE:SetPreferredDifficulty(pn,clamp(GAMESTATE:GetPreferredDifficulty(pn)+dir,DIFFICULTY_BEGINNER,DIFFICULTY_CHALLENGE))

			Screens.SuperMarathon.List.UpdateAllCols()

			--also todo: update difficulty meter values on all folder panes
		end,
		ChangeSort=function(s)
			--TODO
			ScreenMessage("TODO ChangeSort")
		end,
		Pick=function(s,pn)
			local foldername=Env().Cache.FolderNames[Env().SuperMarathon.CurFolder]
			local folder=Env().Cache.Folders[foldername]
			
			Env().SuperMarathon.Folder=folder
			
			--populate song queue in here?
			Env().SongQueue={}

			for i=1,table.getn(folder) do
				local song = folder[i]
				local steps={}
				ForeachPlayer(function(pn) steps[pn]=GetNearestDifficulty(song,pn) end)
				Env().SongQueue[i]={Song=song,Steps=steps}
			end
		end,
		Off=function(s)
			--Env().SuperMarathon=nil --Don't clear it. Some of the vars get used in gameplay and evaluation screens, which get cleared on game end anyway.
		end,
	},
	PlayerPane={
		On=function(s,pn)
			Env().SuperMarathon.PaneValues[pn]={}
			local pane=Capture.ActorFrame.GetChildren(s)

			Actor.xy(pane.self,Metrics.SelectSuperMarathon.PlayerPane.X[pn],Metrics.SelectSuperMarathon.PlayerPane.Y)
--[[
			for i=2,13 do local o=pane.children[i] o:shadowlength(0) o:zoom(0.75) end

			for i=1,6 do --position stats stuff on screen
				pane.children[i+1]:settext(Languages[CurLanguage()].ScreenSelectMusic.Pane[i==1 and "Steps" or StatsNames[i-1] ])
				Actor.xy(pane.children[i+1],unpack(Metrics.SelectSuperMarathon.PlayerPane.Labels[(i==1 and "NumSteps" or StatsNames[i-1]).."XY"]))
				Env().SuperMarathon.PaneValues[pn][i]=pane.children[i+7]
				Actor.xy(pane.children[i+7],unpack(Metrics.SelectSuperMarathon.PlayerPane.Texts[(i==1 and "NumSteps" or StatsNames[i-1]).."XY"]))
			end
			
			if pn==2 then pane.children[1]:basezoomx(-1) end
--]]
			for i=2,13 do local o=pane.children[i].children[1] o:shadowlength(0) o:zoom(0.75) end

			for i=1,6 do --position stats stuff on screen
				pane.children[i+1].children[1]:settext(Languages[CurLanguage()].ScreenSelectMusic.Pane[i==1 and "Steps" or StatsNames[i-1] ])
				Actor.xy(pane.children[i+1].children[1],unpack(Metrics.SelectSuperMarathon.PlayerPane.Labels[(i==1 and "NumSteps" or StatsNames[i-1]).."XY"]))
				Env().SuperMarathon.PaneValues[pn][i]=pane.children[i+7].children[1]
				Actor.xy(pane.children[i+7].children[1],unpack(Metrics.SelectSuperMarathon.PlayerPane.Texts[(i==1 and "NumSteps" or StatsNames[i-1]).."XY"]))
			end
			
			if pn==2 then pane.children[1].children[1]:basezoomx(-1) end
--]]
			
			Screens.SuperMarathon.PlayerPane.Update(pn)
		end,
		Update=function(pn)
			--accumulate stats counts for the entire folder
			local cumu={}
			for _,song in next,Env().Cache.Folders[Env().Cache.FolderNames[Env().SuperMarathon.CurFolder]],nil do
				local steps=GetNearestDifficulty(song,pn)
				for i=1,6 do cumu[i]=(cumu[i] or 0)+(steps and steps:GetRadarValues():GetValue(i+4) or 0) end
			end
			
			--put them on screen
			for i=1,6 do Env().SuperMarathon.PaneValues[pn][i]:settext(tostring(cumu[i])) end
		end,
		Off=function(s)
			Env().SuperMarathon.PaneValues=nil		
		end
	},
	Inputs={
		--If you want auto-repeat, use messageman bindings instead. These bindings gets run before messageman.
		--Also, only the menu buttons send the player number to the function calls.

		--Start doesn't fire again if we are already tweening out to Nextscreen and menu input 
--		{Code="Start", Action=function(pn) ScreenMessage("start") end}, --Screens.SuperMarathon.Pick(pText[pn]) end},

--		{Code="MenuLeft+MenuRight", Action=function(pn) Screens.SuperMarathon.ChangeSort() end},
--		{Code="Select", Action=function(pn) Screens.SuperMarathon.Pick(pText[pn]) end},
--		{Code="Select", Action=function(pn) PrepareScreen("ScreenEvaluationBlank") DeletePreparedScreens() end},

		{Code="MenuLeft", Action=function(pn) GetScreen():aux(-1) end}, --use this to detect autorepeat
		{Code="MenuRight", Action=function(pn) GetScreen():aux(-1) end},

		{Code="MenuUp", Action=function(pn) Screens.SuperMarathon.List.ChangeDifficulty(pText[pn],-1) end},
		{Code="MenuDown", Action=function(pn) Screens.SuperMarathon.List.ChangeDifficulty(pText[pn],1) end},

		
	},
}
