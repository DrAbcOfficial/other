class CBuffItem{
    CScheduledFunction@ pScheduler;
    float flMantainTime;

    void SetBuff(CBasePlayer@ pPlayer){};
    void ResetBuff(CBasePlayer@ pPlayer){};
    void ResetTimerDelegate(EHandle pPlayer){
        if(pPlayer.IsValid())
            ResetBuff(cast<CBasePlayer@>(pPlayer.GetEntity()));
    }
}
final class CBuffManager{
    private dictionary dicBuffs;
    private EHandle pOwner;
    CBuffManager(CBasePlayer@ pPlayer){
        pOwner = EHandle(pPlayer);
    }
    CBuffItem@ Get(string name){
        return cast<CBuffItem@>(dicBuffs[name]);
    }
    CBuffItem@ opIndex(string name){
        return Get(name);
    }
    void Set(string name, CBuffItem@ pItem){
        dicBuffs[name] = @pItem;
    }
    bool Has(string name){
        return Get(name) !is null;
    }
    void Remove(string name, EHandle pTarget){
        CBuffItem@ pItem = Get(name);
        pItem.ResetTimerDelegate(pTarget);
        g_Scheduler.RemoveTimer(pItem.pScheduler);
    }
    void Clear(){
        array<string>@ aryKeys = dicBuffs.getKeys();
        for(uint i = 0; i < aryKeys.length(); i++){
            Get(aryKeys[i]).ResetTimerDelegate(pOwner);
        }
        dicBuffs.clear();
    }
}
array<CBuffManager@> aryBuffFactorys(33);
CBuffManager@ GetBuffManager(CBaseEntity@ pEntity){
    return aryBuffFactorys[pEntity.entindex()];
}