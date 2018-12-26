-- Dump _G
function DumpG(t) 
	local format=string.format
	local rep=string.rep
	local concat=table.concat
	local dump=string.dump
	local obj={
		string=function(v) return format("%q",v) end,
		number=tostring, boolean=tostring, ["nil"]=tostring,
		userdata=tostring, thread=tostring,
		["function"]=function() return "nil --[[ function ]]" end,
	}
	obj.table=function(t,d) --table, depth
		local out={"{"}
		local i=2
		for n,v in next,t,nil do if  v~=_G then out[i]=format("%s[%s]=%s,",rep("\t",d+1),obj[type(n)](n,d+1),obj[type(v)](v,d+1)) i=i+1 end end
		out[i]=rep("\t",d).."}"
		return concat(out,"\r\n")
	end
	return "return "..obj.table(t,0)
end
--if _G then Trace("Dump _G "..DumpG(_G)) end

-- Debug loud function calling
local newfunc=(function()
	local next_=next
	local type_=type
	local tostring_=tostring
	local concat_=table.concat
	local print_=print
	local unpack_=unpack
	local dump_=table.dump
	local attach attach=function(t,n)
		if t==_G or n=="_G" then return _G
		elseif
		--if
		type_(t)=='table' and t~=string then
			local out={} for i,v in next_,t,nil do out[i]=v==_G and _G or attach(v,n.."."..tostring_(i)) end
			return out
		elseif type_(t)=='function' then
		print_("attach "..n)
			return function(...)
				local strs={} for i=1,arg.n do strs[i]=tostring_(arg[i]) end
				local callname=n.."("..concat_(strs,",")..")"
				print_(callname)
				local ret=t(unpack_(arg))
				--print_("- "..callname.." returned "..tostring_(ret))
				print_("- "..callname.." returned "..(type_(ret)=="table" and dump_(ret) or tostring_(ret)))
				return ret
			end
		else return t
		end
	end
	return attach
end)()
----------------------------

	--Write lots of debug output.
if PREFSMAN then -- and PREFSMAN:GetPreference("Timestamping") then
--print("attaching debug output functions")
--for n,t in next,_G,nil do _G[n]=newfunc(_G[n],n) end

--for n,t in next,OptionsList,nil do OptionsList[n]=newfunc(OptionsList[n],"OptionsList."..n) end
--print("done attaching debug output functions")
end



			--[[
				local resumefunc=coroutine.wrap(func)
				local resumevalues=coroutine.yield(returnvalues)
				resumefunc(resumevalues)
			--]]

