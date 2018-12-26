-- Crash handler. Display call stack of function that crashed.

-- Written by Mercury, 2017

--[[
crash={}
crash={
	reasons={},
	stack={},
	funcnames={},
	getsysversion=function() return _VERSION..", sm "..(SM_VERSION or 3.95)..(OPENITG and ", OpenITG "..(GetProductVer and GetProductVer() or "") or "")..", theme build "..(THEME_BUILD_NUMBER or 0) end,
	dump=function()
		local to=function(v) return type(v)=="string" and "\""..v.."\"" or tostring(v) end
		local cat=function(list,delim) local out="" for i,r in next,list,nil do out=out..(i==1 and "" or delim or "\n")..r end return out end

		local callstack={}
		for i,c in next,crash.stack,nil do
			local args={} for i=1,c[2].n do args[i]=to(c[2][i]) end
			callstack[table.getn(crash.stack)+1-i]=crash.funcnames[c[1] ].."("..cat(args,",")..")"		
		end
		return
			"Crash reason:\n"..cat(crash.reasons,"\n")
			.."\n\nCall stack:\n"..cat(callstack,"\n")
			.."\n\nSys version:\n"..crash.getsysversion()
	end,
	
	--pick which handler to use: fatal or non-fatal (nonfatal might leave the game variables in a limbo state)
	
	handle=function() if SCREENMAN then SCREENMAN:SystemMessage(crash.dump(),true) else error(crash.dump() or "test") end end,
	--handle=function() if SCREENMAN then SCREENMAN:SetNewScreen("ScreenCrashMessage") else error(crash.dump() or "test") end end,

	handler={
		attach=function(t,subtn,ign)
			local find=function(t,val) for k,v in next,t,nil do if val==v then return val end end return false end
			if t==_G then return _G
			elseif find(ign,t) then return t
			elseif type(t)=='table' then
				local att=crash.handler.attach
				local out={} for name,scope in next,t,nil do out[name]=att(scope,subtn.."."..tostring(name),ign) end return out
			elseif type(t)=='function' and t~=table.getn and t~=table.concat then
				local st=crash.stack
				local g=table.getn
				local pop=table.remove
				local push=table.insert
				--local pop=function(t) t[g(t)]=nil end
				--local push=function(t,v) t[g(t)+1]=v end
				local p=pcall
				local up=unpack

				crash.funcnames[t]=subtn
				return function(...)
					push(st,{t,arg})
					--local success,ret=p(t,up(arg))

					--only returns the first value. unpack adds so much overhead but it'll have to do.
					
					local success,ret=p(function() return t(up(arg)) end)
					if success then
						pop(st) return ret
					else
						push(crash.reasons,ret) crash.handle() pop(crash.reasons) pop(st)
						return nil
					end
				end
			else return t
			end
		end,
		register=function(scope,ign)
			Trace("registering crash handler")
			local att=crash.handler.attach
			local count=0
			for n,t in next,scope,nil do
				if t~=scope and t~=crash and t~=next and t~=tostring and t~=pcall and t~=unpack and t~=Serialize then scope[n]=att(scope[n],n,ign) count=count+1 end
			end
			Trace(count.." functions registered")
		end
	},
	force=function()
		assert(false,"force crash") --the error reporting interface has not crashed")
	end
}
--]]

--usage:
--crash.handler.register(_G,{TitleMenuEntries,string,ComboColours}) --second arg is a list of functions/tables to ignore.
