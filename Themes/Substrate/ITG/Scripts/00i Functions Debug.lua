function ForceSongAndSteps()
	local song,steps
	repeat
		song=SONGMAN:GetRandomSong()

		local as=song:GetStepsByStepsType(
			StepsType
				[table.findkey(GameNames,CurGame)]
				[CurStyleName()]
		)
		steps=as[
				clamp(
					math.floor(
						math.random()*table.getn(as)
					)
					,1,table.getn(as)
				)
			]
	until song and steps

	GAMESTATE:SetCurrentSong(song)
	GAMESTATE:SetCurrentSteps(PLAYER_1,steps)

	return true
end

---Debug
function DumpActor(s,str) local out=(str or "").." "..(debug and table.dump(debug.getmetatable(s)) or "").." "..(table.dump(IsActorFrame(s) and Capture.ActorFrame.GetChildren(s) or {s})) Trace(out) return out end
function DumpTable(s,str) local out=(str or "").." "..(table.dump(s)) Trace(out) return out end
function LoudReturn(v,name) print(sprintf("LoudReturn: %s returns %s",tostring(name) or "",type(v)=='table' and table.dump(v) or tostring(v))) return v end

function DumpTableSteps(s,str)
	Trace(sprintf("%s:",str or "DumpTableSteps()"))
	for i=1,table.getn(s) do
		Trace(sprintf("\t%d: ",i))
		for k,v in next,getmetatable(s[i]),nil do
			Trace(sprintf("\t\t%s: %s",k,tostring(v(s[i]))))
		end
	end
end

function DumpList(n,delim,list) local strs={} for i=1,table.getn(list) do strs[i]=tostring(list[i]) end local out=n.."("..join(delim,strs)..")" Trace(out) return out end


--Uncomment this to get rid of lots of debug output
--function DumpActor() end function DumpTable() end

-- setup debug

-- LuaManager
--TraceInternal=Trace
--function Trace(str) local msg="Trace: "..str if GetPref('ShowLogOutput') then TraceInternal(msg) else print(msg) end end --Trace(str) --3.95

--function Trace(...) TraceInternal("Trace"..Serialize(arg)) arg[1]="Trace: "..arg[1] TraceInternal(sprintf(unpack(arg))) end

Trace=print