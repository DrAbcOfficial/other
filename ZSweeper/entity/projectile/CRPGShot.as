final class CRPGShot : CBaseProjectile, IBaseProjectile, ScriptBaseEntity{
    CRPGShot(){
        szModel = "models/dm_hotline/proj_red.mdl";
        iDamage = 125;
        flScale = 0.55;
        iFlag = ProjectileFlags::PJ_EXPLODE;
    }
}