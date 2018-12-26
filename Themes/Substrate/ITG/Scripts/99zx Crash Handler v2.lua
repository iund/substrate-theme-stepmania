-- Crash handler. Display call stack of function that crashed.

-- Written by Mercury, 2017

-- [[

if BitmapText then BitmapText.settext_unprotected=BitmapText.settext end

crash=(function()
	local next_=next
	local type_=type
	local tostring_=tostring
	local getn_=table.getn
	local concat_=table.concat
	local remove_=table.remove
	local insert_=table.insert
	local pcall_=pcall
	local unpack_=unpack
	local SystemMessage_=ScreenManager.SystemMessage
	local SetNewScreen_=ScreenManager.SetNewScreen
	local error_=error
	local GetProductVer_=GetProductVer or function() return "" end
	local print_=print
	local Trace_=Trace

	local c={
		reasons={},
		stack={},
		funcnames={},
		getsysversion=function() return _VERSION..", sm "..(SM_VERSION or 3.95)..(OPENITG and ", OpenITG "..(GetProductVer_ and GetProductVer_() or "") or "")..", theme build "..(THEME_BUILD_NUMBER or 0) end,
	}
	c.dump=function()
		local to=function(v) return type_(v)=="string" and "\""..v.."\"" or tostring_(v) end
		local cat=function(list,delim) local out="" for i,r in next_,list,nil do out=out..(i==1 and "" or delim or "\n")..r end return out end

		local callstack={}
		local size=getn_(c.stack)
		local fn=c.funcnames
		for i,c in next_,c.stack,nil do
			local args={} for i=1,c[2].n do args[i]=tostring_(c[2][i]) end
			callstack[size+1-i]=fn[c[1]].."("..concat_(args,",")..")"		
		end
		return
			"Crash reason:\n"..cat(c.reasons,"\n")
			.."\n\nCall stack:\n"..cat(callstack,"\n")
			.."\n\nSys version:\n"..c.getsysversion()
	end

	--pick which handler to use: fatal or non-fatal (nonfatal might leave the game variables in a limbo state)

	c.handle=function() if SCREENMAN then SystemMessage_(SCREENMAN,c.dump(),true) else error_(c.dump() or "test") end end
	--c.handle=function() if SCREENMAN then SetNewScreen_(SCREENMAN,"Crash") else error_(c.dump() or "test") end end

	c.handler={}
	c.handler.attach=function(obj,objname,ignorelist)
		local find=function(obj,val) for k,v in next_,obj,nil do if val==v then return true end end return false end
		if obj==_G then return _G
		elseif find(ignorelist,obj) then return obj
		elseif type_(obj)=='table' then
			-- [[
			local out={}
			for name,scope in next_,obj,nil do out[name]=c.handler.attach(scope,objname.."."..tostring_(name),ignorelist) end
			return out
			--]]

			--for name,scope in next_,obj,nil do scope=c.handler.attach(scope,objname.."."..tostring_(name),ignorelist) end
			--return scope
		elseif type_(obj)=='function' then

			print_("c.handler.attach("..objname..")")

			local st=c.stack
			local handle_=c.handle
			c.funcnames[obj]=objname
			
			return function(...)
				--BUG: seems to only return the first value. unpack adds so much overhead but it'll have to do.

				--debug:
				--[[
				local strs={} for i=1,arg.n do strs[i]=tostring_(arg[i]) end
				local callname=objname.."("..concat_(strs,",")..")"
				print_(callname)
				--]]
				--Trace_(tostring_(objname))

				insert_(st,{obj,arg})
				local success,ret=pcall_(function() print_(objname) return obj(unpack_(arg)) end)
				if success then
					remove_(st) return ret
				else
					insert_(c.reasons,ret) handle_() remove_(c.reasons) remove_(st)
					return nil
				end
			end
		else return obj
		end
	end
	c.handler.register=function(scope,ignorelist)
		local Trace_=Trace
		local dump_=table.dump
		local il=ignorelist or {}
		Trace_("registering crash handler")
		local count=0
		for name,obj in next_,scope,nil do
			--Trace_(name.." "..type_(obj).." "..tostring_(obj))
			--if t~=scope and t~=crash and t~=next and t~=tostring and t~=pcall and t~=unpack and t~=Serialize then 
			scope[name]=c.handler.attach(scope[name],name,il)
			count=count+1
			-- end
		end
		Trace_(count.." functions registered")
		Trace_(dump_(Bool))
	end
	c.force=function()
		error_("force crash") --the error reporting interface has not crashed")
	end
	
	return c
end)()
