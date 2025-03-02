#include "CSuperSpeed"

abstract class CBaseBuff : ScriptBasePlayerAmmoEntity{
    protected string szModelPath = "models/ball.mdl";
    protected CBuffItem@ pItem;
    void Spawn(){
        Precache();
        g_EntityFuncs.SetModel( self, szModelPath );
        BaseClass.Spawn();
        g_EntityFuncs.SetSize(self.pev, Vector( -4, -4, -4 ), Vector( 4, 4, 4 ));
    }
    void Precache(){
        BaseClass.Precache();
        g_Game.PrecacheModel(szModelPath);
        g_Game.PrecacheGeneric(szModelPath);
    }
    bool AddAmmo( CBaseEntity@ pOther ) { 
        if(pOther.IsAlive() && pOther.IsPlayer()){
            CBuffManager@ pManager = GetBuffManager(@pOther);
            if(pManager.Has(self.pev.classname))
                pManager.Remove(self.pev.classname, EHandle(pOther));
            pItem.SetBuff(cast<CBasePlayer@>(@pOther));
            pManager.Set(self.pev.classname, pItem);
            return true;
        }
        return false;
    }
}