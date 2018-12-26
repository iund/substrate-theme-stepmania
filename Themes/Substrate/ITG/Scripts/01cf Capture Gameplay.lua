Capture.Player={ -- Can't get the notefield though
		On=function(s,pn)
			s:draworder(5)
			local objs=Capture.ActorFrame.GetChildren(s).children

			if CurGame=="techno" and CurStyleName()=="single8" then
				--technomotion singles is offset; correct this
				local offset=pn==1 and 56 or -56
				--getmetatable(s).addx(s,offset)
				s:addx(-offset)
				for i,c in next,objs,nil do (c.self or c):addx(offset) end
			end
		
			--judge=judge or {}
			--judge[pn]=objs[1] --.children[1] --get the sprite directly
			local judge=objs[1]

			local comboroot=objs[2]
			local cc=comboroot.children
			--combo=combo or {}
			--combo[pn]={
			local combo={
				self=comboroot.self,
				milestone={ hundred=cc[1], thousand=cc[2] },
				label=cc[3],
				misses=cc[4],
				number=cc[5],
			}		
			--attackdisplay shows stuff like "level 3 attack" in Rave playmode. (lord knows how it works and CBA to find out.)
			attackdisplay=attackdisplay or {}
			attackdisplay[pn]=objs[3].children

			holdjudgment=holdjudgment or {} holdjudgment[pn]={}
			for i=4,table.getn(objs) do --there are always MAX_NOTE_TRACKS (sixteen) hold judge sprites loaded, regardless of the selected game.
				holdjudgment[pn][i-3]={ self=objs[i].self, sprite=objs[i].children[1] }
				objs[i].children[1]:aux(pn)
			end

			--NotITG fix:
			JudgeComboInit.NotITGCombo(combo,pn) --(combo[pn],pn)
			JudgeComboInit.NotITGJudge(judge.children[1],pn) --(judge[pn].children[1],pn)
		end,
		Off=function() holdjudgment=nil attackdisplay=nil judge=nil combo=nil JudgeComboInit.Off() end
	}
Capture.Lifebar={ -- Almost everything the lifebar does, is hardcoded behaviour.
		Stream={
			Normal=function(s)
				GetScreen():aux(GetScreen():getaux()+(Player(1) and 1 or 2))
				local pn=GetScreen():getaux()
				lifebar=lifebar or {} --In 3.95, streamon runs first, then lifeon.
				lifebar[pn]=lifebar[pn] or { stream={} }
				lifebar[pn].stream.normal=s
			end,
			Hot=function(s)
				local pn=GetScreen():getaux()
				lifebar[pn].stream.hot=s
			end,
		},
		On=function(s,pn)
			lifebar=lifebar or {} lifebar[pn]=lifebar[pn] or { stream={} } --sm5 doesnt run Stream on.
			local frame=Capture.ActorFrame.GetChildren(s)
			local fc=frame.children

			if IsBitmapText(fc[3]) then --battery bar
				lifebar[pn]={
					self=frame.self,
					frame=fc[1],
					battery=fc[2],
					lives=fc[3],
					dangerglow=fc[4].children[1], --percent=fc[4].children[1], --Dirty hack I know, but CBA.
				}
				fc[4].self:visible(Bool[false]) --hide %
				lifebar[pn].battery:x(0) --hardcoded to -92/+92
				lifebar[pn].lives:x(0)
			else
				local stream=lifebar[pn].stream
				stream.self=fc[3]
				lifebar[pn]={
					self=frame.self,
					background=fc[1].self or fc[1], --AutoActor
					dangerglow=fc[2],
					stream=stream,
					frame=fc[4].self or fc[4],
				}
				if fc[1].self then fc[1].self:zoomto(1,1) end
				--there's no feasible place to bind Tweens actions in Screens. Do it here instead.
				Tweens.Gameplay.LifeParts.FrameOn(lifebar[pn].frame,pn)
				Tweens.Gameplay.LifeParts.BackgroundOn(lifebar[pn].background,pn)
				Tweens.Gameplay.LifeParts.DangerGlowOn(lifebar[pn].dangerglow,pn)
				Tweens.Gameplay.LifeParts.StreamOn(lifebar[pn].stream.normal,pn)
				Tweens.Gameplay.LifeParts.StreamFullOn(lifebar[pn].stream.hot,pn)
			end

		end,
		Off=function(pn) lifebar[pn]=nil end
	}
Capture.DangerLayer=function(s) s:zoom(0) local pn=GetPN(DangerState[1]) s:aux(pn) DangerState[pn]={self=s,Active=false,LastSeenTime=0} end
Capture.DeathLayer=function(s) s:zoom(0) local pn=GetPN(DeathState[1]) s:aux(pn) DeathState[pn]={self=s,Active=false,LastSeenTime=0} end
