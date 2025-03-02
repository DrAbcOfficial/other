const uint iRoundTime = 300;
const uint iWaitTime = 30;
const uint iSchedulerDelayTime = 5;
const uint iSeekerFreezeTime = 10;
const array<string> arySeekerEquip = {
    "weapon_crowbar",
    "weapon_grapple",
    "weapon_eagle",
    "ammo_357"
};
enum PLAYER_CLASS{
    HIDER_CLASS = 17,
    SEEKDER_CLASS = 18
}

CCVar@ pHiderModel = CCVar("hns_hider_model", "can",   "Hider player model.",  ConCommandFlag::None, null);
CCVar@ pSeekerModel = CCVar("hns_seeker_model", "barney",    "Seeker player model.", ConCommandFlag::None, null);
CCVar@ pHiderSpeed = CCVar("hns_hider_speed", 270,   "Hider player.",  ConCommandFlag::None, null);
CCVar@ pSeekerSpeed = CCVar("hns_seeker_speed", 380,    "Seeker player.", ConCommandFlag::None, null);
CCVar@ pSeekerStealth = CCVar("hns_seeker_stealth", 1,    "Seeker player.", ConCommandFlag::None, null);

CScheduledFunction@ pScheduler = null;
uint iWaitCounter = iWaitTime;
uint iTimeCounter;
HUDTextParams pHudMessage;
array<EHandle> aryInSeekerlist = {};
void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
    g_Module.ScriptInfo.SetContactInfo("?");
}
void MapInit(){
    g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
    g_Hooks.RegisterHook(Hooks::Player::PlayerPostThink, @PlayerPostThink);

    g_SurvivalMode.EnableMapSupport();
    g_SurvivalMode.SetDelayBeforeStart(0.0f);
    g_SurvivalMode.Disable();
    g_SurvivalMode.SetStartOn(false);

    g_Game.PrecacheModel("models/player/" + pHiderModel.GetString() + "/" + pHiderModel.GetString() + ".mdl");
    g_Game.PrecacheGeneric("models/player/" + pHiderModel.GetString() + "/" +  pHiderModel.GetString() + ".mdl");
    g_Game.PrecacheModel("models/player/" + pSeekerModel.GetString() + "/" + pSeekerModel.GetString() + ".mdl");
    g_Game.PrecacheGeneric("models/player/" + pSeekerModel.GetString() + "/" + pSeekerModel.GetString() + ".mdl");

    pHudMessage.x - -1.0;
    pHudMessage.y = 0.02;
    pHudMessage.r1 = pHudMessage.r2 = 255;
    pHudMessage.g1 = pHudMessage.g2 = 255;
    pHudMessage.b1 = pHudMessage.b2 = 255;
    pHudMessage.a1 = pHudMessage.a2 = 255;
    pHudMessage.fadeinTime = pHudMessage.fadeoutTime = 0.0f;
    pHudMessage.holdTime = 1.0f;
    pHudMessage.fxTime = 0.0f;
    pHudMessage.channel = 2;

    @pScheduler = g_Scheduler.SetInterval("WaitingPlayer", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES);
}
void WaitingPlayer(){
    uint iAllPlayer = 0;
    for(uint i = 0; i <= 33; i++){
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(g_EntityFuncs.IndexEnt(i)));
        if(@pPlayer is null || !pPlayer.IsConnected())
            continue;
        iAllPlayer++;
    }
    string szPoints = ".";
    for(int i = 0; i < int(g_Engine.time) % 3; i++){
        szPoints += ".";
    }
    if(iAllPlayer < 2)
        g_PlayerFuncs.HudMessageAll(pHudMessage, "Waiting for player" + szPoints +"\n");
    else{
        iWaitCounter--;
        g_PlayerFuncs.HudMessageAll(pHudMessage, "Waiting for " + iWaitCounter + " start" + szPoints + "\n");
    }
    if(iWaitCounter <= 0){
        g_Scheduler.RemoveTimer(@pScheduler);
        StartRound();
    }
}
void StartRound(){
    g_SurvivalMode.Enable(true);
    g_SurvivalMode.Activate(true);
    RestartRound();
}
void MapActivate(){
    CBaseEntity@ pEntity = null;
    while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "info_player_start")) !is null){
        CreateNewSpawn(@pEntity);
    }
    @pEntity = null;
    while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "info_player_deathmatch")) !is null){
        CreateNewSpawn(@pEntity);
    }
    @pEntity = null;
    while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "weapon_*")) !is null){
        g_EntityFuncs.Remove(@pEntity);
    }
    @pEntity = null;
    while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "ammo_*")) !is null){
        g_EntityFuncs.Remove(@pEntity);
    }
    @pEntity = null;
    while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "item_*")) !is null){
        g_EntityFuncs.Remove(@pEntity);
    }
}
void CreateNewSpawn(CBaseEntity@ pEntity){
    CBaseEntity@ pNew = g_EntityFuncs.Create("info_player_dm2", pEntity.pev.origin, pEntity.pev.angles, false);
    pNew.pev.targetname = pEntity.pev.targetname;
	pNew.pev.maxs = pEntity.pev.maxs;
	pNew.pev.mins = pEntity.pev.mins;
	pNew.pev.origin = pEntity.pev.origin;
	pNew.pev.angles = pEntity.pev.angles;
	pNew.pev.target = pEntity.pev.target;
	pNew.pev.scale = pEntity.pev.scale;
}
CBasePlayer@ EHandle2Player(EHandle e){
    return cast<CBasePlayer@>(e.GetEntity());
}
void ReFillRndList(CBasePlayer@ pIgnore = null){
    aryInSeekerlist.resize(0);
    for(uint i = 0; i <= 33; i++){
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(g_EntityFuncs.IndexEnt(i)));
        if(@pPlayer is null || !pPlayer.IsConnected())
            continue;
        if(@pPlayer is @pIgnore)
            continue;
        aryInSeekerlist.insertLast(EHandle(@pPlayer));
    }
}
void DeletInvalidRndList(){
    for(uint i = 0; i < aryInSeekerlist.length(); i++){
        if(!aryInSeekerlist[i].IsValid())
            aryInSeekerlist.removeAt(i);
    }
}
CBasePlayer@ GetRndSeeker(){
    uint index = Math.RandomLong(0, aryInSeekerlist.length()-1);
    CBasePlayer@ pSeeker = EHandle2Player(aryInSeekerlist[index]);
    SetSeeker(@pSeeker);
    aryInSeekerlist.removeAt(index);
    return @pSeeker;
}
void SetSeeker(CBasePlayer@ pSeeker){
    pSeeker.SetClassification(SEEKDER_CLASS);
    for(uint j = 0; j < arySeekerEquip.length(); j++){
        pSeeker.GiveNamedItem(arySeekerEquip[j]);
    }
    pSeeker.pev.takedamage = DAMAGE_NO;
    pSeeker.pev.max_health = Math.FLOAT_MAX;
}
void SetHider(CBasePlayer@ pHider){
    pHider.pev.takedamage = DAMAGE_AIM;
    pHider.pev.deadflag = DEAD_NO;
    pHider.pev.max_health = 100;
    pHider.pev.health = pHider.pev.max_health;
    pHider.SetClassification(HIDER_CLASS);
    pHider.RemoveAllItems(false);
}
void RefreshHUD(){
    for(uint i = 0; i <= 33; i++){
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(g_EntityFuncs.IndexEnt(i)));
        if(@pPlayer is null || !pPlayer.IsConnected())
            continue;
        pPlayer.SendScoreInfo();
    }
}
void DelayRstartRound(){
    g_Scheduler.RemoveTimer(@pScheduler);
    @pScheduler = g_Scheduler.SetTimeout("RestartRound", iSchedulerDelayTime);
}
void RestartRound(){
    g_PlayerFuncs.RespawnAllPlayers(true, true);
    uint iPlayerCount = 0;
    for(uint i = 0; i <= 33; i++){
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(g_EntityFuncs.IndexEnt(i)));
        if(@pPlayer is null || !pPlayer.IsConnected())
            continue;
        SetHider(@pPlayer);
        iPlayerCount++;
    }
    iTimeCounter = iRoundTime;
    DeletInvalidRndList();
    if(aryInSeekerlist.length() <= 0)
        ReFillRndList();
    if(aryInSeekerlist.length() < 2){
        CBasePlayer@ pSeekerFirst = EHandle2Player(aryInSeekerlist[0]);
        SetSeeker(@pSeekerFirst);
        ReFillRndList(@pSeekerFirst);
        if(iPlayerCount > 2)
            GetRndSeeker();
    }
    else{
        GetRndSeeker();
        if(iPlayerCount > 2)
            GetRndSeeker();
    }
    RefreshHUD();
    g_Scheduler.RemoveTimer(@pScheduler);
    @pScheduler = g_Scheduler.SetInterval("RoundScheduler", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES);
}
void RoundScheduler(){
    uint iAliveHider = 0;
    uint iAliveSeeker = 0;
    uint iAllPlayer = 0;
    iTimeCounter--;
    string szOutPut = "";
    for(uint i = 0; i <= 33; i++){
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(g_EntityFuncs.IndexEnt(i)));
        if(@pPlayer is null || !pPlayer.IsConnected())
            continue;
        if(pPlayer.IsAlive()){
            switch(pPlayer.Classify()){
                case HIDER_CLASS:{
                    iAliveHider++;
                    pPlayer.RemoveAllItems(false);
                    pPlayer.SetOverriddenPlayerModel(pHiderModel.GetString());
                    break;
                }
                case SEEKDER_CLASS:{
                    iAliveSeeker++;
                    pPlayer.pev.health = pPlayer.pev.max_health;
                    pPlayer.SetOverriddenPlayerModel(pSeekerModel.GetString());

                    if(iRoundTime - iTimeCounter <= iSeekerFreezeTime){
                        pPlayer.SetMaxSpeedOverride(0);
                        szOutPut += "Seeker freezing for " + (int(iSeekerFreezeTime) - int(iRoundTime) + int(iTimeCounter)) + "s.\n";
                    }
                    else
                        pPlayer.SetMaxSpeedOverride(int(pSeekerSpeed.GetFloat()));
                    break;
                }
                default:{
                    pPlayer.Killed(pPlayer.pev, GIB_ALWAYS);
                    break;
                }
            }
        }
        iAllPlayer++;
    }
    if(iAllPlayer < 2){
        g_Scheduler.RemoveTimer(@pScheduler);
        @pScheduler = g_Scheduler.SetInterval("WaitingPlayer", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES);
        RestartRound();
        return;
    }
    else
        szOutPut +=  "Time Left: " + iTimeCounter + "\nAlive hiders: " + iAliveHider + "\n";
        
    if(iAliveHider <= 0){
        g_PlayerFuncs.CenterPrintAll("Seeker won!\n");
        DelayRstartRound();
        return;
    }
    else if(iTimeCounter <= 0){
        g_PlayerFuncs.CenterPrintAll("Hider won!\n");
        DelayRstartRound();
        return;
    }else if(iAliveSeeker <= 0){
        g_PlayerFuncs.CenterPrintAll("Seeker quited, round restarted..\n");
        DelayRstartRound();
    }
    g_PlayerFuncs.HudMessageAll(pHudMessage, szOutPut);
}
HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ){
    aryInSeekerlist.insertLast(EHandle(@pPlayer));
	return HOOK_CONTINUE;
}
HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer){
    pPlayer.SetClassification(HIDER_CLASS);
    pPlayer.SetMaxSpeedOverride(int(pHiderSpeed.GetFloat()));
    pPlayer.RemoveAllItems(false);
    return HOOK_CONTINUE;
}
HookReturnCode PlayerPostThink(CBasePlayer@ pPlayer){
    if(pPlayer.Classify() == SEEKDER_CLASS && pSeekerStealth.GetFloat() > 0){
        pPlayer.pev.rendermode = kRenderTransAlpha;
        pPlayer.pev.renderamt = Math.clamp(0.0, 1.0, pPlayer.pev.velocity.Length() / pSeekerSpeed.GetFloat()) * 255;
    }
    else{
        pPlayer.pev.rendermode = kRenderNormal;
        pPlayer.pev.renderamt = 255;
    }
    return HOOK_CONTINUE;
}