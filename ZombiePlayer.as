void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("ahhh");
}

void MapInit(){	
	g_Game.PrecacheOther( "player" );
}

void Test(CBasePlayer@ pPlayer)
{
	CBaseEntity@ pEntity = g_EntityFuncs.Create("player", pPlayer.pev.origin, pPlayer.pev.angles, true, pPlayer.edict());
    pEntity.pev.flags = FL_MONSTER | FL_FAKECLIENT | FL_CLIENT;
	g_EntityFuncs.DispatchSpawn(pEntity.edict());
}

//test
CClientCommand g_HelloWorld("hello", "Hello", @helloword);
void helloword(const CCommand@ pArgs) 
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	Test(@pPlayer);
	
}
//test//