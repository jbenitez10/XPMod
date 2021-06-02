//Ellis Menu////////////////////////////////////////////////////////////////

//Ellis Menu Draw
Action:EllisMenuDraw(iClient) 
{
	decl String:text[512];

	DeleteAllMenuParticles(iClient);
	Menu menu = CreateMenu(EllisMenuHandler);
	SetMenuPagination(menu, MENU_NO_PAGINATION);

	char strStartingNewLines[32], strEndingNewLines[32];
	GetNewLinesToPushMenuDown(iClient, strStartingNewLines);
	GetNewLinesToPushMenuUp(iClient, strEndingNewLines);
	
	FormatEx(text, sizeof(text), "%sLevel %d	XP: %d/%d\n=	=	=	=	=	=	=	=	=	=	=	=	=	=\n \n			Ellis's Weapons Expert Talents\n ", strStartingNewLines, g_iClientLevel[iClient], g_iClientXP[iClient], g_iClientNextLevelXPAmount[iClient]);
	SetMenuTitle(menu, text);
	
	FormatEx(text, sizeof(text), "	[Level %d]	Overconfidence", g_iOverLevel[iClient]);
	AddMenuItem(menu, "option1", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Bring the Pain!", g_iBringLevel[iClient]);
	AddMenuItem(menu, "option2", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Jammin' to the Music", g_iJamminLevel[iClient]);
	AddMenuItem(menu, "option3", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Weapons Training", g_iWeaponsLevel[iClient]);
	AddMenuItem(menu, "option4", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Mechanic Affinity (Bind 1)                ", g_iMetalLevel[iClient]);
	AddMenuItem(menu, "option5", text);
	FormatEx(text, sizeof(text), "	[Level %d]	Fire Storm (Bind 2)\n ", g_iFireLevel[iClient]);
	AddMenuItem(menu, "option6", text);
	
	AddMenuItem(menu, "option7", "Open In Website\n ");
	AddMenuItem(menu, "option8", "", ITEMDRAW_NOTEXT);

	decl String:strFinalOptionText[250];
	Format(strFinalOptionText, sizeof(strFinalOptionText),
		"Back\n \n=	=	=	=	=	=	=	=	=	=	=	=	=	=\
		%s\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ",
		strEndingNewLines);
	AddMenuItem(menu, "option9", strFinalOptionText);

	SetMenuExitButton(menu, false);
	DisplayMenu(menu, iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Overconfidence
Action:OverMenuDraw(iClient) 
{
	decl String:text[512];

	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Over[iClient] = WriteParticle(iClient, "md_ellis_over", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	Menu menu = CreateMenu(OverMenuHandler);

	char strStartingNewLines[32], strEndingNewLines[32];
	GetNewLinesToPushMenuDown(iClient, strStartingNewLines);
	GetNewLinesToPushMenuUp(iClient, strEndingNewLines);
	
	FormatEx(text, sizeof(text), "\
		%s 						Overconfidence (Level %d):\
		\n \
		\nLevel 1:\
		\n+8%%%% Reload Speed per Level\
		\n \
		\nIf Within %i Points Of Max Health:\
		\n	+2%%%% Speed\
		\n	+5%%%% Damage To All Guns per Level\
		\n \
		\nWhile On Adrenaline:\
		\n	+5 Temp Health per Level\
		\n	+5 Damage To All Guns per Level\
		\n	(Team) +2 Seconds Duration per Level\
		\n		- Stacks with every Ellis\
		\n \
		\n ",
		strStartingNewLines,
		g_iOverLevel[iClient],
		ELLIS_OVERCONFIDENCE_BUFF_HP_REQUIREMENT);
	SetMenuTitle(menu, text);

	decl String:strFinalOptionText[250];
	Format(strFinalOptionText, sizeof(strFinalOptionText),
		"Back\
		%s\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ",
		strEndingNewLines);
	AddMenuItem(menu, "option1", strFinalOptionText);

	SetMenuExitButton(menu, false);
	DisplayMenu(menu, iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Bring the Pain!
Action:BringMenuDraw(iClient) 
{
	decl String:text[512];

	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Bring[iClient] = WriteParticle(iClient, "md_ellis_bring", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	Menu menu = CreateMenu(BringMenuHandler);

	char strStartingNewLines[32], strEndingNewLines[32];
	GetNewLinesToPushMenuDown(iClient, strStartingNewLines);
	GetNewLinesToPushMenuUp(iClient, strEndingNewLines);
	
	FormatEx(text, sizeof(text), "\
		%s		Bring the Pain!(Level %d):\
		\n \
		\nOn Special Infected kill:\
		\n \
		\nLevel 1:\
		\nRegen +1 Temp Health per Level\
		\n+20 Clip Ammo per Level\
		\n(Stacks) +1%%%% Movement Speed\
		\n \
		\n \
		\nSkill Uses:\
		\n+4 Max (Stacks) per Level\
		\n ",
		strStartingNewLines,
		g_iBringLevel[iClient]);
	SetMenuTitle(menu, text);
	
	decl String:strFinalOptionText[250];
	Format(strFinalOptionText, sizeof(strFinalOptionText),
		"Back\
		%s\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ",
		strEndingNewLines);
	AddMenuItem(menu, "option1", strFinalOptionText);

	SetMenuExitButton(menu, false);
	DisplayMenu(menu, iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Weapons Training
Action:WeaponsMenuDraw(iClient) 
{
	decl String:text[512];

	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Weapons[iClient] = WriteParticle(iClient, "md_ellis_weapons", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	Menu menu = CreateMenu(WeaponsMenuHandler);

	char strStartingNewLines[32], strEndingNewLines[32];
	GetNewLinesToPushMenuDown(iClient, strStartingNewLines);
	GetNewLinesToPushMenuUp(iClient, strEndingNewLines);
		
	FormatEx(text, sizeof(text), "\
		%s		Weapons Training (Level %d):\
		\n \
		\nLevel 1:\
		\n+10%%%% Reload Speed per Level\
		\n(Team) +8%%%% Laser Accuracy per Level\
		\n \
		\nLevel 5:\
		\nAutomatic Laser Sight\
		\nEllis Can Carry 2 Primary Weapons\
		\n [WALK+ZOOM] To Cycle Weapons\
		\n ",
		strStartingNewLines,
		g_iWeaponsLevel[iClient]);
	SetMenuTitle(menu, text);
	
	decl String:strFinalOptionText[250];
	Format(strFinalOptionText, sizeof(strFinalOptionText),
		"Back\
		%s\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ",
		strEndingNewLines);
	AddMenuItem(menu, "option1", strFinalOptionText);

	SetMenuExitButton(menu, false);
	DisplayMenu(menu, iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Jammin' to the Music
Action:JamminMenuDraw(iClient) 
{
	decl String:text[512];

	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Jammin[iClient] = WriteParticle(iClient, "md_ellis_jammin", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	Menu menu = CreateMenu(JamminMenuHandler);

	char strStartingNewLines[32], strEndingNewLines[32];
	GetNewLinesToPushMenuDown(iClient, strStartingNewLines);
	GetNewLinesToPushMenuUp(iClient, strEndingNewLines);
	
	FormatEx(text, sizeof(text), "\
		%s		Jammin' to the Music (Level %d):\
		\n \
		\n Stash Up To 3 Extra Adrenaline Shots\
		\n	- No Cap on Tank Spawned Shots\
		\n \
		\n On Tank spawn:\
		\n \
		\n	Level 1:\
		\n	+1%%%% Movement Speed per Level\
		\n	+5 Temp Health per Level\
		\n \
		\n	Level 5:\
		\n	+1 Adrenaline Shot\
		\n	+1 Molotov\
		\n ",
		strStartingNewLines,
		g_iJamminLevel[iClient]);
	SetMenuTitle(menu, text);
	
	decl String:strFinalOptionText[250];
	Format(strFinalOptionText, sizeof(strFinalOptionText),
		"Back\
		%s\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ",
		strEndingNewLines);
	AddMenuItem(menu, "option1", strFinalOptionText);

	SetMenuExitButton(menu, false);
	DisplayMenu(menu, iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Metal Storm (Mechanic Affinity)
Action:MetalMenuDraw(iClient) 
{
	decl String:text[512];

	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Bring[iClient] = WriteParticle(iClient, "md_ellis_mechanic", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	Menu menu = CreateMenu(MetalMenuHandler);

	char strStartingNewLines[32], strEndingNewLines[32];
	GetNewLinesToPushMenuDown(iClient, strStartingNewLines);
	GetNewLinesToPushMenuUp(iClient, strEndingNewLines);
	
	FormatEx(text, sizeof(text), "\
		%s				Mechanic Affinity (Level %d):\
		\n \
		\nLevel 1:\
		\n+4 Clip Size per Level (SMG/Rifle/Sniper Only)\
		\n+7%%%% Firing Rate per Level\
		\n+8%%%% Reload Speed per Level\
		\n \
		\nLevel 5:\
		\n [WALK+USE] Double Firing Rate for 5 Seconds\
		\n	- Destroys Weapon After\
		\n \
		\n \
		\n					Bind 1: Ammo Refill\
		\n				+1 Use Every Other Level\
		\n \
		\nLevel 1:\
		\nDeploy An Ammo Stash\
		\n ",
		strStartingNewLines,
		g_iMetalLevel[iClient]);
	SetMenuTitle(menu, text);
	
	decl String:strFinalOptionText[250];
	Format(strFinalOptionText, sizeof(strFinalOptionText),
		"Back\
		%s\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ",
		strEndingNewLines);
	AddMenuItem(menu, "option1", strFinalOptionText);
	
	SetMenuExitButton(menu, false);
	DisplayMenu(menu, iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Fire Storm
Action:FireMenuDraw(iClient) 
{
	decl String:text[512];
	
	DeleteAllMenuParticles(iClient);
	if(g_bEnabledVGUI[iClient] == true && g_iClientTeam[iClient] == TEAM_SURVIVORS && IsPlayerAlive(iClient) == true)
	{
		g_iPID_MD_Ellis_Fire[iClient] = WriteParticle(iClient, "md_ellis_fire", 0.0);
		g_bShowingVGUI[iClient] =  true;
	}
	
	Menu menu = CreateMenu(FireMenuHandler);

	char strStartingNewLines[32], strEndingNewLines[32];
	GetNewLinesToPushMenuDown(iClient, strStartingNewLines);
	GetNewLinesToPushMenuUp(iClient, strEndingNewLines);
	
	FormatEx(text, sizeof(text), "\
		%s						Fire Storm(Level %d):\
		\n \
		\nLevel 1:\
		\n+6 Clip Size per Level (SMG/Rifle/Sniper Only)\
		\n+10%%%% Reload Speed per Level\
		\n+7%%%% Firing Rate per Level\
		\nFire Immunity\
		\n \
		\n \
		\n			Bind 2: Summon Kagu-Tsuchi's Wrath\
		\n						+1 Use Every Other Level\
		\n \
		\nLevel 1: +6 Seconds Of Incendiary Attacks\
		\nAnd Burn Duration per Level\
		\nBurning A Calm Witch\
		\nImmediately Neutralizes Her\
		\n ",
		strStartingNewLines,
		g_iFireLevel[iClient]);
	SetMenuTitle(menu, text);
	
	decl String:strFinalOptionText[250];
	Format(strFinalOptionText, sizeof(strFinalOptionText),
		"Back\
		%s\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ",
		strEndingNewLines);
	AddMenuItem(menu, "option1", strFinalOptionText);
	
	SetMenuExitButton(menu, false);
	DisplayMenu(menu, iClient, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

//Handlers//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Ellis Menu Handler
EllisMenuHandler(Menu menu, MenuAction:action, iClient, itemNum)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select) 
	{
		switch (itemNum)
		{
			case 0: //Overconfidence
			{
				OverMenuDraw(iClient);
			}
			case 1: //Bring the Pain!
			{
				BringMenuDraw(iClient);
			}
			case 2: //Jammin to the Music
			{
				JamminMenuDraw(iClient);
			}
			case 3: //Weapons Training
			{
				WeaponsMenuDraw(iClient);
			}
			case 4: //Mechanic Affinity
			{
				MetalMenuDraw(iClient); //uses metal for mechanic affinity
			}
			case 5: //Fire Storm
			{
				FireMenuDraw(iClient);
			}
			case 6: //Open In Website
			{
				OpenMOTDPanel(iClient, "", "http://xpmod.net/talents/survivors/ceda%20files/ellis/xpmod_ig_talents_survivors_ellis.html", MOTDPANEL_TYPE_URL);
				EllisMenuDraw(iClient);
			}
			case 8: //Back
			{
				TopSurvivorMenuDraw(iClient);
			}
		}
	}
}

//Overconfidence Handler
OverMenuHandler(Menu menu, MenuAction:action, iClient, itemNum)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select)
	{
		switch (itemNum)
		{
			case 0: //Back
            {
				EllisMenuDraw(iClient);
            }
        }
    }
}

//Bring the Pain Handler
BringMenuHandler(Menu menu, MenuAction:action, iClient, itemNum)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select)
	{
		switch (itemNum)
		{
			case 0: //Back
            {
				EllisMenuDraw(iClient);
            }
        }
    }
}


//Weapons Training Handler
WeaponsMenuHandler(Menu menu, MenuAction:action, iClient, itemNum)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select)
	{
		switch (itemNum)
		{
			case 0: //Back
            {
				EllisMenuDraw(iClient);
            }           
        }
    }
}


//Jammin to the Music Handler
JamminMenuHandler(Menu menu, MenuAction:action, iClient, itemNum)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select)
	{
		switch (itemNum)
		{
			case 0: //Back
            {
				EllisMenuDraw(iClient);
            }        
        }
    }
}


//Metal Storm Handler and Mechanic Affinity
MetalMenuHandler(Menu menu, MenuAction:action, iClient, itemNum)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select)
	{
		switch (itemNum)
		{
			case 0: //Back
            {
				EllisMenuDraw(iClient);
            }
        }
    }
}


//Fire Storm Handler
FireMenuHandler(Menu menu, MenuAction:action, iClient, itemNum)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select)
	{
		switch (itemNum)
		{
			case 0: //Back
            {
				EllisMenuDraw(iClient);
            }
        }
    }
}