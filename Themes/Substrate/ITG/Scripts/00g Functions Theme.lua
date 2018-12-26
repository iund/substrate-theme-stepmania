--Theme
function ThemeName() return split("/",THEME:GetPath(2,'','_blank.png'))[3] end
function ThemeVersionString() return not THEME_VERSION and "v?" or sprintf("v%d.%d%s",THEME_VERSION.MAJOR or 0, THEME_VERSION.MINOR or 0, THEME_VERSION.SUFFIX_STR or "") end
function LineNumbers(from,to) local out='' for i=from,to do out=out..(i>from and ','..tostring(i) or tostring(i)) end return out end --Returns (for example) "1,2,3,4" for use with LineNames= in metrics.ini
function Metric(sec,key,raw) return raw and THEME:GetMetric(sec,key) or loadstring("return "..THEME:GetMetric(sec,key))() end
function DisplayAspect() return (SCREEN_WIDTH/SCREEN_HEIGHT)/(4/3) end
function FitScreenToAspect(s) s:zoomx(DisplayAspect()*(4/3)/(16/9)) s:addx((427-SCREEN_CENTER_X)/(DisplayAspect()*(4/3))) end --CBA to make new graphics for 4:3
function IgnoreWindow(str) local pref=SM_VERSION==3.95 and "IgnoredMessageWindows" or "IgnoredDialogs" local list=GetPref(pref) SetPref(pref,string.find(list,str) and list or list..","..str) end
function UnIgnoreWindow(str) local pref=SM_VERSION==3.95 and "IgnoredMessageWindows" or "IgnoredDialogs" SetPref(pref,string.gsub(string.gsub(GetPref(pref),str,""),",,",",")) end

function GetPath(path,ec,direct) local p=THEME:GetPath(ec,"",(direct and "" or "../../../")..path) return not string.find(p,'_missing') and p or false end
function GetPathG(path,direct) return ThemeManager.GetPathG and THEME:GetPathG("",(direct and "" or "../../../")..path) or GetPath(path,EC_GRAPHICS,direct) end
function GetPathB(path,direct) return ThemeManager.GetPathB and THEME:GetPathB("",(direct and "" or "../../../")..path) or GetPath(path,EC_BGANIMATIONS,direct) end
function GetPathS(path,direct) return ThemeManager.GetPathS and THEME:GetPathS("",(direct and "" or "../../../")..path) or GetPath(path,EC_SOUNDS,direct) end

function MapLanguageSymbol()
--recurse through table to string.gsub 


end

--[[
GetPath(type) matches these file extensions:

static const CString ElementCategoryNames[] = {
	"BGAnimations",
	"Fonts",
	"Graphics",
	"Numbers",
	"Sounds",
	"Other"
};
			static const char *masks[NUM_ElementCategory][13] = {
				{ "", "actor", "xml", NULL },
				{ "ini", NULL },
				{ "xml", "actor", "sprite", "png", "jpg", "bmp", "gif","avi", "mpg", "mpeg", "txt", "", NULL},
				{ "png", NULL },
				{ "mp3", "ogg", "wav", NULL },
				{ "*", NULL },
			};		
--]]
