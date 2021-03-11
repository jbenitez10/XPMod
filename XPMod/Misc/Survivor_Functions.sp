void OnPlayerRunCmd_SelfRevive(int iClient, &iButtons)
{
	// The GetEntProp method for getting buttons doesnt work for IN_USE
	// while incap, but it will still be caught in here. So, stop the
	// self revive if they let go.
	// Note: this is apparently stoppeed by being hit by CI. In order
	// to disable this, perhaps make a counter to check how long the
	// IN_USE has been let go before calling EndSelfRevive
	if(g_bSelfReviving[iClient] == true && !(iButtons & IN_USE))
		EndSelfRevive(iClient);

	// Check that the player has a self revive and is pressing the button while incap
	if (g_iSelfRevives[iClient] <= 0 ||
		!(iButtons & IN_USE) ||
		g_bSelfReviving[iClient] == true ||
		g_iClientTeam[iClient] != TEAM_SURVIVORS || 
		RunClientChecks(iClient) == false ||
		GetEntProp(iClient, Prop_Send, "m_isIncapacitated") == 0 ||
		IsFakeClient(iClient))
		return;

	DebugLog(DEBUG_MODE_TESTING, "OnPlayerRunCmd_SelfRevive");

	StartSelfRevive(iClient);
}

void StartSelfRevive(int iClient)
{
	DebugLog(DEBUG_MODE_TESTING, "StartSelfRevive");
	if (g_bSelfReviving[iClient] == true ||
		g_iClientTeam[iClient] != TEAM_SURVIVORS || 
		g_bIsClientGrappled[iClient] ||
		RunClientChecks(iClient) == false ||
		IsFakeClient(iClient) ||
		GetEntProp(iClient, Prop_Send, "m_isIncapacitated") == 0)
		return;
	
	g_bSelfReviving[iClient] = true;
	g_fSelfRevivingFinishTime[iClient] = GetGameTime() + SELF_REVIVE_TIME;
	SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarDuration", SELF_REVIVE_TIME);
	SetEntPropEnt(iClient, Prop_Send, "m_reviveOwner", iClient);

	delete g_hTimer_SelfReviveCheck[iClient];
	g_hTimer_SelfReviveCheck[iClient] = CreateTimer(0.1, TimerSelfReviveCheck, iClient, TIMER_REPEAT);
}

Action:TimerSelfReviveCheck(Handle:timer, any:iClient)
{
	DebugLog(DEBUG_MODE_TESTING, "TimerSelfReviveCheck");
	if (g_iClientTeam[iClient] != TEAM_SURVIVORS || 
		g_bIsClientGrappled[iClient] ||
		RunClientChecks(iClient) == false ||
		IsFakeClient(iClient) ||
		GetEntProp(iClient, Prop_Send, "m_isIncapacitated") == 0)
	{
		EndSelfRevive(iClient);
		g_hTimer_SelfReviveCheck[iClient] = null;
		return Plugin_Stop;
	}
	
	//Check for a completed self revive
	if (g_fSelfRevivingFinishTime[iClient] <= GetGameTime() && 
		g_fSelfRevivingFinishTime[iClient] > 0 &&
		g_bSelfReviving[iClient])
	{
		SuccessfulSelfRevive(iClient);
	}
	// Check if still self reviving and continue
	else if (g_bSelfReviving[iClient])
	{
		return Plugin_Continue;
	}

	EndSelfRevive(iClient);
	g_hTimer_SelfReviveCheck[iClient] = null;
	return Plugin_Stop;
}

void SuccessfulSelfRevive(int iClient)
{
	// Revive them by using cheat command to give full health
	RunCheatCommand(iClient, "give", "give health");

	// Change health to self revive health
	SetEntProp(iClient, Prop_Data,"m_iHealth", SELF_REVIVE_HEALTH);

	// Change temp health to self revive health
	ResetTempHealthToSurvivor(iClient);
	AddTempHealthToSurvivor(iClient, float(SELF_REVIVE_TEMP_HEALTH));

	// Remove the self revive from the client
	g_iSelfRevives[iClient]--;
}

void EndSelfRevive(int iClient)
{
	DebugLog(DEBUG_MODE_TESTING, "EndSelfRevive");
	if (RunClientChecks(iClient) == false)
		return;
	
	g_bSelfReviving[iClient] = false;
	g_fSelfRevivingFinishTime[iClient] = -1.0;
	SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarDuration", 0.0);
	SetEntPropEnt(iClient, Prop_Send, "m_reviveOwner", -1);
}

void ResetTempHealthToSurvivor(iClient)
{
	if (!RunClientChecks(iClient) || 
		!IsPlayerAlive(iClient) || 
		g_iClientTeam[iClient] != TEAM_SURVIVORS ||
		GetEntProp(iClient, Prop_Send, "m_isIncapacitated") == 1)
        return;
	
	SetEntPropFloat(iClient, Prop_Send, "m_healthBuffer", 0.0);
}

void AddTempHealthToSurvivor(iClient, Float:fAdditionalTempHealth)
{
	if (!RunClientChecks(iClient) || 
		!IsPlayerAlive(iClient) || 
		g_iClientTeam[iClient] != TEAM_SURVIVORS)
        return;
	
	// Calculate the current surivivors temp health
	new iTempHealth = GetSurvivorTempHealth(iClient);
	if (iTempHealth < 0)
		return;
	
	// If the temp health is not set or is expired (passed buffer time), then
	// reset the buffer time and set a new temp health buffer with the new value.
	// Else, simply add the additional health to the existing players temp health,
	// without resetting the time buffer.
	if (iTempHealth == 0)
	{
		SetEntPropFloat(iClient, Prop_Send, "m_healthBufferTime", GetGameTime());
		SetEntPropFloat(iClient, Prop_Send, "m_healthBuffer", fAdditionalTempHealth);
	}
	else
	{
		// Get tthe current health buffer and add the specified amount to it
		new Float:fTempHealth = GetEntPropFloat(iClient, Prop_Send, "m_healthBuffer")
		fTempHealth += fAdditionalTempHealth;

		// Cap the temp health
		//if(fTempHealth > 160.0)
		//	fTempHealth = 160.0;

		// Set it
		SetEntPropFloat(iClient, Prop_Send, "m_healthBuffer", fTempHealth);
	}
}

// This function calculates a survivors temp health, since there is no direct way to 
// obtain this information.  It takes health buffer ammount and subtracts the gametime minus
// buffer time times the decay rate for temp health.
int GetSurvivorTempHealth(int iClient)
{
    if (!RunClientChecks(iClient) || 
		!IsPlayerAlive(iClient) || 
		g_iClientTeam[iClient] != TEAM_SURVIVORS)
        return -1;
    
    if (cvarPainPillsDecay == INVALID_HANDLE)
    {
        cvarPainPillsDecay = FindConVar("pain_pills_decay_rate");
        if (cvarPainPillsDecay == INVALID_HANDLE)
            return -1;
        
        HookConVarChange(cvarPainPillsDecay, OnPainPillsDecayChanged);
        flPainPillsDecay = cvarPainPillsDecay.FloatValue;
    }
    
    int tempHealth = RoundToCeil(GetEntPropFloat(iClient, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(iClient, Prop_Send, "m_healthBufferTime")) * flPainPillsDecay)) - 1;
    return tempHealth < 0 ? 0 : tempHealth;
}