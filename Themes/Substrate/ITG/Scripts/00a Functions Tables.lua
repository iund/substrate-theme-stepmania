---Tables
table.copy=function(from,to,dontoverwrite) if not to then local to={} end for n,v in next,table.duplicate(from),nil do to[n]=dontoverwrite and to[n] or v end return to end
table.duplicate=function(t)
	local dup,IsTable,out=table.duplicate,IsTable,setmetatable({},getmetatable(t))
	for k,v in next,t,nil do out[k]=IsTable(v) and dup(v) or v end
	return out
end
--table.duplicate=function(t) return loadstring(table.dump(t))() end --duplicate a whole table. tab2=tab1 in lua will just assign an alias.

table.findkey=function(tab,val) for k,v in next,tab,nil do if val==v then return k end end return false end
table.find=function(t,val) for k,v in next,t,nil do if val==v then return val end end return false end
table.invert=function(t) local out={} for k,v in next,t,nil do out[v]=k end return out end
table.merge=function(...) 
	local out={}
	for i=1,table.getn(arg) do
--	for _,t in next,arg,nil do
--		Trace("table.merge arg="..tostring(t))
		for k,v in next,arg[i],nil do
			if not out[k] then out[k]=v end
		end
	end
	return out
end --merge multiple tables together, prioritising the earlier tables.
table.concati=function(...) local out={} local ins=table.insert for i=1,arg.n do for _,v in next,arg[i],nil do ins(out,v) end end return out end
table.clear=function(t) for n,_ in next,t,nil do t[n]=nil end end --because tab={} doesn't always work
table.namedgetn=function(t) local i=0 for _,__ in next,t,nil do i=i+1 end return i end
table.dmerge=function(...) return table.duplicate(table.merge(unpack(arg))) end -- merge multiple tables together but don't just clone the pointers
table.dedup=function(t,match) local out={} for k,v in next,t,nil do if v~=match then out[k]=v end end return out end --table entry deduplication for top level only
table.sub=function(t,start,finish) local out={} for i=start or 1,finish or table.getn(t) do out[1+i-start]=t[i] end return out end --like string.sub, but for tables
isBeforeNested=function(a,b) local g=table.getn if type(a)=="table" then local i=1 while i<g(a) and a[i]==b[i] do i=i+1 end return isBeforeNested(a[i],b[i]) else return a<b end end --Nested comparison to use with table.sort(tab,isBeforeNested)

table.stablesort=function(t1,before)
	local t2={}
	for i=1,table.getn(t1) do t2[i]={i,t1[i]} end
	local b=function(a,b) return before(a[2],b[2]) or a[2]==b[2] and a[1]<b[1] end
	table.sort(t2,b)
	local out={}
	for i=1,table.getn(t2) do out[t2[i][1]]=t2[i][2] end
	return out
--[[
	local t2={}
	for i=1,table.getn(t1) do t2[i]={i=i,v=t1[i]} end
	table.sort(t2,function(a,b) return before(a.v,b.v) or a.v==b.v and a.i<b.i end)
	local out={}
	for i=1,table.getn(t2) do out[t2[i].i]=t2[i].v end
	return out
]]
end

table.gsub=function(t,replace,with) --recursive string.gsub
	local g=string.gsub
	local e=function(s) return g(s,"[%%%]%^%-$().[*+?]","%%%1") end
	local obj={string=function(v) return g(v,e(replace),e(with)) end, number=function(v) return v end, boolean=function(v) return v end}
	obj.table=function(t) local out={} for n,v in next,t,nil do out[n]=obj[type(v)](v) end return out end
	return obj.table(t)
end
