void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("who");
    g_Hooks.RegisterHook(Hooks::PickupObject::Materialize, @Materialize);
	g_Hooks.RegisterHook(Hooks::PickupObject::Collected, @Collected);
}

void MapInit()
{
	g_Game.PrecacheModel(szModel);
}

const string szModel = "models/misc/highlight.mdl";

HookReturnCode Materialize( CBaseEntity@ pPickup )
{
    uint uiSkin = 0;
    if(string(pPickup.pev.classname).StartsWith("item_"))
        uiSkin = 2;
    else if (string(pPickup.pev.classname).StartsWith("ammo_"))
        uiSkin = 1;
    
    CBaseEntity@ pEntity = g_EntityFuncs.Create("info_target", pPickup.pev.absmin, g_vecZero, false);
    pEntity.pev.targetname = "HILIGHT_" + pPickup.edict().serialnumber;
    pEntity.pev.skin = uiSkin;
    g_EntityFuncs.SetModel(@pEntity, szModel);

    @pEntity = g_EntityFuncs.Create("info_target", pPickup.pev.absmax, Vector(0, 180, 0), false);
    pEntity.pev.targetname = "HILIGHT_" + pPickup.edict().serialnumber;
    pEntity.pev.skin = uiSkin;
    g_EntityFuncs.SetModel(@pEntity, szModel);

    return HOOK_CONTINUE;
}

HookReturnCode Collected( CBaseEntity@ pPickup, CBaseEntity@ pOther )
{
    string szTarget = "HILIGHT_" + pPickup.edict().serialnumber;

    CBaseEntity@ pEntity = null;
    while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, szTarget)) !is null)
    {
        g_EntityFuncs.Remove(@pEntity);
    }
    return HOOK_CONTINUE;
}