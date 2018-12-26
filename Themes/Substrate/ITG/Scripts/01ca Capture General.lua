Capture={
	ActorFrame={
	--Recursively capture an actorframe's children into a lua table.
		CaptureInternal=function(s) --Recursive capture for SM 3.95
			local c=CaptureState
			local done=c.done

			if table.find(done,s) then return end

			local size=stack.size
			local top=stack.top
			local push=stack.push
			local pop=stack.pop
			local afs=c.afstack
			local cs=c.childrenStack

			push(done,s)
			
			--when last child in a node is captured, back out:
			while top(cs)==0 do pop(afs) pop(cs) end
			cs[size(cs)]=top(cs)-1

			--recursively add children of current node
			if IsActorFrame(s) then
				local ch={}
				local node={self=s,children=ch}
				push(top(afs),node)
				push(afs,ch) --push the current node's subtable on the stack ready to be filled
				push(cs,s:GetNumChildren()) --keep track of how far away the last child is
				setmetatable(node,{__index=ch})
				s:propagate(1) c.root.self:playcommand("Capture") s:propagate(0)
			else
				push(top(afs),s)
			end
		end,
		CaptureImmediateInternal=function(s) --simpler and faster variant for oITG/SM5
			local c=CaptureState
			local done=c.done

			local push=stack.push
			local afs=c.afstack
			local tafs=stack.top(afs)
			local cs=c.childrenStack

			push(done,s)

			local tcs=stack.top(cs)
			if tcs==0 then return --for some reason, it runs twice, and spits out command defined twice warnings
			elseif IsActorFrame(s) then
				local pop=stack.pop
				local ch={}
				local t={self=s,children=ch}
				push(tafs,t)
				push(cs,s:GetNumChildren())
				push(afs,ch)
				setmetatable(t,{__index=ch})
				if ActorFrame.RunCommandsOnChildren then
					s:RunCommandsOnChildren(Capture.ActorFrame.CaptureImmediateInternal)
				else --Propagate is very very slow in SM5. Maybe it's deliberate? (because its deprecated)
					s:addcommand("CaptureImmediate",Capture.ActorFrame.CaptureImmediateInternal)
					s:propagate(1) s:playcommand("CaptureImmediate") s:propagate(0)
				end
				pop(afs)
				pop(cs)
			else
				push(tafs,s)
			end
			cs[stack.size(cs)]=tcs-1
		end,
		GetChildren=function(s,flattable)
			local ch={}
			local r={self=s,children=ch}
			local d={}
			CaptureState={ --wrap all these in a table to minimise global namespace pollution.
				       --SM doesn't pass any local values to the next Capture call, so we have to track its state in global variables.
				root=r,
				done=d,
				afstack={ch},
				childrenStack={s:GetNumChildren()}
			}

			if ActorFrame.RunCommandsOnChildren then
				s:RunCommandsOnChildren(Capture.ActorFrame.CaptureImmediateInternal)
			elseif Actor.addcommand then
				local ignore=GetPref("IgnoredMessageWindows")
				if not string.find(ignore,"COMMAND_DEFINED_TWICE") then SetPref("IgnoredMessageWindows",ignore..",COMMAND_DEFINED_TWICE") end --suppress command defined twice popups
				s:addcommand("CaptureImmediate",Capture.ActorFrame.CaptureImmediateInternal)
				s:propagate(1) s:playcommand("CaptureImmediate") s:propagate(0)
			else
				s:propagate(1) s:playcommand("Capture") s:propagate(0)
				for _,o in next,CaptureState.done,nil do if IsActorFrame(o) then o:propagate(0) end end --clean up
			end
			setmetatable(r,{__index=ch})

			CaptureState=nil
			return flattable and d or r
		end,
		RunCommandsOnImmediateChildren=function(s,cmds) if ActorFrame.RunCommandsOnChildren then s:RunCommandsOnChildren(cmds) else s:propagate(1) cmds(s) s:propagate(0) end end,
		RunCommandsOnAllChildren=function(s,cmds) local tab=Capture.ActorFrame.GetChildren(s,true) for i=1,table.getn(tab) do cmds(tab[i]) end end,
		ApplyPNToChildren=function(s,pn) Capture.ActorFrame.RunCommandsOnAllChildren(s,function(s) s:aux(pn) end) end,
		AutoActor={ApplyPNToChildren=function(s,pn) if IsActorFrame(s) then Capture.ActorFrame.ApplyPNToChildren(s,pn) else s:aux(pn) end end}
	},
	AutoActor=function(s) return IsActorFrame(s) and Capture.ActorFrame.GetChildren(s) or s end,
}