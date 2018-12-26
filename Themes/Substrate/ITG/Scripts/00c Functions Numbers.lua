---Numbers
function number(n) return tonumber(tostring(n)) or loadstring('return '..n)() or 0 end
function inc(num,dir) num=num+(dir or 1) end
function within(num,min,max) return num>=min and num<=max end
function round(num,places) local factor=10^(places or 6) return math.floor(0.5+(num*factor))/factor end
function math.round(num) return math.floor(num+0.5) end

function floor(num) return x-math.mod(x,1) end --round towards 0
function quantize(num,step) return math.round(num/step)*step end
function clamp(val,low,high) return math.max( low, math.min(val,high) ) end
function wrap(val,m,max) local min=m or 0 return within(val,min,max) and val or math.mod(val+(max-min+1)-min,max-min+1)+min end
function scale(x,la,ha,lb,hb) return (x-la)*(hb-lb)/(ha-la)+lb end
function randomrange(min,max) return min+(math.random()*(max-min)) end
function UnformatPercentScore(str) return tonumber(string.sub(str,1,-2))/100 end

function ordinal(num) --21 -> "21st", 13 -> "13th", etc.
	--NOTE: assumes english ordinal numbers, you'd need rules to make it correct for other languages

	local n=math.abs(num)
	local last=math.mod(n,10)
	return
		tostring(n)..(
			math.mod(math.floor(n/10),10)~=1 and (
				last==1 and "st"
				or last==2 and "nd"
				or last==3 and "rd"
			) or "th"
		)
end

MATH_PI=math.pi
MATH_PI_TRIG=math.pi/360
MATH_ROOT2=math.sqrt(2)

--dtan is used for my custom grooveradar, the others are provided for convience sake
math.dtan=function(deg) return math.tan(deg*MATH_PI_TRIG) end
math.dcos=function(deg) return math.cos(deg*MATH_PI_TRIG) end
math.dsin=function(deg) return math.sin(deg*MATH_PI_TRIG) end

--commonly used for tweens
math.adcos=function(deg) return math.abs(math.dcos(deg)) end
math.adsin=function(deg) return math.abs(math.dsin(deg)) end
math.adtan=function(deg) return math.abs(math.dtan(deg)) end

--special float values that lua 5.0 doesn't give you
math.nan=0/0
math.huge=1/0
