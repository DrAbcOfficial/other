#include "entity/CViewer"
#include "entity/projectile/IBaseProjectile"
#include "entity/projectile/CBaseProjectile"

#include "weapon/CBaseWeapon"
#include "weapon/melee/CBaseMelee"
#include "weapon/melee/IBaseMelee"

#include "buffmanager"
#include "entity/buffitem/CBaseBuff"

namespace Debugger{
    void Log(string s){
        g_Log.PrintF("[DM HOTLINE]" + s + "\n");
    }
}
namespace Global{
    namespace Const{
        const string szViewerName = "info_hotline_viewer";

        const string szMagnumShot = "proj_hotline_mugnum";
        const string szPistolShot = "proj_hotline_pistol";
        const string szRifleShot = "proj_hotline_rifle";
        const string szShotShot = "proj_hotline_shot";
        const string szRPGShot = "proj_hotline_rpg";

        const string szSuperSpeed = "item_hotline_superspeed";

        const string szMagnum = "weapon_hotline_magnum";
        const string szDoubleShot = "weapon_hotline_doubleshot";
        const string szPistol = "weapon_hotline_pistol";
        const string szRifle = "weapon_hotline_rifle";
        const string szShotgun = "weapon_hotline_shotgun";
        const string szMachineGun = "weapon_hotline_machinegun";
        const string szSniper = "weapon_hotline_sniper";
        const string szRPG = "weapon_hotline_rpg";

        const string szCrowbar = "weapon_hotline_crowbar";

        const string szSprDir = "dm_hotline";
        //视角高度
        const float flViewDistance = 400.0f;
    }
    array<EHandle> aryViewEntity(33);
    array<float> aryZoomedPlayer(33);
}

void PluginInit(){
    g_Module.ScriptInfo.SetAuthor( "drabc" );
    g_Module.ScriptInfo.SetContactInfo( "dmdmdm" );
}
void MapInit(){
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
    g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
    g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );

    EntityRegister( "CViewer", Global::Const::szViewerName);
    EntityRegister( "CPistolShot", Global::Const::szPistolShot);
    EntityRegister( "CRifleShot", Global::Const::szRifleShot);
    EntityRegister( "CShotShot", Global::Const::szShotShot);
    EntityRegister( "CMagumShot", Global::Const::szMagnumShot);
    EntityRegister( "CRPGShot", Global::Const::szRPGShot);

    EntityRegister( "CSuperSpeed", Global::Const::szSuperSpeed);

    WeaponRegister("CDoubleShot", Global::Const::szDoubleShot);
    WeaponRegister("CMagnum", Global::Const::szMagnum);
    WeaponRegister("CPistol", Global::Const::szPistol);
    WeaponRegister("CRifle", Global::Const::szRifle);
    WeaponRegister("CShotGun", Global::Const::szShotgun);
    WeaponRegister("CMachineGun", Global::Const::szMachineGun);
    WeaponRegister("CSniper", Global::Const::szSniper);
    WeaponRegister("CRPG", Global::Const::szRPG);

    WeaponRegister("CCrowbar", Global::Const::szCrowbar, true);

    /**
        DEBUG
    **/
    g_EngineFuncs.CVarSetFloat("sv_maxspeed", 400);
    
}
HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ){
    //新建buff
    @aryBuffFactorys[pPlayer.entindex()] = CBuffManager(@pPlayer);
    return HOOK_CONTINUE;
}
HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer ){
    //设置视角到天上
    Vector vecOrigin = pPlayer.pev.origin;
    CBaseEntity@ pEntity = g_EntityFuncs.Create(Global::Const::szViewerName, 
        vecOrigin, Vector(90, 0 , 0), false, pPlayer.edict());
    Global::aryViewEntity[pPlayer.entindex()] = EHandle(@pEntity);
    //设置移动速度
    pPlayer.SetMaxSpeed(270);
    //清空buff
    CBuffManager@ pManager = GetBuffManager(pPlayer);
    if(pManager !is null)
        pManager.Clear();
    else
        @aryBuffFactorys[pPlayer.entindex()] = CBuffManager(@pPlayer);
    
    return HOOK_CONTINUE;
}
HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int bitGib ){
    if(Global::aryViewEntity[pPlayer.entindex()].IsValid())
        g_EntityFuncs.Remove(Global::aryViewEntity[pPlayer.entindex()]);
    return HOOK_CONTINUE;
}
HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer ){
    pPlayer.SetItemPickupTimes(0);
    pPlayer.SetViewMode(ViewMode_ThirdPerson);
    return HOOK_CONTINUE;
}
void WeaponRegister(string szClassName, string szWeaponName, bool bMelle = false){
    g_CustomEntityFuncs.RegisterCustomEntity( szClassName, szWeaponName );
    g_ItemRegistry.RegisterWeapon( szWeaponName, Global::Const::szSprDir, bMelle ? "" : szWeaponName);
    g_Game.PrecacheOther(szWeaponName);
}
void EntityRegister(string szClassName, string szEntityName){
    g_CustomEntityFuncs.RegisterCustomEntity( szClassName, szEntityName );
    g_Game.PrecacheOther(szEntityName);
}