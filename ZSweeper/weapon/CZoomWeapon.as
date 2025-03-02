mixin class CZoomWeapon{
    //delegate
    void StartZoom() override{
        CBaseWeapon::StartZoom();
        SetThink( ThinkFunction(this.Think) );
        self.pev.nextthink = g_Engine.time;
    }
    void Think(){
        CBaseWeapon::UpdateBeam();
    }
}