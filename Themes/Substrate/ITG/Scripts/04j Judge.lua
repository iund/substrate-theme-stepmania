---------------------------------------
-- Judge/Combo Actor Functions
---------------------------------------

--this is extremely temperamental so don't you dare touch it lmao

-- Judge hooks

-- Judge: 1=fantastic, ... 6=miss
-- Holds: 7=held, 8=dropped
-- Mines: 9=hit mine

function JudgmentCommand(j,n)
	local pn=j:getaux() 
--DEBUG:	if Judgment and Judgment.GetNoteOffset and judge and judge[pn] then local offset=judge[pn].self:GetNoteOffset() ScreenMessage(sprintf("%.3f",offset)) end
	LastJudge[pn]=n
	Ghost.Step(pn,n)
	if not GetEnv("EditMode") and ComboColour then ComboColour[pn](n) end
	if JudgmentTween and JudgmentTween[pn] then JudgmentTween[pn](j) end
	Broadcast("JudgmentP"..tostring(pn))
end
function HoldCommand(h,n)
	local pn=GetEnv("EditMode") and 1 or h:getaux()
	LastJudge[pn]=n
	Ghost.Step(pn,n)
	if HoldTween and HoldTween[pn] then HoldTween[pn](h) end
	Broadcast("HoldJudgmentP"..tostring(pn))
end

function CheckHitMine(s)
	--StepPN calls this, then 
--	Trace("CheckHitMine("..s:getaux()..") "..s:GetText())
end
function PollHitMine(s) --s=PercentPn text
	local cs=CachedScore
	local pn=s:getaux() if not (cs and cs[pn]) then return end
	local dpscoring=Env().UseDP --GetPref("DancePointsForOni")
	if dpscoring and math.max(0,tonumber(s:GetText()))~=cs[pn] then Ghost.Step(pn,9) end --% display is inaccurate, don't rely on it to detect mines.
	--if dpscoring and math.max(0,tonumber(s:GetText()))~=CachedScore[pn] or not dpscoring and s:GetText()~=FormatPercentScore(CachedScore[pn]) then Ghost.Step(pn,9) end
end

-- Combo colour hooks

--NOTE: Midpoint gets run for every step, but the first quarter of the song gets sent FullComboBrokenCommand regardless of blue combo status.
function ComboPulse(c)
	local pn=c:getaux()
	if pn>0 and comboNumber and comboNumber[pn]~=c then ComboTween[pn]() end --pulse gets run on combo, combolabel and misseslabel
end
function MidpointComboColour(c,n)
	local pn=c:getaux()
	if pn>0 and GetProfile(pn).ComboColour==1 and comboNumber then Combo.Apply(n,pn) end
end

-- Setup functions

JudgeComboInit={
	Init=function()
		comboNumber={} comboLabel={} missesLabel={}
		worstJudge={0,0} --eg: fantastic=1, miss=6
		missOffsetFlag={false,false} -- this is used to work around the "+1 combo after miss" bug in sm 3.95 vanilla
		ComboColour={} JudgmentTween={} HoldTween={} ComboTween={} --ComboColour=nil JudgmentTween=nil HoldTween=nil ComboTween=nil
		LastJudge={0,0}
	end,

	--Dummies because the NotITG code is much less temperamental.
	Label=function(s) end,
	Number=function(s) end,
	Combo=function(s) end,
	Judge=function(s) end,

	Edit={ --Use the previous functions for ScreenEdit. Normal capture doesn't work there.
--[[
		Label=function(s) --populates in this order: comboLabel[1] missesLabel[1] comboLabel[2] missesLabel[2]
			comboLabel=comboLabel or {}
			missesLabel=missesLabel or {}
			local pn=GetPN(comboLabel[1] and missesLabel[1])
			if not comboLabel[pn] then comboLabel[pn]=s else missesLabel[pn]=s end
			s:aux(pn) --prevent crash by setting aux to pn, because [Combo] FullCombo*Command= runs on both number and label
		end,

		Number=function(s) --Capture combo number object and apply pn to it.
			comboNumber=comboNumber or {}
			local pn=p or GetPN(comboNumber[1])
			Trace("JudgeComboInit.Number "..pn)
			comboNumber[pn]=s
			s:aux(pn)
			s:shadowlength(0) s:horizalign('center') s:diffuse(1,1,1,1) s:vertalign('bottom')
		end,
--]]
		Combo=function(s)
			if s:getaux()==-1 then return end s:aux(-1) --don't run it twice
			local pn=GetPN(table.getn(comboNumber)>1)

			local cc=Capture.ActorFrame.GetChildren(s).children

			for i=1,table.getn(cc) do cc[i]:aux(pn) end
			
			comboLabel=comboLabel or {}
			missesLabel=missesLabel or {}
			comboNumber=comboNumber or {}

			comboLabel[pn]=cc[3]
			missesLabel[pn]=cc[4]
			comboNumber[pn]=cc[5]

			local n=cc[5] n:shadowlength(0) n:horizalign('center') n:diffuse(1,1,1,1) n:vertalign('bottom')

			JudgmentTween=JudgmentTween or {}
			HoldTween=HoldTween or {}
			ComboColour=ComboColour or {}
			ComboTween=ComboTween or {}

			JudgmentTween[pn]=Tween.Judgment(pn)
			HoldTween[pn]=Tween.Hold(pn)
			ComboColour[pn]=Combo.Init(pn)
			ComboTween[pn]=Tween.Combo(pn)
		
			ComboTween[0]=function(s) end --catch premature PulseCommand on screen load
		end,
	
		Judge=function(s) --set pn on judge sprite
			local r=Capture.ActorFrame.GetChildren(s)

			local judge=r.children[1] --.children[1] --get the sprite directly

			if judge:getaux()~=0 then return end
			local pn=GetPN(table.getn(comboNumber)>1)

			judge:aux(pn)
		
			--might as well load judge font here
			local font=GetPathG("_Judge Fonts/"..GetProfile(pn).JudgeFont,true)
			if font then judge:Load(font) end

			judge:basezoomx(judgeZoom)
			judge:basezoomy(judgeZoom)
		end,
	},
	--NotITG initialises stuff a bit differently.
	--Doing it the old way (see above, commented out) means comboNumber[pn] gets the wrong BitmapText object, thus the combo object doesn't tween.
	--Anyway, it's a cleaner way to initialise it, because it's using the actorframe captures.
	--Hooked from player capture.
	NotITGCombo=function(combo,pn)
		--combo setup
		comboNumber[pn]=combo.number
		comboLabel[pn]=combo.label
		missesLabel[pn]=combo.misses
		for r,s in next,combo,nil do if not IsTable(s) then s:aux(pn) end end
		local s=comboNumber[pn] s:shadowlength(0) s:horizalign('center') s:diffuse(1,1,1,1) s:vertalign('bottom')
		--object hooks
		JudgmentTween[pn]=Tween.Judgment(pn)
		HoldTween[pn]=Tween.Hold(pn)
		ComboColour[pn]=Combo.Init(pn)
		ComboTween[pn]=Tween.Combo(pn)
	end,
	
	NotITGJudge=function(judge,pn)
		--load judge font
		local font=GetPathG("_Judge Fonts/"..GetProfile(pn).JudgeFont,true)
		if font then judge:Load(font) end
		judge:aux(pn)
		judge:basezoomx(judgeZoom)
		judge:basezoomy(judgeZoom)
	end,
	
	Off=function() comboNumber=nil comboLabel=nil missesLabel=nil ComboColour=nil JudgmentTween=nil HoldTween=nil ComboTween=nil end
}

-- Tween functions

Tween={
	Judgment=function(pn)
		local size=GetProfile(pn).JudgeAnimation
		local jts=judgeTweenSizes[size]
		local bs=judgeTweenBaseSize
		local tween=Tweens.Gameplay.Judgment.Tween
		return function(s) tween(s,jts,bs) end
	end,

	Hold=function(pn)
		local env=GetProfile(pn)
		local h=env.HideHoldJudge and 0 or 1
		local hts=holdTweenSizes[env.JudgeAnimation]
		local bs=1
		local tween=Tweens.Gameplay.HoldJudgment.Tween
		return function(s) tween(s,h,hts,bs) end
	end,

	Combo=function(pn)
		local meter=playerMeter and playerMeter[pn] or 1 -- Check needed because it crashes on 'timed sets'
		local number=comboNumber[pn]
		local combolabel=comboLabel[pn]
		local misseslabel=missesLabel[pn]
		local size=GetProfile(pn).JudgeAnimation
		local cts=comboTweenSizes[size]
		local bug=not OPENITG and SM_VERSION==3.95 --i presume it got fixed in 5
		local tween=Tweens.Gameplay.Combo.Tween
		return function()
			local num=tonumber(number:GetText())
			local zoom=number:GetZoom()
			if bug and missOffsetFlag[pn] then number:settext(num-1) end --bugfix for +1 combo after miss

			local fadeval=clamp(num-3,0,meter)/meter/0.95
			tween(number,zoom,cts,fadeval)
			tween(combolabel,1,cts,fadeval)
			tween(misseslabel,1,cts,fadeval)
		end
	end
}

-- Colour functions

Combo={
	Init=function(pn)
		local mode=GetProfile(pn).ComboColour
		local wj=worstJudge[pn]
		local number=comboNumber[pn]
		local apply=Combo.Apply
		return function(n)
			if n==6 and wj<6 then --got a miss
				apply(6,pn) wj=6 missOffsetFlag[pn]=false
			elseif (mode==2 and n>wj) or (mode==3 and wj>=4 and n<4 or n>wj) then --set colour based on worst judge
				apply(n,pn) wj=n
			elseif n<6 and wj==6 then --came off a miss
				apply(4,pn) wj=4 missOffsetFlag[pn]=true
			end
		end
	end,

	Apply=function(n,pn)
		if n<4 then -- set colour (fantastic, excellent, great)
			local apply=Tweens.Gameplay.Combo.ColourApply
			apply(comboNumber[pn],n)
			apply(comboLabel[pn],n)
		else -- broke combo
			local cancel=Tweens.Gameplay.Combo.ColourCancel
			cancel(comboNumber[pn],n)
			cancel(comboLabel[pn],n)
			if n==6 then
				missOffsetFlag[pn]=false
				cancel(missesLabel[pn],n)
			end --miss
		end
	end
}
