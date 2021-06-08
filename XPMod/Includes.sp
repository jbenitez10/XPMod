// Global Variables
#include "XPMod/GlobalVariables/Global_Variables.sp"
#include "XPMod/GlobalVariables/ConVars.sp"
#include "XPMod/GlobalVariables/Admin.sp"
#include "XPMod/GlobalVariables/Infected.sp"
#include "XPMod/GlobalVariables/Models_Particles_Anims.sp"
#include "XPMod/GlobalVariables/Offsets_Reload_SDKCalls.sp"
#include "XPMod/GlobalVariables/Sounds.sp"
#include "XPMod/GlobalVariables/Survivors.sp"
#include "XPMod/GlobalVariables/Talent_Levels.sp"
#include "XPMod/GlobalVariables/Timers.sp"
#include "XPMod/GlobalVariables/XP_Levels_Confirm.sp"
//Remove Testing before release                       /////////////////////////////////////////////////////////////////////////
#include "XPMod/Misc/Testing.sp"
// Misc
#include "XPMod/Misc/Debug.sp"
#include "XPMod/Misc/Admin_Commands.sp"
#include "XPMod/Misc/Switch_Teams.sp"
#include "XPMod/Misc/Generic_Functions.sp"
#include "XPMod/Misc/Setup.sp"
#include "XPMod/Misc/ResetVariables.sp"
#include "XPMod/Misc/ConVars.sp"
#include "XPMod/Misc/Particle_Effects.sp"
#include "XPMod/Misc/Precache.sp"
#include "XPMod/Misc/Weapons.sp"
#include "XPMod/Misc/MovementSpeed.sp"
#include "XPMod/Misc/Statistics.sp"
#include "XPMod/Misc/Statistics_Panel.sp"
#include "XPMod/Misc/Survivor_Functions.sp"
#include "XPMod/Misc/SpawnInfected.sp"
#include "XPMod/Misc/VictimHealthMeter.sp"
//Database Management
#include "XPMod/Database/Database.sp"
#include "XPMod/Database/Models/DB_Users.sp"
#include "XPMod/Database/User_Management.sp"
#include "XPMod/Database/Ban_Management.sp"
#include "XPMod/Database/Statistics.sp"
//Experience
#include "XPMod/XP/XP_Management.sp"
#include "XPMod/XP/XP_Events.sp"
//Menu Navigation Files
#include "XPMod/Menus/Menu_Main.sp"
#include "XPMod/Menus/Menu_Admin.sp"
#include "XPMod/Menus/Menu_NewUser.sp"
#include "XPMod/Menus/Menu_Confirm.sp"
#include "XPMod/Menus/Menu_Loadouts.sp"
#include "XPMod/Menus/S/Menu_Survivors.sp"
#include "XPMod/Menus/S/Menu_Rochelle.sp"
#include "XPMod/Menus/S/Menu_Coach.sp"
#include "XPMod/Menus/S/Menu_Ellis.sp"
#include "XPMod/Menus/S/Menu_Nick.sp"
#include "XPMod/Menus/S/Menu_Bill.sp"
#include "XPMod/Menus/S/Menu_Louis.sp"
#include "XPMod/Menus/I/Menu_Infected.sp"
#include "XPMod/Menus/I/Menu_Boomer.sp"
#include "XPMod/Menus/I/Menu_Smoker.sp"
#include "XPMod/Menus/I/Menu_Hunter.sp"
#include "XPMod/Menus/I/Menu_Spitter.sp"
#include "XPMod/Menus/I/Menu_Charger.sp"
#include "XPMod/Menus/I/Menu_Jockey.sp"
#include "XPMod/Menus/I/Tanks/Menu_Tank.sp"
#include "XPMod/Menus/I/Tanks/Menu_Tank_Fire.sp"
#include "XPMod/Menus/I/Tanks/Menu_Tank_Ice.sp"
#include "XPMod/Menus/I/Tanks/Menu_Tank_NecroTanker.sp"
#include "XPMod/Menus/I/Tanks/Menu_Tank_Vampiric.sp"
//Game Event Files
#include "XPMod/Events/Events_Main.sp"
#include "XPMod/Events/Events_SDK_Hooks.sp"
#include "XPMod/Events/Events_OnGameFrame.sp"
#include "XPMod/Events/Events_OnPlayerRunCmd.sp"
#include "XPMod/Events/Events_Survivors.sp"
#include "XPMod/Events/Events_Infected.sp"
#include "XPMod/Events/Events_Hurt.sp"
#include "XPMod/Events/Events_Death.sp"
#include "XPMod/Events/Events_Reload.sp"
#include "XPMod/Events/Events_Interact.sp"
//Ability Files
#include "XPMod/Talents/Talents_Load.sp"
#include "XPMod/Talents/S/Talents_Rochelle.sp"
#include "XPMod/Talents/S/Talents_Coach.sp"
#include "XPMod/Talents/S/Talents_Ellis.sp"
#include "XPMod/Talents/S/Talents_Nick.sp"
#include "XPMod/Talents/S/Talents_Bill.sp"
#include "XPMod/Talents/S/Talents_Louis.sp"
#include "XPMod/Talents/I/Enhance_CI.sp"
#include "XPMod/Talents/I/Talents_Boomer.sp"
#include "XPMod/Talents/I/Talents_Smoker.sp"
#include "XPMod/Talents/I/Talents_Hunter.sp"
#include "XPMod/Talents/I/Talents_Spitter.sp"
#include "XPMod/Talents/I/Talents_Charger.sp"
#include "XPMod/Talents/I/Talents_Jockey.sp"
#include "XPMod/Talents/I/Tanks/Talents_Tank.sp"
#include "XPMod/Talents/I/Tanks/Tank_Rocks.sp"
#include "XPMod/Talents/I/Tanks/Talents_Tank_Fire.sp"
#include "XPMod/Talents/I/Tanks/Talents_Tank_Ice.sp"
#include "XPMod/Talents/I/Tanks/Talents_Tank_NecroTanker.sp"
#include "XPMod/Talents/I/Tanks/Talents_Tank_Vampiric.sp"
//Binded Key Press Files
#include "XPMod/Binds/Binds.sp"
#include "XPMod/Binds/Bind1/S/Bind1_Bill.sp"
#include "XPMod/Binds/Bind1/S/Bind1_Coach.sp"
#include "XPMod/Binds/Bind1/S/Bind1_Rochelle.sp"
#include "XPMod/Binds/Bind1/S/Bind1_Ellis.sp"
#include "XPMod/Binds/Bind1/S/Bind1_Nick.sp"
#include "XPMod/Binds/Bind1/S/Bind1_Louis.sp"
#include "XPMod/Binds/Bind1/I/Bind1_Boomer.sp"
#include "XPMod/Binds/Bind1/I/Bind1_Smoker.sp"
#include "XPMod/Binds/Bind1/I/Bind1_Hunter.sp"
#include "XPMod/Binds/Bind1/I/Bind1_Spitter.sp"
#include "XPMod/Binds/Bind1/I/Bind1_Charger.sp"
#include "XPMod/Binds/Bind1/I/Bind1_Jockey.sp"
#include "XPMod/Binds/Bind2/S/Bind2_Bill.sp"
#include "XPMod/Binds/Bind2/S/Bind2_Coach.sp"
#include "XPMod/Binds/Bind2/S/Bind2_Rochelle.sp"
#include "XPMod/Binds/Bind2/S/Bind2_Ellis.sp"
#include "XPMod/Binds/Bind2/S/Bind2_Nick.sp"
#include "XPMod/Binds/Bind2/S/Bind2_Louis.sp"
#include "XPMod/Binds/Bind2/I/Bind2_Boomer.sp"
#include "XPMod/Binds/Bind2/I/Bind2_Smoker.sp"
#include "XPMod/Binds/Bind2/I/Bind2_Hunter.sp"
#include "XPMod/Binds/Bind2/I/Bind2_Spitter.sp"
#include "XPMod/Binds/Bind2/I/Bind2_Charger.sp"
#include "XPMod/Binds/Bind2/I/Bind2_Jockey.sp"
//Timer Files
#include "XPMod/Timers/Timers_Generic.sp"
#include "XPMod/Timers/Timers_Messages.sp"
#include "XPMod/Timers/S/Timers_Rochelle.sp"
#include "XPMod/Timers/S/Timers_Coach.sp"
#include "XPMod/Timers/S/Timers_Ellis.sp"
#include "XPMod/Timers/S/Timers_Nick.sp"
#include "XPMod/Timers/S/Timers_Bill.sp"
#include "XPMod/Timers/S/Timers_Louis.sp"
#include "XPMod/Timers/I/Timers_Boomer.sp"
#include "XPMod/Timers/I/Timers_Smoker.sp"
#include "XPMod/Timers/I/Timers_Hunter.sp"
#include "XPMod/Timers/I/Timers_Spitter.sp"
#include "XPMod/Timers/I/Timers_Charger.sp"
#include "XPMod/Timers/I/Timers_Jockey.sp"
#include "XPMod/Timers/I/Timers_Tank.sp"