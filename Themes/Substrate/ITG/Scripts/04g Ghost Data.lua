--Not using ghostdata right now so the settexts are commented out.

Ghost={}
Ghost={
	--SSM
	GetMaxDP=function(stats) --Get max dp from panedisplay saved stats.
		local prefix=IsCourseMode() and "Course" or "Song"
		local steps=prefix.."NumSteps"
		local holds=prefix.."Holds"
		local rolls=prefix.."Rolls"
		return not tonumber(stats[steps]) and -1 or stats[steps]*GetPref("PercentScoreWeight"..JudgeNames[1])+(stats[holds]+stats[rolls])*GetPref("PercentScoreWeight"..JudgeNames[7])
	end,

	--SGP
	Init=function(s) --s=helptext
		--Todo: move them all to Env()?
		ScoreWeights={} for i,n in next,JudgeNames,nil do ScoreWeights[i]=GetPref("PercentScoreWeight"..n) end
		CurGhostData={}
		CachedScore={}
		CurScore={}
		CompareGhostData={}
		CompareScore={}
		StepIndex={}
		JudgeCounts={}
		RivalJudgeCounts={}
		GhostDisplayText={}
		CurGhostDataCourse={}
		CompareGhostDataCourse={}
	end,
	
	InitClock=function(s)
		--unused
	end,

	Load=function(pn) --Starting a song
		local pd=GetSysConfig().EnableRivals and Rival.Load(pn) or {}
		CurGhostData[pn]={}
		CompareGhostData[pn]=pd and pd.Ghost and Ghost.Unpack(pd.Ghost) or {}
		CachedScore[pn]=0
		CompareScore[pn]=0
		StepIndex[pn]=1
		JudgeCounts[pn]={} for j=1,9 do JudgeCounts[pn][j]=0 end
		RivalJudgeCounts[pn]={} for j=1,9 do RivalJudgeCounts[pn][j]=0 end
	end,

	LoadCourse=function(pn) --Starting a course.
		local pd=GetSysConfig().EnableRivals and Rival.Load(pn) or {}
		CurGhostDataCourse[pn]={}
		CompareGhostDataCourse[pn]=pd and pd.Ghost or {}
		CachedScore[pn]=0
		CompareScore[pn]=0
		StepIndex[pn]=1
		JudgeCounts[pn]={} for j=1,9 do JudgeCounts[pn][j]=0 end
		RivalJudgeCounts[pn]={} for j=1,9 do RivalJudgeCounts[pn][j]=0 end

		Ghost.NextCourseSong(pn)
	end,

	NextCourseSong=function(pn)
		local song=CourseSongIndex()+1
		if song>1 then
			--save prev
			CurGhostDataCourse[pn][song-1]=Ghost.Pack(CurGhostData[pn])
		end
		--load next
		CurGhostDataCourse[pn][song]={}
		CurGhostData[pn]={}
		local pd=CompareGhostDataCourse[pn][song]
		CompareGhostData[pn]=pd and Ghost.Unpack(pd) or {}
	end,

	InitScore=function(s,pn)
		s:effectclock("beat")
		if CurScore then CurScore[pn]=s end
		-- NOTE: commented out to use the built-in score display since we aren't using ghostdata right now.
		--if (stepsStats and stepsStats[pn] and stepsStats[pn].MaxDP or 0)>0 then s:zoom(0) end --hide the object because i'm using my own one isntead
	end,

	--ghost text, hooked from PlayerOptions text object.
	InitText=function(s,pn)
		s:aux(0) --use aux to store next position in table
		s:effectclock("beat")
		GhostDisplayText[pn]=s
	end,

	UpdateText=function(s,pn) --Run on each frame.

		--TODO: fix jitter
		local formatdp=function(d) --(dd)
			--local d=math.max(dd,0)
			if math.abs(d)>14 then
				local maxdp=(stepsStats and stepsStats[pn] and stepsStats[pn].MaxDP or 1)
				return (d>0 and "+" or "")..FormatPercentScore(d/maxdp)
			else
				return (d>0 and "+" or "")..sprintf("%d",d)
			end
		end

		local pnr=math.mod(pn,2)+1 --opposite player
		if GAMESTATE:GetNumPlayersEnabled()==2 
				and CurSteps(1)==CurSteps(2) 
				and CurRival[pn] and CurRival[pn].UUID==
				GetProfile(pnr).UUID
			then
			
			--versus / same chart
			local dp=CachedScore[pn]
			local dpr=CachedScore[pnr]
--			s:settext(formatdp(dp-dpr))
		else
			local si=s:getaux() --step index
			local cgd=CompareGhostData[pn]
			local curcgd=cgd[si]
			local nextcgd=cgd[si+1]

			--see if we crossed the next rival step
			--store the table index in aux
			--if nextcgd and nextcgd[1] and s:GetSecsIntoEffect()+s:GetEffectDelta()>=nextcgd[1] then
			if nextcgd and nextcgd[1] and s:GetSecsIntoEffect()>=nextcgd[1] then
				s:aux(si+1) s:finishtweening()
				local n=nextcgd[2] --judge
				RivalJudgeCounts[pn][n]=RivalJudgeCounts[pn][n]+1
				CompareScore[pn]=nextcgd[3]

				local d=CachedScore[pn]-nextcgd[3]
--				s:settext(formatdp(d))
			elseif curcgd and curcgd[3] then
				local d=CachedScore[pn]-curcgd[3]
--				s:settext(formatdp(d))
			end


		end
	end,
	
	LifeTimeStep=function(pn,n) --ScoreDisplayLifeTime has bindings for each judgement INCLUDING HitMine.
		if not (CachedScore and CachedScore[pn]) or GetEnv("EditMode") or not (stepsStats and stepsStats[pn]) or stepsStats[pn].MaxDP<=0 or DeathState and DeathState[pn].Active then return end
	
		local dpscoring=stepsStats[pn].MaxDP>0
		local sw=ScoreWeights
		local dbs=CachedScore
		local cs=CurScore
		local scoredelta=dpscoring and sw[n] or sw[n]/stepsStats[pn].MaxDP

		local timestamp=CurScore[pn]:GetSecsIntoEffect()

		dbs[pn]=dbs[pn]+scoredelta

		local step={ timestamp, n, dbs[pn] }
		table.insert(CurGhostData[pn],step)
		JudgeCounts[pn][n]=JudgeCounts[pn][n]+1
		StepIndex[pn]=StepIndex[pn]+1

		Broadcast("GhostStepP"..pn)
	end,

	Step=function(pn,n) --fantastic-miss=1-6, hold=7, drop=8, mine=9
		if GAMESTATE:GetPlayMode()==PLAY_MODE_ONI or UsingModifier(pn,"lifetime") then return end --LifeTimeStep handles Survival mode (ie: ScoreDisplayLifeTime)
		--Percent only works if the max DP is known.
		if not (CachedScore and CachedScore[pn]) or GetEnv("EditMode") or not (stepsStats and stepsStats[pn]) or stepsStats[pn].MaxDP<=0 or DeathState and DeathState[pn].Active then return end

		local maxdp=stepsStats[pn].MaxDP
		local dpscoring=maxdp>0 --GetPref("DancePointsForOni")
		local sw=ScoreWeights
		local dbs=CachedScore
		local cs=CurScore
		local scoredelta=dpscoring and sw[n] or sw[n]/maxdp
		local curscore=dpscoring and cs[pn]:GetText() or UnformatPercentScore(cs[pn]:GetText())
		
		local timestamp=CurScore[pn]:GetSecsIntoEffect()

		--add step
		local addstep=function(pn,n)
			local step={ timestamp, n, dbs[pn] }
			table.insert(CurGhostData[pn],step)
			JudgeCounts[pn][n]=JudgeCounts[pn][n]+1
			StepIndex[pn]=StepIndex[pn]+1
		end
		if n<9 then
			dbs[pn]=dbs[pn]+scoredelta
			addstep(pn,n)
			--set the percent text ourself, ready for the next PollHitMine update.
			--After any hit judgement, the game updates the percent score on the next frame
			--Hitmine is assumed to occur if the score changes without any judgment fired on the frame before it.
--			cs[pn]:settext(dpscoring and math.max(0,dbs[pn]) or FormatPercentScore(math.max(0,dbs[pn])))
		else --HitMine
			--find out how many mines were hit, then record each of them.
			--only way in 3.95 is to note the DP discrepancy from what is expected,
			--thus, if any mines occur before (non-miss) notes, it's impossible to detect since the score display doesn't change (ie fall below 0)
			local nummineshit=math.round((curscore-dbs[pn])/scoredelta)
			dbs[pn]=curscore
			for i=1,nummineshit do addstep(pn,n) end
		end

		Broadcast("GhostStepP"..pn) --Send a signal to stats pane in SGP Underlay to update text.
	end,
	
	Die=function(pn)
		--When a player dies, record as such.
	
	
	end,
	
	GetData=function(pn,uuid) end,
	SetData=function(pn,data) end,
	
	Save=function() -- Evaluation firstupdate.
		assert(CachedScore)
		if not CachedScore then return end --workout and super-marathon mode crashes?

		ForeachPlayer(function(pn)
			if IsCourseMode() then CurGhostDataCourse[pn][table.getn(CurGhostDataCourse[pn])]=Ghost.Pack(CurGhostData[pn]) end --make sure last course song gets its ghost data saved
			--Always save rival data, but keep the kill-switch in case something goes wrong.
			if true or GetSysConfig().EnableRivals then Rival.Save(pn,(IsCourseMode() and CurGhostDataCourse or CurGhostData)[pn]) end
		end)

		CurGhostData=nil
		CurGhostDataCourse=nil
		CachedScore=nil
		CurScore=nil
		CompareGhostData=nil 
		CompareGhostDataCourse=nil
		CompareScore=nil 
		StepIndex=nil
		ScoreWeights=nil
		JudgeCounts=nil
		RivalJudgeCounts=nil
		GhostDisplayText=nil
	end,
	
	Prune=function(path,dtype)
		--TODO
		
--		1. Get play data
--		2. Populate temp table, add Index field
--		3. table.sort by play date/score
--		4. return top N entries of sorted table
--		
	
	end,
	
	--Packing functions: Currently this uses a modified BCD.
	--intermediate format: "+q/t,j,s/t,j,s/t,j,s/..." (time,judge,score - per step)

	Pack=function(ghostdata)
		local rou=round
		local n=next
		local ts=tostring

		local q=16 --quantisation factor; default this to 16 to minimise quantisation jitter

		local data={}

		data[1]=ts(q)
		for i=1,table.getn(ghostdata) do
			local step=ghostdata[i]
			j=i+1 --quantise
			for s,v in n,step,nil do step[s]=rou(v,s+2) end --quantise the step time. in other words: step[1]=round(step[1],2) step[3]=round(step[1],4) --step[2] (judge) is an integer already
			data[j]=ts(step[1]*q)..","..ts(step[2])..","..ts(step[3]) --tostring is used instead of sprintf because %f only gives you fixed decimal places (even for integers)
			--data[i]=ts(step[1])..","..ts(step[2])..","..ts(step[3]) --tostring is used instead of sprintf because %f only gives you fixed decimal places (even for integers)
		end
		return bcd.pack(join("/",data))
	end,
	Unpack=function(packeddata)
		local data=bcd.unpack(packeddata)
		if not string.find(data,",") then --if data=="" then
			--prevent a crash later on, in Ghost.UpdateText
			return {}
		else
			local sp=split
			local tn=tonumber
			local n=next
			local out={}

			local steps=sp("/",data)

			local start,q=1,1
			if not string.find(steps[1],",") then
				--found a quantisation header
				start=2
				q=tn(steps[1]) or 1
			end
			for i=start,table.getn(steps) do
				local step=steps[i]
				local s=sp(",",step)
				local j=i-(start-1)
				out[j]={}

				out[j][1]=(tn(s[1]) or 0)/q
				for k=2,table.getn(s) do out[j][k]=tn(s[k]) or 0 end
				--for k,v in n,s,nil do out[j][k]=tn(v) or 0 end
			end
			return out
		end
	end
}
