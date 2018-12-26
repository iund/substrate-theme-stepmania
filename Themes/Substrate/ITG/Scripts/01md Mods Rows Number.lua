-- Number types

RowType.Number=function(name,scale,fmtstr,var,step,range)
	--TODO, make suffix customisable?
	local handler = {
		get = function(r,pn) return var[pn] end,
		set = function(r,pn,val) var[pn] = val end,
		format = function(r,pn,num) return sprintf(fmtstr,num*scale) end
	}
	return RowType.Slider(name,handler,step,range,false)
end	

RowType.Time=function(name,var,step,range) --var is in seconds
	local handler = {
		get = function(r,pn) return var[pn] end,
		set = function(r,pn,val) var[pn] = val end,
		format = function(r,pn,val) return SecondsToMSS(val) end
	}
	return RowType.Slider(name,handler,step,range,false)
end

----

RowType.ModNumber=function(mod,scale,fmtstr,step,range,shared)
	local format=function(r,pn,val) return sprintf(fmtstr,val*scale) end
	local handler = {
		format = format,
		get = function(r,pn) local val=0 for i=range.min,range.max do if UsingModifier(pn,mod,i) then val=i end end return val end,
		set = function(r,pn,val) ApplyModifier(pn,mod,val) end
	}
	return RowType.Slider(mod,handler,step,range,shared)
end	

RowType.EnvTime=function(name,step,range)
	local handler = {
		get = function(r,pn) return GetProfile(pn)[name] or step.snap end,
		set = function(r,pn,val) GetProfile(pn)[name]=val end,
		format = function(r,pn,val) return SecondsToMSS(val) end
	}
	return RowType.Slider(name,handler,step,range,true)
end

RowType.EnvNumber=function(name,scale,fmtstr,step,range,shared)
	local format=function(r,pn,val) return sprintf(fmtstr,val*scale) end
	local handler = {
		get = function(r,pn) return GetProfile(pn)[name] or step.snap end,
		set = function(r,pn,val) GetProfile(pn)[name]=val end,
		format = format
	}
	return RowType.Slider(name,handler,step,range,shared)
end
