LoadIceTankTalents(iClient)
{
	if (RunClientChecks(iClient) == false || 
		g_iClientTeam[iClient] != TEAM_INFECTED || 
		GetEntProp(iClient, Prop_Send, "m_zombieClass") != TANK)
		return;
	
	if(IsPlayerAlive(iClient) == false)
	{
		if (IsFakeClient(iClient) == false)
			PrintToChat(iClient, "\x04You cannot choose tank talents after you have died");
		return;
	}
	
	g_iTankChosen[iClient] = TANK_ICE;
	g_fTankHealthPercentage[iClient] =  1.0;
	g_iIceTankLifePool[iClient] = TANK_ICE_REGEN_LIFE_POOL_SIZE;
	
	//Stop Kiting (Bullet hits slowing tank down)
	SetConVarInt(FindConVar("z_tank_damage_slow_min_range"), 0);
	SetConVarInt(FindConVar("z_tank_damage_slow_max_range"), 0);

	//Set Movement Speed	
	SetClientSpeed(iClient);
	
	//Give Health
	SetEntProp(iClient, Prop_Data,"m_iMaxHealth", TANK_HEALTH_ICE);
	new iCurrentHealth = GetEntProp(iClient,Prop_Data,"m_iHealth");
	SetEntProp(iClient, Prop_Data,"m_iHealth", iCurrentHealth + TANK_HEALTH_ICE - 6000);
	
	//Change Skin Color
	SetEntityRenderMode(iClient, RenderMode:0);
	SetEntityRenderColor(iClient, 0, 255, 255, 255);

	//Grow the tank, doesnt seem to work
	//SetEntPropFloat(iClient , Prop_Send,"m_flModelScale", 1.3); 
	
	//Particle effects
	CreateIceTankTrailEffect(iClient);
	g_iPID_IceTankIcicles[iClient] = CreateParticle("ice_tank_icicles", 0.0, iClient, ATTACH_RSHOULDER);
	
	if (IsFakeClient(iClient) == false)
		PrintHintText(iClient, "You have become the Ice Tank");
}

// SetupTankForBot_Ice(iClient)
// {
// 	LoadIceTankTalents(iClient);
// }

SetClientSpeedTankIce(iClient, &Float:fSpeed)
{
	if (g_iTankChosen[iClient] != TANK_ICE)
		return;
}

OnGameFrame_Tank_Ice(iClient)
{
	//Check to see if the charging has already taken place or depleted
	if(g_iTankChosen[iClient] == TANK_ICE && g_iIceTankLifePool[iClient] < 1)
		return;
	
	new buttons = GetEntProp(iClient, Prop_Data, "m_nButtons", buttons);
	
	//Check to see if ducking and not attacking before starting the charge
	if((buttons & IN_DUCK) && !(buttons & IN_ATTACK) && !(buttons & IN_ATTACK2))
	{
		CheckIfTankMovedWhileChargingAndIncrementCharge(iClient);

		//Display the first message to the player while he is charging up
		if(g_iTankCharge[iClient] == 30 && IsFakeClient(iClient) == false)
			PrintHintText(iClient, "Charging Up Health Regeneration"); 
		
		//Charged for long enough, now handle ice tank regen
		if(g_iTankCharge[iClient] >= 150)
		{
			decl Float:fCurrentTankHealthPercentage;
			new iCurrentHealth = GetEntProp(iClient,Prop_Data,"m_iHealth");
			
			if(g_iIceTankLifePool[iClient] > 0 && iCurrentHealth < TANK_HEALTH_ICE)
			{
				if(g_iIceTankLifePool[iClient] > 10)
				{
					new iNewHealth = iCurrentHealth + 10 > TANK_HEALTH_ICE ? TANK_HEALTH_ICE : iCurrentHealth + 10;
					SetEntProp(iClient, Prop_Data,"m_iHealth", iNewHealth);
					fCurrentTankHealthPercentage = float(iNewHealth) / float(TANK_HEALTH_ICE);
					g_iIceTankLifePool[iClient] -= 10;
					
					if (IsFakeClient(iClient) == false)
						PrintHintText(iClient, "Life Pool Remaining: %d", g_iIceTankLifePool[iClient]);
					
					//Show the ice sphere around the Ice Tank
					g_bShowingIceSphere[iClient] = true;
					
					if(g_iPID_IceTankChargeMistStock[iClient] == -1 && g_iPID_IceTankChargeMistAddon[iClient] == -1 && g_iPID_IceTankChargeSnow[iClient] == -1)
					{
						g_iPID_IceTankChargeMistAddon[iClient] = WriteParticle(iClient, "ice_tank_charge_mist", 50.0);
						g_iPID_IceTankChargeSnow[iClient] = WriteParticle(iClient, "ice_tank_charge_snow", 50.0);

						//Make Ice Fog Entity
						g_iPID_IceTankChargeMistStock[iClient] = CreateEntityByName("env_smokestack");
						new String:vecString[32];
						Format(vecString, sizeof(vecString), "%f %f %f", g_xyzClientTankPosition[iClient][0], g_xyzClientTankPosition[iClient][1], g_xyzClientTankPosition[iClient][2]);

						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"Origin", vecString);
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"BaseSpread", "0");		//Gap in the middle
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"SpreadSpeed", "90");	//Speed the smoke moves outwards
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"Speed", "50");			//Speed the smoke moves up
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"StartSize", "1");
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"EndSize", "150");
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"Rate", "60");			//Amount of smoke created
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"JetLength", "200");		//Smoke jets outside of the original
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"Twist", "30"); 			//Amount of global twisting
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"RenderColor", "200 230 255");
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"RenderAmt", "50");		//Transparency
						DispatchKeyValue(g_iPID_IceTankChargeMistStock[iClient],"SmokeMaterial", "particle/particle_smokegrenade1.vmt");
						
						DispatchSpawn(g_iPID_IceTankChargeMistStock[iClient]);
						AcceptEntityInput(g_iPID_IceTankChargeMistStock[iClient], "TurnOn");
					}
					
					if(g_hTimer_IceSphere[iClient] == null)
						g_hTimer_IceSphere[iClient] = CreateTimer(0.1, Timer_CreateSmallIceSphere, iClient, TIMER_REPEAT);

					decl Float:xyzCurrentPosition[3];
					GetClientAbsOrigin(iClient, xyzCurrentPosition);
					
					//Check to see if there is a player inside of the ice sphere and freeze him if he is
					for(new iVictim = 1; iVictim <= MaxClients; iVictim++)
					{
						if(g_bFrozenByTank[iVictim] == true || g_iClientTeam[iVictim] != TEAM_SURVIVORS 
							|| IsClientInGame(iVictim) == false || IsPlayerAlive(iVictim) == false)
							continue;
						
						decl Float:xyzVictimPosition[3];
						GetClientAbsOrigin(iVictim, xyzVictimPosition);
						
						new Float:fDistance = GetVectorDistance(xyzVictimPosition, xyzCurrentPosition, false);
						
						//The sphere radius is about 125.0 but check for 130.0 to be safe
						if(fDistance <= 130.0)
							CreateTimer(0.1, Timer_FreezePlayerByTank, iVictim, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
				else
				{
					new iNewHealth = iCurrentHealth + g_iIceTankLifePool[iClient] > TANK_HEALTH_ICE ? TANK_HEALTH_ICE : iCurrentHealth + g_iIceTankLifePool[iClient];
					SetEntProp(iClient, Prop_Data,"m_iHealth", iNewHealth);
					fCurrentTankHealthPercentage = float(iCurrentHealth + g_iIceTankLifePool[iClient]) / float(TANK_HEALTH_ICE);
					g_iIceTankLifePool[iClient] = 0;
					
					if (IsFakeClient(iClient) == false)
						PrintHintText(iClient, "Life Pool Depleted");
					
					g_bShowingIceSphere[iClient] = false;
				}
				
				//Set the color of the tank to match his current health percentage
				new iGreen	= 20 + RoundToNearest(235 * fCurrentTankHealthPercentage);
				
				SetEntityRenderMode(iClient, RenderMode:0);
				SetEntityRenderColor(iClient, 0, iGreen, 255, 255);
			}
		}
	}
	else if(g_iTankCharge[iClient] > 0)
	{
		if(g_iTankCharge[iClient] > 31 && IsFakeClient(iClient) == false)
			PrintHintText(iClient, "Charge Interrupted");
		
		g_iTankCharge[iClient] = 0;
		g_bShowingIceSphere[iClient] = false;
	}
}

EventsHurt_TankVictim_Ice(Handle:hEvent, iAttacker, iVictimTank, iDmgType, iDmgHealth)
{
	SuppressNeverUsedWarning(hEvent, iAttacker);

	new iCurrentHealth = GetEntProp(iVictimTank,Prop_Data,"m_iHealth");
	decl Float:fCurrentTankHealthPercentage;

	//Add More Fire Damage
	if(iDmgType == DAMAGETYPE_FIRE1 || iDmgType == DAMAGETYPE_FIRE2)
	{
		SetEntProp(iVictimTank, Prop_Data, "m_iHealth", iCurrentHealth - 216);
	}
	else if(iDmgType == DAMAGETYPE_IGNITED_ENTITY)
	{
		SetEntProp(iVictimTank, Prop_Data, "m_iHealth", iCurrentHealth + 28);
		ExtinguishEntity(iVictimTank);
	}
	
	fCurrentTankHealthPercentage = float(iCurrentHealth + iDmgHealth) / float(TANK_HEALTH_ICE);
	
	//Check to see if the difference in stored health and current health percentage is significant
	if(g_fTankHealthPercentage[iVictimTank] - fCurrentTankHealthPercentage >= 0.01)
	{
		g_fTankHealthPercentage[iVictimTank] = fCurrentTankHealthPercentage;
		
		//Change the actual color of the tank to reflect his health
		//Go from Light Blue to Dark Blue by lowering the green value
		new iGreen	= 20 + RoundToNearest(235 * fCurrentTankHealthPercentage);
		
		SetEntityRenderMode(iVictimTank, RenderMode:0);
		SetEntityRenderColor(iVictimTank, 0, iGreen, 255, 255);
	}
}

EventsHurt_TankAttacker_Ice(Handle:hEvent, iAttackerTank, iVictim, iDmgType, iDmgHealth)
{
	SuppressNeverUsedWarning(iAttackerTank, iDmgType, iDmgHealth);

	decl String:weapon[20];
	GetEventString(hEvent,"weapon", weapon, 20);

	if(g_bFrozenByTank[iVictim] == false && g_bBlockTankFreezing[iVictim] == false)
	{
		if(StrEqual(weapon,"tank_rock") == true ||
			(StrEqual(weapon,"tank_claw") == true && GetRandomInt(1, 3) == 1))
			FreezePlayerByTank(iVictim, 4.2);
	}
	else
		UnfreezePlayerByTank(iVictim);
}

FreezePlayerByTank(iVictim, Float:fFreezeTime, Float:fStartTime = 0.2)
{
	if(iVictim < 1 || IsClientInGame(iVictim) == false)
		return;
	
	CreateTimer(fStartTime, Timer_FreezePlayerByTank, iVictim, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(fFreezeTime, Timer_UnfreezePlayerByTank, iVictim, TIMER_FLAG_NO_MAPCHANGE);
}

UnfreezePlayerByTank(iClient)
{
	if(iClient < 1 || g_iClientTeam[iClient] != TEAM_SURVIVORS || g_bFrozenByTank[iClient] == false || IsValidEntity(iClient) == false || 
		IsClientInGame(iClient) == false || IsPlayerAlive(iClient) == false)
		return;
	
	g_bFrozenByTank[iClient] =  false;
	g_bBlockTankFreezing[iClient] = true;
	
	//Reset To Allow The Player To Freeze Again
	CreateTimer(3.0, Timer_UnblockTankFreezing, iClient, TIMER_FLAG_NO_MAPCHANGE);
	
	//Play Ice Break Sound
	new Float:vec[3];
	GetClientAbsOrigin(iClient, vec);
	EmitAmbientSound(SOUND_FREEZE, vec, iClient, SNDLEVEL_NORMAL);
	
	StopHudOverlayColor(iClient)
	
	//Set Player Model Color
	fnc_SetRendering(iClient);
	//ResetGlow(iClient);
	
	//Reset Movement Speed
	SetClientSpeed(iClient);
	//ResetSurvivorSpeed(iClient);
}

CreateIceSphere(iClient, Float:fSphereDiameter, iRings, Float:fRingWidth, Float:fLifeTime, Float:fZOffset = 50.0)
{
	new Float:fRings = float(iRings);
	decl Float:fRingDiameter, Float:xyzOrigin[3];
	GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", xyzOrigin);
	
	
	new Float:xyzRingPosition[3];
	
	xyzRingPosition[0] = xyzOrigin[0];
	xyzRingPosition[1] = xyzOrigin[1];
	//Raise the sphere to center it around the player
	xyzOrigin[2] += fZOffset;
	
	// Create the rings to make the spehere
	decl i;
	for(i = 1; i < iRings; i++)
	{
		fRingDiameter = 0.0 + fSphereDiameter * Sine(PI * (i / fRings));
		
		xyzRingPosition[2] = xyzOrigin[2] + ((fSphereDiameter / 2.0) * Cosine(PI * (i / fRings)));
		
		TE_Start("BeamRingPoint");
		TE_WriteVector("m_vecCenter", xyzRingPosition);
		TE_WriteFloat("m_flStartRadius",  fRingDiameter);
		TE_WriteFloat("m_flEndRadius", fRingDiameter + 0.1);
		TE_WriteNum("m_nModelIndex", g_iSprite_Laser);
		TE_WriteNum("m_nHaloIndex", g_iSprite_Halo);
		TE_WriteNum("m_nStartFrame", 0);
		TE_WriteNum("m_nFrameRate", 60);
		TE_WriteFloat("m_fLife", fLifeTime);
		TE_WriteFloat("m_fWidth", fRingWidth);
		TE_WriteFloat("m_fEndWidth", fRingWidth);
		TE_WriteFloat("m_fAmplitude",  0.1);	//0.5
		TE_WriteNum("r", 0);
		TE_WriteNum("g", 30);
		TE_WriteNum("b", 180);
		TE_WriteNum("a", 35);
		TE_WriteNum("m_nSpeed", 1);
		TE_WriteNum("m_nFlags", 0);
		TE_WriteNum("m_nFadeLength", 0);
		TE_SendToAll();
	}
}

CreateIceRockDestroyEffect(int iRockEntity)
{
	// Find the tank rock entity in the list that will be used to the trail particle entity
	new iTankRockIndex = FindIndexInArrayListUsingValue(g_listTankRockEntities, iRockEntity, TANK_ROCK_ENTITY_ID);
	new iTankRockTrailParticle = g_listTankRockEntities.Get(iTankRockIndex, TANK_ROCK_PARTICLE_TRAIL);
	// Stop the trail particle and remove it
	TurnOffAndDeleteSmokeStackParticle(iTankRockTrailParticle);

	new Float:xyzRockPosition[3];
	GetEntPropVector(iRockEntity, Prop_Send, "m_vecOrigin", xyzRockPosition);
	xyzRockPosition[2] -= 20.0;

	new String:vecString[32];
	Format(vecString, sizeof(vecString), "%f %f %f", xyzRockPosition[0], xyzRockPosition[1], xyzRockPosition[2]);

	//Create particles
	WriteParticle(iRockEntity, "impact_glass", 0.0, 5.0, xyzRockPosition);
	WriteParticle(iRockEntity, "impact_glass_cheap", 0.0, 5.0, xyzRockPosition);
	WriteParticle(iRockEntity, "water_child_water6", 0.0, 5.0, xyzRockPosition);
	WriteParticle(iRockEntity, "tank_rock_throw_impact_chunks", 0.0, 5.0, xyzRockPosition);
	
	//Make Smoke Entity
	new smoke = CreateEntityByName("env_smokestack");
	
	DispatchKeyValue(smoke,"Origin", vecString);
	DispatchKeyValue(smoke,"BaseSpread", "0");		//Gap in the middle
	DispatchKeyValue(smoke,"SpreadSpeed", "350");	//Speed the smoke moves outwards
	DispatchKeyValue(smoke,"Speed", "200");			//Speed the smoke moves up
	DispatchKeyValue(smoke,"StartSize", "10");
	DispatchKeyValue(smoke,"EndSize", "550");
	DispatchKeyValue(smoke,"Rate", "150");			//Amount of smoke created
	DispatchKeyValue(smoke,"JetLength", "300");		//Smoke jets outside of the original
	DispatchKeyValue(smoke,"Twist", "10"); 			//Amount of global twisting
	DispatchKeyValue(smoke,"RenderColor", "200 230 255");
	DispatchKeyValue(smoke,"RenderAmt", "105");		//Transparency
	DispatchKeyValue(smoke,"SmokeMaterial", "particle/particle_smokegrenade1.vmt");
	
	DispatchSpawn(smoke);
	AcceptEntityInput(smoke, "TurnOn");
	
	CreateTimer(0.5, TimerStopSmokeEntity, smoke, TIMER_FLAG_NO_MAPCHANGE);
}

CreateIceRockTrailEffect(int iRockEntity)
{
	new Float:xyzRockPosition[3];
	GetEntPropVector(iRockEntity, Prop_Send, "m_vecOrigin", xyzRockPosition);
	new String:vecString[32];
	Format(vecString, sizeof(vecString), "%f %f %f", xyzRockPosition[0], xyzRockPosition[1], xyzRockPosition[2]);

	// Make Smoke Entity
	new iTankRockTrailParticle = CreateEntityByName("env_smokestack");
	// Find the tank rock entity in the list that will be used store the trail particle entity
	new iTankRockIndex = FindIndexInArrayListUsingValue(g_listTankRockEntities, iRockEntity, TANK_ROCK_ENTITY_ID);
	// Store it for stopping and destroying it later
	g_listTankRockEntities.Set(iTankRockIndex, iTankRockTrailParticle, TANK_ROCK_PARTICLE_TRAIL);
	
	DispatchKeyValue(iTankRockTrailParticle,"Origin", vecString);
	DispatchKeyValue(iTankRockTrailParticle,"BaseSpread", "0");		//Gap in the middle
	DispatchKeyValue(iTankRockTrailParticle,"SpreadSpeed", "30");	//Speed the smoke moves outwards
	DispatchKeyValue(iTankRockTrailParticle,"Speed", "2");			//The speed at which the smoke particles move after they're spawned
	DispatchKeyValue(iTankRockTrailParticle,"StartSize", "40");
	DispatchKeyValue(iTankRockTrailParticle,"EndSize", "80");
	DispatchKeyValue(iTankRockTrailParticle,"Rate", "100");			//Amount of smoke created
	DispatchKeyValue(iTankRockTrailParticle,"JetLength", "8");		//Smoke jets outside of the original
	DispatchKeyValue(iTankRockTrailParticle,"Twist", "3"); 			//Amount of global twisting
	DispatchKeyValue(iTankRockTrailParticle,"RenderColor", "200 230 255");
	DispatchKeyValue(iTankRockTrailParticle,"RenderAmt", "205");		//Transparency
	DispatchKeyValue(iTankRockTrailParticle,"SmokeMaterial", "particle/particle_smokegrenade1.vmt");
	
	
	SetVariantString("!activator");
	AcceptEntityInput(iTankRockTrailParticle, "SetParent", iRockEntity, iTankRockTrailParticle, 0);

	DispatchSpawn(iTankRockTrailParticle);
	AcceptEntityInput(iTankRockTrailParticle, "TurnOn");
	
	CreateTimer(30.0, TimerStopSmokeEntity, iTankRockTrailParticle, TIMER_FLAG_NO_MAPCHANGE);
}


CreateIceTankTrailEffect(int iClient)
{
	new Float:xyzTankPosition[3];
	GetClientAbsOrigin(iClient, xyzTankPosition);
	xyzTankPosition[2] += 30.0;
	new String:vecString[32];
	Format(vecString, sizeof(vecString), "%f %f %f", xyzTankPosition[0], xyzTankPosition[1], xyzTankPosition[2]);

	g_iPID_IceTankTrail[iClient] = CreateEntityByName("env_smokestack");
	
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"Origin", vecString);
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"BaseSpread", "0");		//Gap in the middle
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"SpreadSpeed", "20");	//Speed the smoke moves outwards
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"Speed", "5");			//The speed at which the smoke particles move after they're spawned
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"StartSize", "35");
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"EndSize", "70");
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"Rate", "5");			//Amount of smoke created
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"JetLength", "20");		//Smoke jets outside of the original
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"Twist", "3"); 			//Amount of global twisting
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"RenderColor", "200 230 255");
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"RenderAmt", "50");		//Transparency
	DispatchKeyValue(g_iPID_IceTankTrail[iClient],"SmokeMaterial", "particle/particle_smokegrenade1.vmt");
	
	
	SetVariantString("!activator");
	AcceptEntityInput(g_iPID_IceTankTrail[iClient], "SetParent", iClient, g_iPID_IceTankTrail[iClient], 0);

	DispatchSpawn(g_iPID_IceTankTrail[iClient]);
	AcceptEntityInput(g_iPID_IceTankTrail[iClient], "TurnOn");
}

FreezeEveryoneCloseToExplodingIceTankRock(iRockEntity)
{
	// Get the rock location
	new Float:xyzRockPosition[3];
	GetEntPropVector(iRockEntity, Prop_Send, "m_vecOrigin", xyzRockPosition);

	for(new iClient=1; iClient <= MaxClients; iClient++)
	{
		if(RunClientChecks(iClient) &&
			IsPlayerAlive(iClient) &&
			g_iClientTeam[iClient] == TEAM_SURVIVORS)
		{
			// Get the survivor player location
			new Float:xyzSurvivorPosition[3];
			GetClientAbsOrigin(iClient, xyzSurvivorPosition);
			//Check if player is within the radius to freeze
			// Get the distance
			new Float:fDistance = GetVectorDistance(xyzSurvivorPosition, xyzRockPosition, false);		
			//Freeze if they are close enough
			if(fDistance <= 180.0)
				FreezePlayerByTank(iClient, 6.0);
		}
	}
}