Capture.MusicWheel={
		WheelOn=function(s) --this gets run twice: at start load, and at finish load
			-- XXX: In SM5, this only gets run at the end, so this is now moved to Screens.
			--XXX: s is the highlight
--			if s:getaux()==0 then s:aux(-1) mwItems={} mwSprites={} mwTexts={} end
		end,
		ItemOn=function(s)
			if table.getn(mwItems)<Metric("MusicWheel","NumWheelItems")+2 then
				table.insert(mwItems, Capture.ActorFrame.GetChildren(s))
				local i=table.getn(mwItems)
				local mwic=mwItems[i].children
				mwSprites[i]={
					BaseBar=mwic[1],
					Song=mwic[3],
					Folder={ Closed=mwic[4], Open=mwic[5] },
					Mode=mwic[6],
					Sort=mwic[7],
					Icon=mwic[8],
					Grade=GetNumPlayersEnabled()==2
						and { [1]=mwic[14], [2]=mwic[15] }
						or {
							[1]=Player(1) and mwic[14] or false,
							[2]=Player(2) and mwic[14] or false
						}
--[[
						and { [1]=mwic[MUSICWHEEL_EXTRA_FEATURES and 18 or 14], [2]=mwic[MUSICWHEEL_EXTRA_FEATURES and 22 or 15] }
						or {
							[1]=Player(1) and mwic[MUSICWHEEL_EXTRA_FEATURES and 18 or 14] or false,
							[2]=Player(2) and mwic[MUSICWHEEL_EXTRA_FEATURES and 18 or 14] or false
						}
--]]
				}
				local mwisc=mwic[9].children
				mwTexts[i]={
					BaseText=mwic[2], -- "- EMPTY -" text, ordinarily.
					Song={ self=mwic[9].self, Title=mwisc[1], Subtitle=mwisc[2], Artist=mwisc[3] },
					Folder=mwic[10],
					Roulette=mwic[11],
					Course=mwic[12],
					Sort=mwic[13],
					--extra stuff: you MUST check if MUSICWHEEL_EXTRA_FEATURES is defined before trying to use them
--[[
					SongDir=mwic[14],
					Meter=GetNumPlayersEnabled()==2
						and { [1]=mwic[15], [2]=mwic[19] }
						or { [1]=Player(1) and mwic[15] or false, [2]=Player(2) and mwic[15] or false },
					Score={
						Name=GetNumPlayersEnabled()==2
							and { [1]=mwic[17], [2]=mwic[21] }
							or { [1]=Player(1) and mwic[17] or false, [2]=Player(2) and mwic[17] or false }
						,
						Percent=GetNumPlayersEnabled()==2
							and { [1]=mwic[16], [2]=mwic[20] }
							or { [1]=Player(1) and mwic[16] or false, [2]=Player(2) and mwic[16] or false }
					}
--]]
				}
				--add aux indexes:
				mwTexts[i].Song.Subtitle:aux(i) --for SetInfo()
				s:aux(i) --for Unhide()

				mwSprites[i].Folder.Open:aux(i) mwSprites[i].Folder.Open:luaeffect("Update") --help figure out which folder we're in
				mwSprites[i].Folder.Closed:aux(i) mwSprites[i].Folder.Closed:luaeffect("Update") --help figure out which folder we're in
				
				--Capture.ActorFrame.RunCommandsOnImmediateChildren(s,function(s) s:luaeffect("Update") end)
				--Capture.ActorFrame.RunCommandsOnImmediateChildren(s,function(s) LuaEffect(s,"Update") end)
			elseif GAMESTATE:GetSortOrder()==SORT_MODE_MENU then
				mwTexts[s:getaux()].Song.Title:settext('') --prevent stray banners from being loaded by Format()
				mwTexts[s:getaux()].BaseText:settext('') --catch stray BaseText that doesn't get hidden
			elseif mwTexts[s:getaux()].Song.Title:GetText()~='' then
				--Trace('reload')
				--Capture.MusicWheel.FirstFormat(s:getaux())
			end
			Capture.MusicWheel.FirstFormat(s:getaux())
		end,
		ItemOnSM5=function(s)
			table.insert(mwItems, Capture.ActorFrame.GetChildren(s))
			local i=table.getn(mwItems)
			local mwic=mwItems[i].children
			mwSprites[i]={
				BaseBar=mwic[1], --There is no basebar; what can I use?
				Song=mwic[2],
				Folder={ Closed=mwic[4], Open=mwic[6] },
				Mode=mwic[14],
				Sort=mwic[12],
				Icon=mwic[42],
				Grade=GetNumPlayersEnabled()==2
					and { [1]=mwic[43], [2]=mwic[44] }
					or { [1]=Player(1) and mwic[43] or false, [2]=Player(2) and mwic[43] or false }
			}
			local mwisc=mwic[21].children
			mwTexts[i]={
				BaseText=mwic[37], -- No basetext apparently; re-use Mode.
				Song={ self=mwic[21].self, Title=mwisc[1], Subtitle=mwisc[2], Artist=mwisc[3] },
				Folder=mwic[32], --and 33
				Roulette=mwic[34],
				Course=mwic[35],
				Sort=mwic[36],
			}
			--add aux indexes
			mwTexts[i].Song.Subtitle:aux(i) --for SetInfo()
			s:aux(i) --for Unhide()
			Capture.MusicWheel.FirstFormat(s:getaux())
		end,
		After=function(wheel)
			local mwRoot=Capture.ActorFrame.GetChildren(wheel)
			local bottom=table.getn(mwRoot.children)
			local mwScrollBar=mwRoot.children[bottom] --2
			local mwHighlight=mwRoot.children[bottom-1] --1
			mwHighlight:zoomto(Metrics.MusicWheel.ItemWidth,Metrics.MusicWheel.SpacingY) --Make the highlight sprite fit wheel items.
			
			if table.getn(mwRoot.children)>2 then
				--In SM5, all wheel items are loaded as children. (in addition to scrollbar/highlight)
				--They're not already run, because there's no MusicWheelItem[StartOn/FinishOn]Command. Run ItemOn manually.
				for i=1,(table.getn(mwRoot.children)-2) do Capture.MusicWheel.ItemOnSM5(mwRoot.children[i].self) end			
			end
			Capture.MusicWheel.SetAllInfo(wheel)
			LuaEffect(wheel,"Update")
		end,
		FirstFormat=function(i)
			local mwi=mwItems[i]
			local mwt=mwTexts[i]
			local mws=mwSprites[i]
			
			--Bring basetext forward, but keep it behind the folder sprites. Yes it's a workaround for Basetext not being hidden automatically
			-- Draworder doesn't seem to work here, so Z positioning will have to do.
			mws.Song:z(-2)
			mws.Icon:z(-2)
			mwt.BaseText:z(-1);
			mwt.Course:z(-1);

			ForeachPlayer(function(pn) local g=mws.Grade[pn] g:ztestmode('writeonfail') g:z(-2) g:zoomtoheight(Metrics.MusicWheel.SpacingY) end) --initialise clearlamps

			mwi.self:SetDrawByZPosition(true) --TODO: will setting this false and using draworder still work?
			
			--Reload the graphics that got missed (3.95 only)
			if not mws.Folder.Closed.self then
				mws.Folder.Closed:Load(GetPathG("MusicWheelItem _section*.png",true))
				mws.Folder.Open:Load(GetPathG("MusicWheelItem _expanded*.png",true))
				mws.Sort:Load(GetPathG("MusicWheelItem _section*.png",true))
				mws.BaseBar:Load(GetPathG("MusicWheelItem _song*.png",true))
				mws.Song:Load(GetPathG("MusicWheelItem _song*.png",true))
			end

			--Scale the sprites to suit the wheel spacing
			for i,s in next,{mws.BaseBar, mws.Sort, mws.Song, mws.Mode, mws.Folder.Closed, mws.Folder.Open},nil do
				local o=s.children and s.children[1] or s
				o:zoomto(Metrics.MusicWheel.ItemWidth,Metrics.MusicWheel.SpacingY)
				if i<5 then o:diffusealpha(CommonPaneDiffuseAlpha) end --except folders. keep them opaque to hide the stray left meter text (BaseText)
			end

			for _,s in next,{mwt.Roulette, mwt.BaseText, mwt.Sort, mwt.Course, mwt.Song.Title, mwt.Song.Subtitle, mwt.Folder},nil do
				s:zoom(Metrics.MusicWheel.TitleTextZoom)
			end

			--Banner wheel items consists of: basebar (back+mask), song (banner), mode (outline frame).
			--mws.BaseBar:zbias(1) mws.BaseBar:zwrite(1) --banner mask (basetext needs this too, because the game doesn't toggle hidden on it)
			--mws.Song:zbias(2) mws.Song:zbuffer(1) mws.Song:ztestmode("writeonfail") --banner mask (basetext needs this too, because the game doesn't toggle hidden on it)

--[[
			if GetSysConfig().MusicWheelUsesBanners then
				--mws.Song:Load(THEME:GetPath(2,'MusicWheelItem','mode')) --mask
				mws.Mode:scaletoclipped(unpack(Metrics.MusicWheelItem.BannerSize)) --crop the banner to the frame
				mws.Mode:diffusealpha(0.25) --TODO tweens.lua
			end
--]]

			for _,s in next,{mwt.BaseText, mwt.Course, mwt.Song, mws.Mode},nil do (s.self or s):ztestmode('writeonfail') end --use mask
			for _,s in next,{mwt.Course,mwt.Sort,mwt.Folder},nil do s:maxwidth(Metrics.MusicWheelItem.MaxTextWidth/s:GetZoomX()) end --clamp text widths

			if false then --if MUSICWHEEL_EXTRA_FEATURES then
				ForeachPlayer(function(pn) mwt.Meter[pn]:x(Metrics.MusicWheelItem.MeterX[pn]) mwt.Meter[pn]:ztestmode("writeonfail") end)
			else
				if not IsCourseMode() then 
					for i,m in next,{ mwt.Course, mwt.BaseText },nil do m:zoom(1) m:x(Metrics.MusicWheelItem.MeterX[i]) end --format text
				else
					if MusicWheelItem and MusicWheelItem.GetCourse then --My feature ;)
						--Since basetext and course got re-used for meter values in dance mode,
						--reuse the song Textbanner for the course meter. 
						local mwts=mwt.Song
						for i,m in next,{mwts.Title,mwts.Subtitle},nil do m:x(Metrics.MusicWheelItem.MeterX[i]) m:zoom(1) end
					end
				end
			end
			
			--Set colours.
			mws.Song:diffusecolor(unpack(UIColor("MusicWheelItemSong")))
			mws.BaseBar:diffusecolor(unpack(UIColor("MusicWheelItemSong")))
			
			mwState.CurFolder=CurSong() and GetFolder(CurSong()) or ""
		end,
		Format=function(i,maxwidth) --Center align both the title and subtitle text, to allow them to be formatted differently.
			local mwts=mwTexts[i].Song
			mwts.Subtitle:settext(" "..mwts.Subtitle:GetText())
			mwts.Artist:settext("")
			local totalwidth=AlignTexts("center",mwts.Title,mwts.Subtitle,mwts.Artist)
			mwts.self:zoomx(math.min(1,maxwidth or Metrics.MusicWheelItem.MaxTextWidth/totalwidth))

			--Capture.MusicWheel.QueuedFormat(mwItems[i].self)
			mwItems[i].self:queuecommand('QueuedFormat') --Stepmania sets hide flags AFTER format; so queuecommand is needed to work round it.

			--mwTexts[i].Folder:settext("")
		end,
		QueuedFormat=function(s)
			local i=s:getaux()
			if i==0 or not mwSprites or GAMESTATE:GetSortOrder()==SORT_MODE_MENU then return end --prevent crash if Start is hit halfway through QueuedFormat commands
			local mws=mwSprites[i]
			--mws.BaseBar:hidden(0) mws.Song:hidden(0) mws.Mode:hidden(0)
			--mwTexts[i].Song.Subtitle:diffuse(0.75,0.75,0.75,1) --The colour gets overwritten by the game when a folder is opened
			mwTexts[i].Song.Subtitle:diffusealpha(0.75) --The colour gets overwritten by the game when a folder is opened

			--clearlamp display
			ForeachPlayer(function(pn) mws.Grade[pn]:visible(Bool[UsingUSB(pn)]) end)

--[[
			--course name poll, for meter display (can't rely on textbanner)
			mwTexts[i].Course:aux(i)
			LuaEffect(mwTexts[i].Course,"Poll")
--]]

			--roulette and random wheel entries hides the meter objects that we don't want, when opening a folder
			local mwt=mwTexts[i]
			mwt.Course:visible(Bool[true])
			mwt.BaseText:visible(Bool[true])
		end,
		Update=function(w)

		end,
		Sprites={ --The draw order is: outer to inner, innermost last.
			SectionPoll=function(s) --Detect if a folder is closed then opened again.
				local i=s:getaux()
				if mwState and mwTexts and mwState.CurFolderItem==i and mwState.CurFolder==mwTexts[i].Folder:GetText() then
					mwState.CurFolderItem=0
				end
			end,
			ExpandedPoll=function(s) --Detect which folder is open, before highlighting a song.
				local i=s:getaux()
				if mwState and mwTexts and mwState.CurFolderItem~=i then
					mwState.CurFolderItem=i
					mwState.CurFolder=mwTexts[i].Folder:GetText()
					
					--ForeachPlayer(function(pn) Capture.MusicWheel.SetMeterText(i+math.floor(table.getn(mwItems)/2),pn) end)
					--if not CurSong() then ForeachPlayer(Capture.MusicWheel.SetAllMeterText) end
				end
			end,
		},
		CourseNamePoll=function(s)
--[[ TODO
			local i=s:getaux()
			local mwt=mwTexts[i]
			local lastseen=mwt.Song.Title
			local current=mwt.Song.Artist
			
			local lastseentime=lastseen:getaux()
			local curtime=s:GetSecsIntoEffect()
			lastseen:aux(curtime)
			if lastseentime==curtime then	
				mwTexts[i].Song.self:visible(Bool[true])
				Capture.MusicWheel.SetInfo(i)
			end
--]]
		end,
		SetAllInfo=function() for i=1,table.getn(mwTexts) do Capture.MusicWheel.SetInfo(i) end end, --SetAllInfo=function() for i=1,table.getn(mwTexts) do if mwTexts[i].Song.Title:GetText()~='' then Capture.MusicWheel.SetInfo(i) end end end,
		SetInfo=function(i) --hooked from Two/ThreeLinesSubtitleCommand
			if i==0 then return end --this fires prematurely on wheel load
			local mws=mwSprites[i]
			local mwt=mwTexts[i]
			local difftext=IsCourseMode() and {mwt.Song.Title,mwt.Song.Subtitle} or { mwt.Course, mwt.BaseText } --local difftext=MUSICWHEEL_EXTRA_FEATURES and mwt.Meter or { mwt.Course, mwt.BaseText }
			local sprite={ mws.Mode, mws.BaseBar } --unused rn
			Capture.MusicWheel.Format(i)
			local song=Capture.MusicWheel.GetSong(i)

			if song or MusicWheelItem and MusicWheelItem.GetSong then
				if GetSysConfig().MusicWheelUsesBanners then mws.Mode:LoadBanner(song and song:GetBannerPath() or THEME:GetPath(2,'','_blank')) end
				ForeachPlayer(function(pn) Capture.MusicWheel.SetMeterText(i,pn,true) end) --,wheel) end)
			else
				--current folder var update is delayed till next frame
				--mwItems[i].self:finishtweening()
				--mwItems[i].self:queuecommand("QueuedSet")
			end
		end,
		QueuedSetInfo=function(s)
			local i=s:getaux()
			local song=Capture.MusicWheel.GetSong(i)
			if GetSysConfig().MusicWheelUsesBanners then mws.Mode:LoadBanner(song and song:GetBannerPath() or THEME:GetPath(2,'','_blank')) end
			ForeachPlayer(function(pn) Capture.MusicWheel.SetMeterText(i,pn,true) end)
		end,
		GetSong=function(i)
			local call=MusicWheelItem and MusicWheelItem[IsCourseMode() and "GetCourse" or "GetSong"]
			if call then
				return call(mwItems[i].self) --Extra methods for wheel item to directly reference Song/Course pointers.
			elseif CurSong() or mwState.CurFolderItem then
				local mwt=mwTexts[i]
				local so=GAMESTATE:GetSortOrder()
				local folder=CurSong() and GetFolder(CurSong()) or mwState.CurFolder
				local title=mwt.Song.Title:GetText()..(mwt.Song.Subtitle:GetText()~=' ' and mwt.Song.Subtitle:GetText() or '')
				if so>=SORT_EASY_METER and so<=SORT_CHALLENGE_METER then
					return MasterSongList[title] or SONGMAN:FindSong(title) or nil --TODO
				elseif so==SORT_TITLE then
					return MasterSongList[title] or SONGMAN:FindSong(title) or nil
				else
					return
						AllSongsNamesBySort[so] and
						AllSongsNamesBySort[so][folder] and
						AllSongsNamesBySort[so][folder][title]
						or MasterSongList[title]
						or SONGMAN:FindSong(title)
						or nil
				end
--[[
				if so==SORT_GROUP then
					local song=AllSongNamesByFolder[folder] and AllSongNamesByFolder[folder][title] or nil
					return song
				elseif AllSongsNamesBySort[so][folder] then --not group sort, 

				local song=AllSongsNamesBySort[so][folder][title]
				return song
				end
--]]
			end
			return nil
		end,
		SetAllMeterText=function(pn,notween) for i=1,table.getn(mwTexts) do Capture.MusicWheel.SetMeterText(i,pn,notween) end end,
		SetMeterText=function(i,pn,notween)
		--TODO: Doesn't work for courses.

			local getn=table.getn
			local mwt=mwTexts[i]
			local song=Capture.MusicWheel.GetSong(i)
			local difftext=IsCourseMode() and {mwt.Song.Title,mwt.Song.Subtitle} or { mwt.Course, mwt.BaseText } --local difftext=MUSICWHEEL_EXTRA_FEATURES and mwt.Meter or {mwt.Course,mwt.BaseText}
			local m=difftext[pn]

			if not song then
				m:settext("")
				return
			end
			--set difficulties
			local curdiff={false,false}

			local d=
				IsCourseMode() and CurTrail(pn) and song:GetTrail(GetStepsType(),CurTrail(pn):GetDifficulty())
				or not IsCourseMode() and GetNearestDifficulty(song,pn)

			if d then
				curdiff[pn]=d:GetDifficulty()~=DIFFICULTY_INVALID and d:GetMeter() or 'x'

				m:visible(Bool[true])
				m:settext(tostring(curdiff[pn]))
				m:diffusecolor(unpack(difficultyColors[d:GetDifficulty()]))
			end

			if d and not notween then Tweens.SelectMusic.MusicWheelItem.MeterTween(m,d,pn) end
		end,
		Off=function(s) --clean up
			s:stopeffect()
			mwState=nil
			mwItems=nil mwSprites=nil mwTexts=nil mWheel=nil
		end
	}
Capture.CustomDifficultyList={ --Look in 04CustomDifficultyList.lua, this is unused
		On=function(s,pn) custDiffList=custDiffList or {} custDiffList[pn]=Capture.ActorFrame.GetChildren(s) end,
		Off=function(s,pn) custDiffList[pn]=nil end
	}
Capture.DifficultyList={ --Not the same as the dual lists visible in game. The only thing here that gets used right now is MoveCursor detection, because it's run after all onscreen text gets set.
		On=function(s)
			local insert=table.insert
			local getn=table.getn
			local list=Capture.ActorFrame.GetChildren(s)
			local objects=list.children
			DifficultyList={ Self=list.self, Cursors={}, Rows={} }
			local i=1
			while IsType(objects[i].children[1],'Sprite') do
				insert(DifficultyList.Cursors, objects[i]) objects[i].self:aux(getn(DifficultyList.Cursors)) i=i+1
			end
			while objects[i] do --DifficultyMeters (ActorFrames)
				insert(DifficultyList.Rows, objects[i])
				objects[i].self:aux(getn(DifficultyList.Rows))
				i=i+1
			end
		end,
		SetMeterColor=function(s,diff)
			s:aux(diff) s:diffuse(unpack(difficultyColors[diff]))
		end,
		MoveCursor=function(s,pn)
			-- this gets run after all song info is set
			--XXX2: Cursor tween gets run, then the Y position gets set by stepmania.
			if not DifficultyList then return end
			local cursor=DifficultyList.Cursors[s:getaux()]
			local diff=GAMESTATE:GetPreferredDifficulty(pNum[pn])
			local c=cursor.self
			DifficultyCursorTween(c)
			c:y(diff*Metric('DifficultyList','ItemsSpacingY'))

			--refresh wheel only if the difficulty is changed
			local cachedDiff=cursor.children[1]
			local wheel=GetScreen():GetChild('MusicWheel')
			if not IsCourseMode() and wheel and diff~=cachedDiff:getaux() then
				cachedDiff:aux(diff)
				Capture.MusicWheel.SetAllMeterText(pn)
			end
			--For some reason, Stepmania always sets all rows' Y positions, even if they're not actually being moved.
			--Capture.DifficultyList.MoveAllRows()
		end,
		MoveAllRows=function()
			local rows=DifficultyList.Rows
			for i=1,table.getn(rows) do Capture.DifficultyList.MoveRow(rows[i].self) end
		end,
		MoveRow=function(s)
			s:y(cursor.children[1]:getaux()*THEME:GetMetric('DifficultyList','ItemsSpacingY'))
		end,
		Off=function(s) DifficultyList=nil end
	}

