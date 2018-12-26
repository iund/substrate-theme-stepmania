--Version detection (do this very early since a number of functions depend on these values)
LUA_VERSION=tonumber(string.sub(_VERSION,5,7))
SM_VERSION=(LUA_VERSION<5.1 or OPENITG) and 3.95 or 5.0
OPENITG_BETA3=OPENITG and GetProductVer and string.sub(GetProductVer(),1,5)=="beta3"

-- System cached variables

System = {
	Coins = 0,
	MemoryCardPresent = {false,false},
	MemoryCardState = {},
}
-- use for ScreenSystemLayer overlay objects

SystemOverlay={ CreditText={} }

GameEnv={}

EnvTable={} --replace GAMESTATE:Env() because sm5 is a bit broken

--Env().TempLuaEffectList={}

--Env().MemoryCardState={}
