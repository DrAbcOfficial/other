#include "CMagumShot"
#include "CPistolShot"
#include "CRifleShot"
#include "CShotShot"
#include "CRPGShot"

enum ProjectileFlags{
    PJ_NONE = 0,
    PJ_PIERCE = 1 << 0,
    PJ_EXPLODE = 1 << 1
}

mixin class CBaseProjectile {
    protected string szModel;
    protected int iDamage = 0;
    protected int iFlag = ProjectileFlags::PJ_NONE;
    protected int iRadius = 0;
    protected float flScale = 0.5;
    protected EHandle pRealOwner;
    protected Vector vecSizeMax = Vector(4, 4, 4);
    protected Vector vecSizeMin = Vector(-4, -4, -4);
    protected Vector vecVelocity;
    CBaseEntity@ GetOwner(){
        return pRealOwner.GetEntity();
    }
    void Precache(){
        g_Game.PrecacheModel(szModel);
        g_Game.PrecacheGeneric(szModel);
        BaseClass.Precache();
    }
    void Spawn(){
        if(self.pev.owner is null)
            return;
        BaseClass.Spawn();
        g_EntityFuncs.SetModel(self, szModel);
        g_EntityFuncs.SetSize(self.pev, vecSizeMin, vecSizeMax);
        pRealOwner = EHandle(g_EntityFuncs.Instance(self.pev.owner));
        self.pev.movetype = MOVETYPE_FLYMISSILE;
        self.pev.solid = SOLID_TRIGGER;
        self.pev.renderamt = 155;
        self.pev.scale = flScale;
        self.pev.rendermode = kRenderTransAdd;
        vecVelocity = self.pev.velocity;
        //im soooo evil
        self.SetClassification(CLASS_PLAYER);
        if(iFlag & ProjectileFlags::PJ_PIERCE != 0){
            SetThink(ThinkFunction(@FlyThink));
            self.pev.nextthink = g_Engine.time;
        }
    }
    void FlyThink(){
        self.pev.velocity = vecVelocity;
        self.pev.nextthink = g_Engine.time;
    }
    void DeathThink(){
        self.pev.scale = Math.max(0, self.pev.scale - 0.05);
        if(self.pev.scale <= 0){
            g_EntityFuncs.Remove(self);
            return;
        }
        self.pev.nextthink = g_Engine.time + 0.01;
    }
    void Destory(){
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
        self.pev.velocity = g_vecZero;
        if(iFlag & ProjectileFlags::PJ_EXPLODE != 0){
            g_EntityFuncs.CreateExplosion(self.pev.origin, g_vecZero, pRealOwner.GetEntity().edict(), 0, false);
            g_WeaponFuncs.RadiusDamage(self.pev.origin, self.pev, self.pev, 
                iDamage, iRadius, CLASS_NONE, DMG_BLAST);
            g_EntityFuncs.Remove(self);
        }
        else{
            SetThink(ThinkFunction(@DeathThink));
            self.pev.nextthink = g_Engine.time + 0.01;
        }
    }
    void Touch(CBaseEntity@ pEntity){
        if(@pEntity is null)
            return;
        if(pEntity.pev.modelindex == self.pev.modelindex)
            return;
        if(pEntity.pev.solid <= SOLID_TRIGGER)
            return;
        //if(pEntity.pev.groupinfo == self.pev.groupinfo)
        //    return;
        if(@pEntity is pRealOwner.GetEntity())
            return;
        //闪避
        if(pEntity.IsPlayer() && pEntity.pev.flags & FL_ONGROUND == 0)
            return;
        //受伤
        pEntity.TakeDamage(self.pev, GetOwner().pev, iDamage, DMG_BULLET);
        //飙血
        if(g_Utility.ShouldShowBlood(pEntity.BloodColor())){
            if(iFlag & ProjectileFlags::PJ_PIERCE != 0)
                g_Utility.BloodStream(self.pev.origin, g_Utility.RandomBloodVector(), pEntity.BloodColor(), iDamage);
            g_Utility.BloodDrips(self.pev.origin, g_Utility.RandomBloodVector(), pEntity.BloodColor(), iDamage);
        }
        else{
            g_Utility.Ricochet(self.pev.origin, 2);
        }
        //憋他妈挡我!
        if(iFlag & ProjectileFlags::PJ_PIERCE != 0)
            @self.pev.owner = pEntity.edict();
        else{
            Destory();
            return;
        }
        if(pEntity.IsBSPModel())
            Destory();
    }
}