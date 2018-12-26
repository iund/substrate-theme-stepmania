Capture.ModsMenu={
		On=function(s)
			--3.95 adds player-specific objects with FOREACH_HumanPlayer, while SM5 uses FOREACH_PlayerNumber.
			--Override normal ForeachPlayer() with one that always runs for both player numbers.
			local function ForeachPlayer(action) for pn=1,2 do if SM_VERSION==5 or Player(pn) then action(pn) end end end

			--capture frame
			local frameItems=Capture.ActorFrame.GetChildren(s)
			local getn=table.getn
			local insert=table.insert
	
			page=frameItems.children[1].self or frameItems.children[1] --it's an AutoActor
			
			local r=2
			linehighlights={} ForeachPlayer(function(pn) linehighlights[pn]=frameItems.children[r] r=r+1 end)
			cursors={} ForeachPlayer(function(pn) cursors[pn]=frameItems.children[r] r=r+1 end)
			--cursor structure: self { middle, left, right }
			
			--populate a named table
			rows={}
			while frameItems.children[r].children do
				local row=frameItems.children[r].children[1].children
				local rowframe=frameItems.children[r].children[1].self

				--SM5 seems to omit optionicons and go straight for bullet, title, items.
				
				local i=SM_VERSION==5 and 3 or 5 -- 1,2=optionicons, 3=bullet, 4=title, 5...end=titles,highlights
				--local i=5 -- 1,2=optionicons, 3=bullet, 4=title, 5...end=titles,highlights
				local itemtexts =	{}
				while IsBitmapText(row[i]) do insert(itemtexts, row[i]) i=i+1 end
				
				if getn(row)>5 then --option row
					local highlights={}
					local shared=false
					local condensed=false
					if getn(row)-4-getn(itemtexts)==getn(itemtexts) or getn(itemtexts)==1 then --same number of text objects as sprites
						condensed=true
						shared=getn(itemtexts)==1 --if it's condensed, and shared.
						ForeachPlayer(function(pn) highlights[pn]={row[i]} i=i+1 end)
					else
						condensed=false
						ForeachPlayer(function(pn) highlights[pn]={} for j=1,getn(itemtexts) do highlights[pn][j]=row[i] i=i+1 end end)
					end
					insert(rows, {
						self=rowframe,
						icons={ 
							[1]={ self=row[1].self, sprite=row[1].children[1], text=row[1].children[2] },
							[2]={ self=row[2].self, sprite=row[2].children[1], text=row[2].children[2] }
						},
						bullet=row[3],
						title=row[4],
						items={ text=itemtexts, highlight=highlights },
						condensed=condensed,
						shared=shared
					})
				else --exit row
					rows.exit={
						self=rowframe,
						icons={ 
							[1]={ self=row[1].self, sprite=row[1].children[1], text=row[1].children[2] },
							[2]={ self=row[2].self, sprite=row[2].children[1], text=row[2].children[2] }
						},
						bullet=row[3],
						title=row[4],
						text=row[5]
					}
				end

				--TODO: put the bullet behind the cursor: help?
				row[3]:draworder(-1)
				row[3]:visible(Bool[false])
				r=r+1
				
				ForeachPlayer(function(pn) cursors[pn].self:aux(pn) end) --set pn to be used elsewhere
				--ForeachPlayer(function(pn) Sprite.aux(linehighlights[pn],pn) cursors[pn].self:aux(pn) end) --set pn to be used elsewhere
			end

			if rows.exit then rows.exit.text:settext(Languages[CurLanguage()].ScreenOptions.Exit) end
			
			--DualScrollBar. Not even used (no scrolling menus)
			if IsActorFrame(frameItems.children[r]) then
				local frame=frameItems.children[r]
				local i=1
				--order: under p1, under p2, over p1, over p2 (type Sprite)
				scrollbar={}
				ForeachPlayer(function(pn) scrollbar[pn]={ under=frame.children[i], over=frame.children[i+2] } i=i+1 end)
				scrollbar.self=frame.self
				r=r+1
			end
			
			--explanation text
			explanations={}
			ForeachPlayer(function(pn) explanations[pn]=frameItems.children[r] r=r+1 end)
		end,
		More=function(s) more=Capture.AutoActor(s) disqualifyText={} end, --DQ oncommand gets run immediately after MoreOn
		DQ=function(s,pn) disqualifyText[pn]=Capture.AutoActor(s) end,
		Off=function(s) frameItems=nil rows=nil linehighlights=nil cursors=nil page=nil disqualifyText=nil more=nil end
	}