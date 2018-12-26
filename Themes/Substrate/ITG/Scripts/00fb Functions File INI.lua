File.Ini={
	Read=function(handle) --INI to table
		local nextline=string.gfind
		local nextline=File.ReadLine

		local sub=string.sub
		local find=string.find
		local len=string.len
		local getn=table.getn

		local stack={
			size=table.getn,
			pop=function(t) t[table.getn(t)]=nil end,
			push=function(t,v) t[table.getn(t)+1]=v end,
			top=function(t) return t[table.getn(t)] end,
		}

		t={}
		st={}
		stack.push(st,t)

		local cur_section=""
		
		for indent,line in string.gfind(handle,"(\t-)(.-)\n") do --for line in nextline,handle,nil do
			local nest=len(indent)
			local lev=stack.size(st)

			if nest<lev then
				stack.pop(st)
				--exit out
			elseif nest>lev then
				stack.push(st,{})
				--nest
			end

			if sub(line,1,1) == '[' then
				cur_section = sub(line,2,len(line)-1)
				--DEBUG:
				Trace(table.dump(st))
				Trace(stack.size(st))
				--
				stack.top(st)[cur_section]={}
			elseif find(line,'=') then
				local pos = find(line,'=')
				local left = sub(line,1,pos-1)
				local right = sub(line,pos+1,-1)
				stack.top(st)[cur_section][left] = right
			end
		end
		return t
	end,

	Write=function(handle,table)
		local next=next
		local write=File.WriteLine
		local ins=function(line) print(line) end --local ins=function(line) write(handle,line) end
		for name,list in next,table,nil do
			ins("["..name.."]")
			for field,value in next,list,nil do
				ins(field.."="..value)
			end
		end
	end
}

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

if false then

local function tabledump(t)
	--do the actual table to string work here. Serialize just adds "return " before it
	local format=string.format
	local rep=string.rep
	local concat=table.concat
	local dump=string.dump
	local nx=next
	local ty=type
	local obj={}
	obj={
		string=function(v) return format("%q",v) end, number=tostring, boolean=tostring, ["nil"]=tostring,
		userdata=function(v,d) 
			local name=(debug and debug.getmetatable(v).heirarchy.Actor or getmetatable(v) and getmetatable(v).GetName) and v:GetName() or ""

--			if SCREENMAN and GetScreen() then
--				--Get child name. Horribly slow, but it's only used for debugging so it's fine.
--				local cn=ChildNames
--				print(type(t))
--				print(t.self and 'yes' or 'no')
--				if t.self then for i=1,table.getn(cn) do if v==t.self:GetChild(cn[i]) then name=cn[i] end end end
--			end
			return (debug and debug.getmetatable(v).heirarchy.Actor or getmetatable(v).GetX) and
				format("nil --[[ %s (%s) x=%d y=%d aux=%d name=%s ]]",
				tostring(v),
				IsActorFrame(v) and v:GetNumChildren().." children" or 
				(debug and debug.getmetatable(v).heirarchy.BitmapText or getmetatable(v).GetText)
					and format("%q",v:GetText()) or "",
				v:GetX(), v:GetY(), v:getaux(), name
				)
			or format("nil --[[ metatable=%s ]]", obj.table(debug and debug.getmetatable(v).__index or getmetatable(v),d))
		end,
--		["function"]=function(v) return sprintf("nil --[[ function: %s]]",tostring(v(t))) end,
		["function"]=function() return "nil --[[ function ]]" end,
--		["function"]=function(v) return string.format("loadstring(%q)",string.dump(v)) end,
		table=function(t,d) --table, depth
			if debug and debug.getmetatable(t) and debug.getmetatable(t).heirarchy then return obj.userdata(t,d+1) end --format("nil --[[ %s ]]",tostring(t)) end --obj.string(debug.getmetatable(t).__index.class) end --obj[type(debug.getmetatable(t))](debug.getmetatable(t),d+1) end		
			local out={"{"}
			local i=2
			for n,v in nx,t,nil do out[i]=format("%s[%s]=%s,",rep("\t",d+1),obj[ty(n)](n,d+1),obj[ty(v)](v,d+1)) i=i+1 end
			out[i]=rep("\t",d).."}"
			return concat(out,"\r\n")
		end
	}
	return obj.table(t,0)
end

local function Serialize(t) return "return "..tabledump(t) end

error(tabledump(File.Ini.Read([[
[foo]
bar=hello
bas=world
bqe=today
	[nest]
	nest1=nest2
	nest3=nest4
	unused
	#comment
[zxc]
qwer=what
asdf=time
zxcv=is
uiop=it
]])))
end
--[[example:


	File.Ini.Write(h,
	{
		foo={
			bar="hello",
			bas="world",
			bqe="today"
		},
		zxc={
			qwer="what",
			asdf="time",
			zxcv="is",
			uiop="it"
		}
	
	})
	
	populates a file with:
	
		[foo]
		bar=hello
		bas=world
		bqe=today
		[zxc]
		qwer=what
		asdf=time
		zxcv=is
		uiop=it

--]]
