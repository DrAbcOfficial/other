final class CMagumShot : CBaseProjectile, IBaseProjectile, ScriptBaseEntity{
    CMagumShot(){
        szModel = "models/dm_hotline/proj_orange.mdl";
        iDamage = 65;
        iFlag = ProjectileFlags::PJ_PIERCE;
    }
}