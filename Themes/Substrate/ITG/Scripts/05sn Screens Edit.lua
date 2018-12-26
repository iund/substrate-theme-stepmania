Screens.Edit={
--		Init=function(s) Screens.SelectMusic.On() SetEnv('EditMode',1) end,
--		On=function(s) Screens.Gameplay.Init() Screens.Gameplay.On() end,
			--InputTipsOn and InfoOn gets run when edit screen opens, and also when backing out of playing state to editor again.
		--InputTips=left, Info=right.
--		InputTipsOn=function(s) s:horizalign("left") s:vertalign("top") s:shadowlength(0) s:zoom(15/20) end,
--		InfoOn=function(s) GetScreen():GetChild("Overlay"):visible(Bool[false]) s:horizalign("left") s:vertalign("top") s:shadowlength(0) s:zoom(15/20) s:draworder(-1) s:visible(Bool[false]) end,
		InfoGetTitles=function(s)
			local find=string.find
			local sub=string.sub
			local list=split("\n",s:GetText())
			local titles={}
			local i=1
			for _,line in next,list,nil do
				if line=="Selection beat:" then
					titles[i]="Selection top"
					titles[i+1]="Selection bot"
					i=i+2
				elseif find(line,":") then
					titles[i]=sub(line,1,-2)
					i=i+1
				end
			end
			return join("\n",titles)
		end,
		InfoGetValues=function(s)
			local sub=string.sub
			local list=split("\n",s:GetText())
			local values={}
			local i=1
			for _,line in next,list,nil do
				if sub(line,1,2)=="  " then
					values[i]=sub(line,3)
					i=i+1
				end
			end
			return join("\n",values)
		end,
--[[
		PlayRecordHelpOn=function(s)
			s:horizalign("center") s:vertalign("middle") s:shadowlength(0) s:zoom(15/20)
			s:luaeffect("Update") s:effectclock("beat")
		end,
		PlayRecordHelpUpdate=function(s) --Evaluated per frame (via luaeffect) while playing a chart
			local beat=math.floor(s:GetSecsIntoEffect())
			s:settext(sprintf("Beat %d/%d",math.mod(beat,4)+1,math.floor(beat/4)+1))
		end,
--]]
		FirstUpdate=function(s) end,
		State={
			--These get run when the editor enters a subscreen (eg, play, record, editor)
			--Edit gets run before layers get their hidden state changed, play/record is after.
			--So, run hidden on stuff in InfoOn or InputTipsOn.
			Edit=function(s) Broadcast("SlideIn") end,
			Play=function(s) s:visible(Bool[true]) Broadcast("SlideOut") end,
			Record=function(s) Broadcast("SlideOut") end
		},
		Off=function(s) JudgeComboInit.Off() Capture.Player.Off() end,
	}