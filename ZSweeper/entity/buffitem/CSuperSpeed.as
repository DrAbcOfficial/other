final class CSuperSpeedItem: CBuffItem{
    CSuperSpeedItem(){
        flMantainTime = 30.0f;
    }
    void SetBuff(CBasePlayer@ pPlayer) override{
        pPlayer.SetMaxSpeedOverride(400);
        @pScheduler = g_Scheduler.SetTimeout(this, "ResetTimerDelegate", this.flMantainTime, EHandle(pPlayer));
    }
    void ResetBuff(CBasePlayer@ pPlayer) override{
        pPlayer.SetMaxSpeedOverride(-1);
    }
}
final class CSuperSpeed: CBaseBuff{
    CSuperSpeed(){
        @pItem = CSuperSpeedItem();
    }
}