TalentsLoad_Ellis(iClient)
{
	SetEntProp(iClient,Prop_Data,"m_iMaxHealth", g_iEllisMaxHealth[iClient]);
	new currentHP = GetEntProp(iClient,Prop_Data,"m_iHealth");
	if(currentHP > g_iEllisMaxHealth[iClient])
		SetEntProp(iClient,Prop_Data,"m_iHealth", g_iEllisMaxHealth[iClient]);
	
	if(g_iMetalLevel[iClient]>0)
	{
		g_bDoesClientAttackFast[iClient] = true;
		g_bSomeoneAttacksFaster = true;
		push(iClient);
	}
	
	if(g_iMetalLevel[iClient] == 5)
	{
		g_bIsEllisLimitBreaking[iClient] = false;
		g_bCanEllisLimitBreak[iClient] = true;
		g_bEllisLimitBreakInCooldown[iClient] = false;
	}
	
	if(g_bSurvivorTalentsGivenThisRound[iClient] == false)
	{
		if((0.4 - (float(g_iWeaponsLevel[iClient])*0.08)) < g_fMaxLaserAccuracy)
		{
			g_fMaxLaserAccuracy = 0.4 - (float(g_iWeaponsLevel[iClient])*0.08);
			SetConVarFloat(FindConVar("upgrade_laser_sight_spread_factor"), g_fMaxLaserAccuracy);
		}
		
		g_iClientBindUses_1[iClient] = 3 - RoundToCeil(g_iMetalLevel[iClient] * 0.5);
	}
	
	
	
	if(g_iFireLevel[iClient] > 0)
	{
		if(g_iClientBindUses_2[iClient] < 3)
			g_iPID_EllisCharge3[iClient] = WriteParticle(iClient, "ellis_ulti_fire_charge3", 0.0);
		if(g_iClientBindUses_2[iClient] < 2)
			g_iPID_EllisCharge2[iClient] = WriteParticle(iClient, "ellis_ulti_fire_charge2", 0.0);
		if(g_iClientBindUses_2[iClient] < 1)
			g_iPID_EllisCharge1[iClient] = WriteParticle(iClient, "ellis_ulti_fire_charge1", 0.0);
	}
	
	if( (g_iClientLevel[iClient] - (g_iClientLevel[iClient] - g_iSkillPoints[iClient])) <= (g_iClientLevel[iClient] - 1))
		PrintToChat(iClient, "\x03[XPMod] \x05Your \x04Weapon Expert Talents \x05have been loaded.");
	else
		PrintToChat(iClient, "\x03[XPMod] \x05Your abilties will be automatically set as you level.");
		
	if(g_iOverLevel[iClient] > 0)
	{
		new iCurrentHealth = GetEntProp(iClient,Prop_Data,"m_iHealth");
		new iMaxHealth = GetEntProp(iClient,Prop_Data,"m_iMaxHealth");
		if(iCurrentHealth < (iMaxHealth - 20))
		{
			if(g_bEllisOverSpeedIncreased[iClient])
			{
				g_bEllisOverSpeedIncreased[iClient] = false;
				SetClientSpeed(iClient);
			}
		}
		else if(iCurrentHealth >= (iMaxHealth - 20))
		{
			if(g_bEllisOverSpeedIncreased[iClient] == false)
			{
				g_bEllisOverSpeedIncreased[iClient] = true;
				SetClientSpeed(iClient);
			}
		}
	}

	if(g_iJamminLevel[iClient] == 5)
	{
		g_iEllisJamminGrenadeCounter[iClient] = 0;
	}
	
	if(g_iWeaponsLevel[iClient] == 5)
	{
		g_bIsEllisInPrimaryCycle[iClient] = false;
		g_iEllisCurrentPrimarySlot[iClient] = 0;
		g_bCanEllisPrimaryCycle[iClient] = true;
		g_strEllisPrimarySlot1 = "empty";
		g_strEllisPrimarySlot2 = "empty";
		//PrintToChatAll("Ellis primary slots are now empty");
	}
}

OnGameFrame_Ellis(iClient)
{
	if(g_iMetalLevel[iClient] == 5)
	{
		new buttons = GetEntProp(iClient, Prop_Data, "m_nButtons", buttons);
		
		if(!(buttons & IN_SPEED) || !(buttons & IN_USE))
			g_bWalkAndUseToggler[iClient] = false;
			
		if((g_bWalkAndUseToggler[iClient] == false) && ((buttons & IN_SPEED) && (buttons & IN_USE)))
		{
			g_bWalkAndUseToggler[iClient] = true;
			if((g_bIsEllisLimitBreaking[iClient] == false) && (g_bCanEllisLimitBreak[iClient] == true))
			{
				g_bIsEllisLimitBreaking[iClient] = true;
				g_bCanEllisLimitBreak[iClient] = false;
				CreateTimer(5.0, TimerEllisLimitBreakReset, iClient, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(65.0, TimerEllisLimitBreakCooldown, iClient, TIMER_FLAG_NO_MAPCHANGE);
				PrintHintText(iClient, "Double fire rate for 5 seconds; Your weapon will break afterward!");
			}
			else if(g_bEllisLimitBreakInCooldown[iClient] == true)
			{
				PrintHintText(iClient, "LIMIT BREAK is still cooling down");
			}
		}
	}
	if(g_iWeaponsLevel[iClient] == 5)
	{
		if(g_bCanEllisPrimaryCycle[iClient] == true)
		{
			new buttons = GetEntProp(iClient, Prop_Data, "m_nButtons", buttons);
			
			if((buttons & IN_SPEED) && (buttons & IN_ZOOM))
			{
				decl String:currentweapon[512];
				GetClientWeapon(iClient, currentweapon, sizeof(currentweapon));
				//PrintToChatAll("Current Weapon is %s", currentweapon);
				if((StrContains(currentweapon,"shotgun",false) != -1) || (StrContains(currentweapon,"rifle",false) != -1) || (StrContains(currentweapon,"smg",false) != -1) || (StrContains(currentweapon,"sniper",false) != -1) || (StrContains(currentweapon,"launcher",false) != -1))
				{
					if((StrEqual(g_strEllisPrimarySlot1, "empty", false) == false) && (StrEqual(g_strEllisPrimarySlot2, "empty", false) == false))
					{
						//PrintToChatAll("String contains a gun");
						g_bCanEllisPrimaryCycle[iClient] = false;
						g_bIsEllisInPrimaryCycle[iClient] = true;
						CreateTimer(0.5, TimerEllisPrimaryCycleReset, iClient, TIMER_FLAG_NO_MAPCHANGE);
						//new ActiveWeaponID = GetEntDataEnt2(iClient, g_iOffset_ActiveWeapon);
						//PrintToChatAll("%s g_strEllisPrimarySlot2", g_strEllisPrimarySlot2[iClient]);
						//PrintToChatAll("%s g_strEllisPrimarySlot1", g_strEllisPrimarySlot1[iClient]);
						//new iOffset_Ammo = FindDataMapInfo(iClient,"m_iAmmo");
						//new CurrentClipAmmo = GetEntProp(ActiveWeaponID,Prop_Data,"m_iClip1");
						//PrintToChatAll("CurrentClipAmmo %d", CurrentClipAmmo);
						fnc_DeterminePrimaryWeapon(iClient);
						fnc_SaveAmmo(iClient);
						fnc_CycleWeapon(iClient);
						
						// if(g_iLaserUpgradeCounter[iClient] > 0)
						// {
						// 	g_iLaserUpgradeCounter[iClient]--;
						// }
						// if(g_iEllisCurrentPrimarySlot[iClient] == 0)
						// {
						// 	if((StrEqual(currentweapon, "weapon_rifle", false) == true) || (StrEqual(currentweapon, "weapon_rifle_ak47", false) == true) || (StrEqual(currentweapon, "weapon_rifle_sg552", false) == true) || (StrEqual(currentweapon, "weapon_rifle_desert", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 12);
						// 		g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
						// 	}
						// 	else if((StrEqual(currentweapon, "weapon_smg", false) == true) || (StrEqual(currentweapon, "weapon_smg_mp5", false) == true) || (StrEqual(currentweapon, "weapon_smg_silenced", false) == true) || (StrEqual(currentweapon, "weapon_rifle_desert", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 20);
						// 		g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
						// 	}
						// 	else if((StrEqual(currentweapon, "weapon_pumpshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_chrome", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 28);
						// 		g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
						// 	}
						// 	else if((StrEqual(currentweapon, "weapon_autoshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_spas", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 32);
						// 		g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
						// 	}
						// 	else if(StrEqual(currentweapon, "weapon_hunting_rifle", false) == true)
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 36);
						// 		g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
						// 	}
						// 	else if((StrEqual(currentweapon, "weapon_sniper_military", false) == true) || (StrEqual(currentweapon, "weapon_sniper_awp", false) == true) || (StrEqual(currentweapon, "weapon_sniper_scout", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 40);
						// 		g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
						// 	}
						// 	else if(StrEqual(currentweapon, "weapon_grenade_launcher", false) == true)
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 68);
						// 		g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
						// 	}
						// 	else if(StrEqual(currentweapon, "weapon_rifle_m60", false) == true)
						// 	{
						// 		//new iAmmo = GetEntData(iClient, iOffset_Ammo);
						// 		g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot1[iClient] = 0;
						// 	}
							
						// 	PrintToChatAll("g_iEllisPrimarySavedClipSlot1 %d", g_iEllisPrimarySavedClipSlot1[iClient]);
						// 	PrintToChatAll("g_iEllisPrimarySavedAmmoSlot1 %d", g_iEllisPrimarySavedAmmoSlot1[iClient]);
							
						// 	if(StrEqual(g_strEllisPrimarySlot2, "weapon_autoshotgun", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give autoshotgun");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 32, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_grenade_launcher", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give grenade_launcher");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 68, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_hunting_rifle", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give hunting_rifle");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 36, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_pumpshotgun", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give pumpshotgun");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 28, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_rifle", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give rifle");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 12, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_rifle_ak47", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give rifle_ak47");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 12, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_rifle_desert", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give rifle_desert");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 12, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_rifle_m60", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give rifle_m60");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		//SetEntData(iClient, iOffset_Ammo + 32, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_rifle_sg552", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give rifle_sg552");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 12, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_shotgun_chrome", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give shotgun_chrome");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 28, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_shotgun_spas", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give shotgun_spas");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 32, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_smg", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give smg");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 20, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_smg_mp5", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give smg_mp5");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 20, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_smg_silenced", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give smg_silenced");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 20, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_sniper_awp", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give sniper_awp");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 40, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_sniper_military", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give sniper_military");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 40, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot2, "weapon_sniper_scout", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 1;

						// 		RunCheatCommand(iClient, "give", "give sniper_scout");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot2[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 40, g_iEllisPrimarySavedAmmoSlot2[iClient]);
						// 	}
						// 	else if(StrContains(g_strEllisPrimarySlot2[iClient], "empty", false) != -1)
						// 	{
						// 		PrintToChatAll("The next primary slot is empty");
						// 	}
						// }
						// else if(g_iEllisCurrentPrimarySlot[iClient] == 1)
						// {
						// 	g_strEllisPrimarySlot2 = currentweapon;
						// 	PrintToChatAll("Current Weapon is %s", currentweapon);
						// 	PrintToChatAll("Second Check %s", g_strEllisPrimarySlot2[iClient]);
							
						// 	if((StrEqual(currentweapon, "weapon_rifle", false) == true) || (StrEqual(currentweapon, "weapon_rifle_ak47", false) == true) || (StrEqual(currentweapon, "weapon_rifle_sg552", false) == true) || (StrEqual(currentweapon, "weapon_rifle_desert", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 12);
						// 		g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
						// 	}
						// 	else if((StrEqual(currentweapon, "weapon_smg", false) == true) || (StrEqual(currentweapon, "weapon_smg_mp5", false) == true) || (StrEqual(currentweapon, "weapon_smg_silenced", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 20);
						// 		g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
						// 	}
						// 	else if((StrEqual(currentweapon, "weapon_pumpshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_chrome", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 28);
						// 		g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
						// 	}
						// 	else if((StrEqual(currentweapon, "weapon_autoshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_spas", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 32);
						// 		g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
						// 	}
						// 	else if(StrEqual(currentweapon, "weapon_hunting_rifle", false) == true)
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 36);
						// 		g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
						// 	}
						// 	else if((StrEqual(currentweapon, "weapon_sniper_military", false) == true) || (StrEqual(currentweapon, "weapon_sniper_awp", false) == true) || (StrEqual(currentweapon, "weapon_sniper_scout", false) == true))
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 40);
						// 		g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
						// 	}
						// 	else if(StrEqual(currentweapon, "weapon_grenade_launcher", false) == true)
						// 	{
						// 		new iAmmo = GetEntData(iClient, iOffset_Ammo + 68);
						// 		g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
						// 	}
						// 	else if(StrEqual(currentweapon, "weapon_rifle_m60", false) == true)
						// 	{
						// 		//new iAmmo = GetEntData(iClient, iOffset_Ammo);
						// 		g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
						// 		g_iEllisPrimarySavedAmmoSlot2[iClient] = 0;
						// 	}
							
						// 	PrintToChatAll("g_iEllisPrimarySavedClipSlot2 %d", g_iEllisPrimarySavedClipSlot2[iClient]);
						// 	PrintToChatAll("g_iEllisPrimarySavedAmmoSlot2 %d", g_iEllisPrimarySavedAmmoSlot2[iClient]);
							
						// 	if(StrEqual(g_strEllisPrimarySlot1, "weapon_autoshotgun", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give autoshotgun");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 32, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_grenade_launcher", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give grenade_launcher");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 68, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_hunting_rifle", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give hunting_rifle");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 36, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_pumpshotgun", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give pumpshotgun");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 28, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_rifle", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give rifle");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 12, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_rifle_ak47", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give rifle_ak47");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 12, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_rifle_desert", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give rifle_desert");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 12, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_rifle_m60", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give rifle_m60");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		//SetEntData(iClient, iOffset_Ammo + 32, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_rifle_sg552", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give rifle_sg552");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 12, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_shotgun_chrome", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give shotgun_chrome");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 28, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_shotgun_spas", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give shotgun_spas");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 32, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_smg", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give smg");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 20, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_smg_mp5", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give smg_mp5");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 20, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_smg_silenced", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give smg_silenced");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 20, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_sniper_awp", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give sniper_awp");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 40, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_sniper_military", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give sniper_military");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 40, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrEqual(g_strEllisPrimarySlot1, "weapon_sniper_scout", false) == true)
						// 	{
						// 		AcceptEntityInput(ActiveWeaponID);
						// 		g_iEllisCurrentPrimarySlot[iClient] = 0;

						// 		RunCheatCommand(iClient, "give", "give sniper_scout");
						// 		SetEntData(ActiveWeaponID, g_iOffset_Clip1, g_iEllisPrimarySavedClipSlot1[iClient], true);
						// 		SetEntData(iClient, iOffset_Ammo + 40, g_iEllisPrimarySavedAmmoSlot1[iClient]);
						// 	}
						// 	else if(StrContains(g_strEllisPrimarySlot1[iClient], "empty", false) != -1)
						// 	{
						// 		PrintToChatAll("The next primary slot is empty");
						// 	}
							
						// }
						
					}
					else
					{
						//PrintToChatAll("The next primary slot is empty");
					}
				}
			}
		}
	}
	if((g_iMetalLevel[iClient] > 0) || (g_iFireLevel[iClient] > 0))
	{
		new buttons = GetEntProp(iClient, Prop_Data, "m_nButtons", buttons);
		if((buttons & IN_RELOAD) && g_bClientIsReloading[iClient] == false && g_bForceReload[iClient] == false)
		{
			decl String:currentweapon[32];
			GetClientWeapon(iClient, currentweapon, sizeof(currentweapon));
			new ActiveWeaponID = GetEntDataEnt2(iClient, g_iOffset_ActiveWeapon);
			if (IsValidEntity(ActiveWeaponID) == false)
				return;
			new CurrentClipAmmo = GetEntProp(ActiveWeaponID,Prop_Data,"m_iClip1");
			if((((StrEqual(currentweapon, "weapon_rifle", false) == true) || (StrEqual(currentweapon, "weapon_rifle_sg552", false) == true)) && (CurrentClipAmmo == 50)) || ((StrEqual(currentweapon, "weapon_rifle_ak47", false) == true) && (CurrentClipAmmo == 40)) || ((StrEqual(currentweapon, "weapon_rifle_desert", false) == true) && (CurrentClipAmmo == 60)))
			{
				new iOffset_Ammo = FindDataMapInfo(iClient,"m_iAmmo");
				new iAmmo = GetEntData(iClient, iOffset_Ammo + 12);
				if(iAmmo > 0)
				{
					g_bForceReload[iClient] = true;
					g_iSavedClip[iClient] = CurrentClipAmmo;
					SetEntData(ActiveWeaponID, g_iOffset_Clip1, 0, true);
					SetEntData(iClient, iOffset_Ammo + 12, iAmmo + g_iSavedClip[iClient]);
				}
			}
			if(((StrEqual(currentweapon, "weapon_smg", false) == true) || (StrEqual(currentweapon, "weapon_smg_silenced", false) == true) || (StrEqual(currentweapon, "weapon_smg_mp5", false) == true)) && (CurrentClipAmmo == 50))
			{
				new iOffset_Ammo = FindDataMapInfo(iClient,"m_iAmmo");
				new iAmmo = GetEntData(iClient, iOffset_Ammo + 20);
				if(iAmmo > 0)
				{
					g_bForceReload[iClient] = true;
					g_iSavedClip[iClient] = CurrentClipAmmo;
					SetEntData(ActiveWeaponID, g_iOffset_Clip1, 0, true);
					SetEntData(iClient, iOffset_Ammo + 20, iAmmo + g_iSavedClip[iClient]);
				}
			}
			if((StrEqual(currentweapon, "weapon_hunting_rifle", false) == true) && (CurrentClipAmmo == 15))
			{
				new iOffset_Ammo = FindDataMapInfo(iClient,"m_iAmmo");
				new iAmmo = GetEntData(iClient, iOffset_Ammo + 36);
				if(iAmmo > 0)
				{
					g_bForceReload[iClient] = true;
					g_iSavedClip[iClient] = CurrentClipAmmo;
					SetEntData(ActiveWeaponID, g_iOffset_Clip1, 0, true);
					SetEntData(iClient, iOffset_Ammo + 36, iAmmo + g_iSavedClip[iClient]);
				}
			}
			if(((StrEqual(currentweapon, "weapon_sniper_awp", false) == true) && (CurrentClipAmmo == 20)) || ((StrEqual(currentweapon, "weapon_sniper_military", false) == true) && (CurrentClipAmmo == 30)) || ((StrEqual(currentweapon, "weapon_sniper_scout", false) == true) && (CurrentClipAmmo == 15)))
			{
				new iOffset_Ammo = FindDataMapInfo(iClient,"m_iAmmo");
				new iAmmo = GetEntData(iClient, iOffset_Ammo + 40);
				if(iAmmo > 0)
				{
					g_bForceReload[iClient] = true;
					g_iSavedClip[iClient] = CurrentClipAmmo;
					SetEntData(ActiveWeaponID, g_iOffset_Clip1, 0, true);
					SetEntData(iClient, iOffset_Ammo + 40, iAmmo + g_iSavedClip[iClient]);
				}
			}
		}
	}
}

OGFSurvivorReload_Ellis(iClient, const char[] currentweapon, ActiveWeaponID, CurrentClipAmmo, iOffset_Ammo)
{
	if((StrEqual(g_strEllisPrimarySlot1, "empty", false) == true) || (StrEqual(g_strEllisPrimarySlot2, "empty", false) == true))
	{
		fnc_DeterminePrimaryWeapon(iClient);
		if((StrContains(g_strCurrentWeapon, "rifle", false) != -1) || (StrContains(g_strCurrentWeapon, "smg", false) != -1) || (StrContains(g_strCurrentWeapon, "shotgun", false) != -1) || (StrContains(g_strCurrentWeapon, "launcher", false) != -1) || (StrContains(g_strCurrentWeapon, "sniper", false) != -1))
		{
			fnc_SaveAmmo(iClient);
		}
	}
	if((((StrEqual(currentweapon, "weapon_rifle", false) == true) || (StrEqual(currentweapon, "weapon_rifle_sg552", false) == true)) && (CurrentClipAmmo == 50)) || ((StrEqual(currentweapon, "weapon_rifle_ak47", false) == true) && (CurrentClipAmmo == 40)) || ((StrEqual(currentweapon, "weapon_rifle_desert", false) == true) && (CurrentClipAmmo == 60)))
	{
		new iAmmo = GetEntData(iClient, iOffset_Ammo + 12);	//for rifle (+12)
		if(iAmmo >= (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6)), true);
			SetEntData(iClient, iOffset_Ammo + 12, iAmmo - (g_iMetalLevel[iClient]*4) - (g_iFireLevel[iClient]*6));
		}
		else if(iAmmo < (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			new NewAmmo = ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - iAmmo);
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - NewAmmo), true);
			SetEntData(iClient, iOffset_Ammo + 12, 0);
		}
		g_bClientIsReloading[iClient] = false;
		g_iReloadFrameCounter[iClient] = 0;
	}
	else if(((StrEqual(currentweapon, "weapon_smg", false) == true) || (StrEqual(currentweapon, "weapon_smg_silenced", false) == true) || (StrEqual(currentweapon, "weapon_smg_mp5", false) == true)) && (CurrentClipAmmo == 50))
	{
		new iAmmo = GetEntData(iClient, iOffset_Ammo + 20);	//for smg (+20)
		if(iAmmo >= (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6)), true);
			SetEntData(iClient, iOffset_Ammo + 20, iAmmo - (g_iMetalLevel[iClient]*4) - (g_iFireLevel[iClient]*6));
		}
		else if(iAmmo < (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			new NewAmmo = ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - iAmmo);
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - NewAmmo)), true);
			SetEntData(iClient, iOffset_Ammo + 20, 0);
		}
		g_bClientIsReloading[iClient] = false;
		g_iReloadFrameCounter[iClient] = 0;
	}
	else if((StrEqual(currentweapon, "weapon_hunting_rifle", false) == true) && (CurrentClipAmmo == 15))
	{
		new iAmmo = GetEntData(iClient, iOffset_Ammo + 36);	//for hunting rifle (+36)
		if(iAmmo >= (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6)), true);
			SetEntData(iClient, iOffset_Ammo + 36, iAmmo - (g_iMetalLevel[iClient]*4) - (g_iFireLevel[iClient]*6));
		}
		else if(iAmmo < (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			new NewAmmo = ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - iAmmo);
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - NewAmmo)), true);
			SetEntData(iClient, iOffset_Ammo + 36, 0);
		}
		g_bClientIsReloading[iClient] = false;
		g_iReloadFrameCounter[iClient] = 0;
	}
	else if(((StrEqual(currentweapon, "weapon_sniper_awp", false) == true) && (CurrentClipAmmo == 20)) || ((StrEqual(currentweapon, "weapon_sniper_military", false) == true) && (CurrentClipAmmo == 30)) || ((StrEqual(currentweapon, "weapon_sniper_scout", false) == true) && (CurrentClipAmmo == 15)))
	{
		new iAmmo = GetEntData(iClient, iOffset_Ammo + 40);	//for AWP, Scout, and Military Sniper (+40)
		if(iAmmo >= (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6)), true);
			SetEntData(iClient, iOffset_Ammo + 40, iAmmo - (g_iMetalLevel[iClient]*4) - (g_iFireLevel[iClient]*6));
		}
		else if(iAmmo < (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			new NewAmmo = ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - iAmmo);
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - NewAmmo)), true);
			SetEntData(iClient, iOffset_Ammo + 40, 0);
		}
		g_bClientIsReloading[iClient] = false;
		g_iReloadFrameCounter[iClient] = 0;
	}
	/*
	if(((StrEqual(currentweapon, "weapon_pumpshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_chrome", false) == true)) && (CurrentClipAmmo == 8))
	{
		new iAmmo = GetEntData(iClient, iOffset_Ammo + 28);	//for pump shotguns (+28)
		if(iAmmo >= (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6)), true);
			SetEntData(iClient, iOffset_Ammo + 28, iAmmo - (g_iMetalLevel[iClient]*4) - (g_iFireLevel[iClient]*6));
		}
		else if(iAmmo < (g_iPromotionalLevel[iClient]*20))
		{
			new NewAmmo = ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - iAmmo);
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - NewAmmo)), true);
			SetEntData(iClient, iOffset_Ammo + 28, 0);
		}
		g_bClientIsReloading[iClient] = false;
		g_iReloadFrameCounter[iClient] = 0;
	}
	if(((StrEqual(currentweapon, "weapon_autoshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_spas", false) == true)) && (CurrentClipAmmo == 10))
	{
		new iAmmo = GetEntData(iClient, iOffset_Ammo + 32);	//for auto shotguns (+32)
		if(iAmmo >= (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6))
		{
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + (g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6)), true);
			SetEntData(iClient, iOffset_Ammo + 32, iAmmo - (g_iMetalLevel[iClient]*4) - (g_iFireLevel[iClient]*6));
		}
		else if(iAmmo < (g_iPromotionalLevel[iClient]*20))
		{
			new NewAmmo = ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - iAmmo);
			SetEntData(ActiveWeaponID, g_iOffset_Clip1, (CurrentClipAmmo + ((g_iMetalLevel[iClient]*4) + (g_iFireLevel[iClient]*6) - NewAmmo)), true);
			SetEntData(iClient, iOffset_Ammo + 32, 0);
		}
		g_bClientIsReloading[iClient] = false;
		g_iReloadFrameCounter[iClient] = 0;
	}
	*/
	//Decided the following was not necessary. It was meant to save ammo during reloading in case a player changed weapons in the middle of a reload, but changing weapons already saves the weapons current data.
	/*
	if(g_iEllisCurrentPrimarySlot[iClient] == 0)
	{
		if((StrEqual(currentweapon, "weapon_rifle", false) == true) || (StrEqual(currentweapon, "weapon_rifle_ak47", false) == true) || (StrEqual(currentweapon, "weapon_rifle_sg552", false) == true) || (StrEqual(currentweapon, "weapon_rifle_desert", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 12);
			g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
		}
		else if((StrEqual(currentweapon, "weapon_smg", false) == true) || (StrEqual(currentweapon, "weapon_smg_mp5", false) == true) || (StrEqual(currentweapon, "weapon_smg_silenced", false) == true) || (StrEqual(currentweapon, "weapon_rifle_desert", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 20);
			g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
		}
		else if((StrEqual(currentweapon, "weapon_pumpshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_chrome", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 28);
			g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
		}
		else if((StrEqual(currentweapon, "weapon_autoshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_spas", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 32);
			g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
		}
		else if(StrEqual(currentweapon, "weapon_hunting_rifle", false) == true)
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 36);
			g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
		}
		else if((StrEqual(currentweapon, "weapon_sniper_military", false) == true) || (StrEqual(currentweapon, "weapon_sniper_awp", false) == true) || (StrEqual(currentweapon, "weapon_sniper_scout", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 40);
			g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
		}
		else if(StrEqual(currentweapon, "weapon_grenade_launcher", false) == true)
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 68);
			g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot1[iClient] = iAmmo;
		}
		else if(StrEqual(currentweapon, "weapon_rifle_m60", false) == true)
		{
			//new iAmmo = GetEntData(iClient, iOffset_Ammo);
			g_iEllisPrimarySavedClipSlot1[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot1[iClient] = 0;
		}
	}
	else if(g_iEllisCurrentPrimarySlot[iClient] == 1)
	{
		if((StrEqual(currentweapon, "weapon_rifle", false) == true) || (StrEqual(currentweapon, "weapon_rifle_ak47", false) == true) || (StrEqual(currentweapon, "weapon_rifle_sg552", false) == true) || (StrEqual(currentweapon, "weapon_rifle_desert", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 12);
			g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
		}
		else if((StrEqual(currentweapon, "weapon_smg", false) == true) || (StrEqual(currentweapon, "weapon_smg_mp5", false) == true) || (StrEqual(currentweapon, "weapon_smg_silenced", false) == true) || (StrEqual(currentweapon, "weapon_rifle_desert", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 20);
			g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
		}
		else if((StrEqual(currentweapon, "weapon_pumpshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_chrome", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 28);
			g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
		}
		else if((StrEqual(currentweapon, "weapon_autoshotgun", false) == true) || (StrEqual(currentweapon, "weapon_shotgun_spas", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 32);
			g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
		}
		else if(StrEqual(currentweapon, "weapon_hunting_rifle", false) == true)
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 36);
			g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
		}
		else if((StrEqual(currentweapon, "weapon_sniper_military", false) == true) || (StrEqual(currentweapon, "weapon_sniper_awp", false) == true) || (StrEqual(currentweapon, "weapon_sniper_scout", false) == true))
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 40);
			g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
		}
		else if(StrEqual(currentweapon, "weapon_grenade_launcher", false) == true)
		{
			new iAmmo = GetEntData(iClient, iOffset_Ammo + 68);
			g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot2[iClient] = iAmmo;
		}
		else if(StrEqual(currentweapon, "weapon_rifle_m60", false) == true)
		{
			//new iAmmo = GetEntData(iClient, iOffset_Ammo);
			g_iEllisPrimarySavedClipSlot2[iClient] = CurrentClipAmmo;
			g_iEllisPrimarySavedAmmoSlot2[iClient] = 0;
		}
	}
	*/
}

EventsHurt_AttackerEllis(Handle:hEvent, iAttacker, iVictim)
{
	if (IsFakeClient(iAttacker))
		return;
	
	if (g_iClientTeam[iVictim] != TEAM_INFECTED)
		return;
	
	if(g_iFireLevel[iAttacker]>0)
	{
		if(g_iClientTeam[iVictim] == TEAM_INFECTED)
		{
			if(g_bUsingFireStorm[iAttacker]==true)
			{
				new Float:time = (float(g_iFireLevel[iAttacker]) * 6.0);
				IgniteEntity(iVictim, time, false);
			}
		}
	}
	
	if(g_iOverLevel[iAttacker] > 0)
	{
		if(g_iClientTeam[iVictim] == TEAM_INFECTED)
		{
			new iCurrentHealth = GetEntProp(iAttacker,Prop_Data,"m_iHealth");
			new iMaxHealth = GetEntProp(iAttacker,Prop_Data,"m_iMaxHealth");
			new iTempHealth = GetSurvivorTempHealth(iAttacker);
			if(iCurrentHealth + iTempHealth >= iMaxHealth - 30)
			{
				decl String:strWeaponClass[32];
				GetEventString(hEvent,"weapon",strWeaponClass,32);
				//PrintToChatAll("\x03-class of gun: \x01%s",strWeaponClass);
				if ((StrContains(strWeaponClass,"shotgun",false) != -1) || 
					(StrContains(strWeaponClass,"rifle",false) != -1) || 
					(StrContains(strWeaponClass,"pistol",false) != -1) || 
					(StrContains(strWeaponClass,"smg",false) != -1) || 
					(StrContains(strWeaponClass,"sniper",false) != -1) || 
					(StrContains(strWeaponClass,"launcher",false) != -1))
				{
					new iVictimHealth = GetEntProp(iVictim,Prop_Data,"m_iHealth");
					// PrintToChatAll("Ellis iVictim %N START HP: %i", iVictim, iVictimHealth);

					new iDmgAmount = GetEventInt(hEvent,"dmg_health");
					new iAddtionalDmg = RoundToNearest(iDmgAmount * (g_iOverLevel[iAttacker] * 0.05));
					SetEntProp(iVictim, Prop_Data,"m_iHealth", iVictimHealth - CalculateDamageTakenForVictimTalents(iVictim, iAddtionalDmg, strWeaponClass));
					PrintToChatAll("Ellis is doing %i original damage", iDmgAmount);
					PrintToChatAll("Ellis is doing %i additional damage", CalculateDamageTakenForVictimTalents(iVictim, iAddtionalDmg, strWeaponClass));

					// new iVictimHealth2 = GetEntProp(iVictim,Prop_Data,"m_iHealth");
					// PrintToChatAll("Ellis iVictim %N   END HP: %i", iVictim, iVictimHealth2);
				}
			}
		}
	}
}

EventsHurt_VictimEllis(Handle:hEvent, attacker, victim)
{
	if (IsFakeClient(victim))
		return;

	SuppressNeverUsedWarning(attacker);

	new dmgType = GetEventInt(hEvent, "type");
	new dmgHealth  = GetEventInt(hEvent,"dmg_health");

	if(g_iFireLevel[victim] > 0)
	{
		//Prevent Fire Damage
		if(dmgType == DAMAGETYPE_FIRE1 || dmgType == DAMAGETYPE_FIRE2)
		{
			//PrintToChat(victim, "Prevent fire damage");
			new currentHP = GetEventInt(hEvent,"health");
			SetEntProp(victim,Prop_Data,"m_iHealth", dmgHealth + currentHP);
		}
	}

	if(g_iOverLevel[victim] > 0)
	{
		new iCurrentHealth = GetEntProp(victim,Prop_Data,"m_iHealth");
		new iMaxHealth = GetEntProp(victim,Prop_Data,"m_iMaxHealth");
		//new Float:fTempHealth = GetEntDataFloat(victim, g_iOffset_HealthBuffer);
		//if(float(iCurrentHealth) + fTempHealth < (float(iMaxHealth) - 20.0))
		if(iCurrentHealth < (iMaxHealth - 20.0))
		{
			if(g_bEllisOverSpeedIncreased[victim])
			{
				g_bEllisOverSpeedIncreased[victim] = false;

				SetClientSpeed(victim);
			}
		}
		//else if(float(iCurrentHealth) + fTempHealth > (float(iMaxHealth) - 20.0))
		else if(iCurrentHealth >= (iMaxHealth - 20.0))
		{
			if(g_bEllisOverSpeedIncreased[victim] == false)
			{
				g_bEllisOverSpeedIncreased[victim] = true;

				SetClientSpeed(victim);						
			}
		}
	}
}

EventsDeath_AttackerEllis(Handle:hEvent, iAttacker, iVictim)
{
	// Handle Ellis's speed boost with the tanks dying
	if (g_iClientTeam[iVictim] == TEAM_INFECTED &&
		g_bEndOfRound == false && 
		RunClientChecks(iVictim) &&
		GetEntProp(iVictim, Prop_Send, "m_zombieClass") == TANK)
	{
		for(new i=1; i <= MaxClients; i++)
		{
			if (g_iChosenSurvivor[i] == ELLIS &&
				g_iJamminLevel[i] > 0 &&
				g_iClientTeam[i] == TEAM_SURVIVORS &&
				RunClientChecks(i) && 
				IsPlayerAlive(i) &&
				IsFakeClient(i) == false)
			{
				SetClientSpeed(i);
				if(g_iTankCounter == 0)
					PrintHintText(i, "You calm down knowing there are no Tanks around.");
			}
		}
	}
	
	// Now start Ellis's attacker abilities
	if (g_iChosenSurvivor[iAttacker] != ELLIS ||
		g_bTalentsConfirmed[iAttacker] != true ||
		g_iClientTeam[iAttacker] != TEAM_SURVIVORS ||
		g_iClientTeam[iVictim] != TEAM_INFECTED ||
		RunClientChecks(iAttacker) == false ||
		IsPlayerAlive(iAttacker) == false)
		return;
	
	SuppressNeverUsedWarning(hEvent);

	if(g_iBringLevel[iAttacker] > 0)
	{
		// Give temp health on SI kill
		AddTempHealthToSurvivor(iAttacker, float(g_iBringLevel[iAttacker]), false);
		
		// Increase clip size
		new iEntid = GetEntDataEnt2(iAttacker, g_iOffset_ActiveWeapon);
		if (iEntid != -1)
		{
			decl String:wclass[32];
			GetEntityNetClass(iEntid, wclass, 32);
			//PrintToChatAll("\x03-class of gun: \x01%s",wclass);
			if (StrContains(wclass,"rifle",false) != -1 || 
				StrContains(wclass,"smg",false) != -1 || 
				StrContains(wclass,"sub",false) != -1 || 
				StrContains(wclass,"sniper",false) != -1)
			{
				new clip = GetEntProp(iEntid,Prop_Data,"m_iClip1");
				clip += g_iBringLevel[iAttacker] * 20;
				// Clamp the clip
				if(clip > 250)
					clip = 250;
				SetEntData(iEntid, g_iOffset_Clip1, clip, true);

				// Whats clip2 do??
				//clip2 = GetEntProp(iEntid,Prop_Data,"m_iClip2"); 			
				//SetEntData(iEntid, clipsize2, clip2+30, true);	
			}
		}
		if(g_iEllisSpeedBoostCounter[iAttacker] < (4 * g_iBringLevel[iAttacker]))
		{
			g_iEllisSpeedBoostCounter[iAttacker]++;
			SetClientSpeed(iAttacker);
		}
	}
}

// EventsDeath_VictimEllis(Handle:hEvent, iAttacker, iVictim)
// {
// 	SuppressNeverUsedWarning(hEvent, iAttacker, iVictim);
// }
