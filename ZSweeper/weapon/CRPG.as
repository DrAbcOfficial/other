final class CRPG : CBaseWeapon, CZoomWeapon{
    CRPG(){
        szPModel = "models/p_rpg.mdl";
        szWModel = "models/w_rpg.mdl";
        szShellModel = "models/shell.mdl";

        aryFireSound = {"weapons/glauncher.wav", "weapons/glauncher2.wav"};
        
        szProjName = Global::Const::szRPGShot;
        szAnimation = "rpg";

        flIdleTime = 5;
        flPrimaryTime = 1.35f;

        iPellet = 1;
        iDefaultGive = 3;
        iMaxAmmo1 = 3;
        iSlot = 1;
        iPosition = 20;
        iShellSound = TE_BOUNCE_SHELL;
        vecAccurency = Vector(64, 64, 0);
    }
}