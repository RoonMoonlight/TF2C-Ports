#include <sourcemod>
#include <tf2c>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_VERSION "3.06"

#define TF_CLASS_SCOUT			1
#define TF_CLASS_SNIPER			2
#define TF_CLASS_SOLDIER		3
#define TF_CLASS_DEMOMAN		4
#define TF_CLASS_MEDIC			5
#define TF_CLASS_HEAVY			6
#define TF_CLASS_PYRO			7
#define TF_CLASS_SPY			8
#define TF_CLASS_ENGINEER		9
#define TF_CLASS_UNKNOWN		0

#define TF_TEAM_BLU				3
#define TF_TEAM_RED				2
#define TF_TEAM_GRN				4
#define TF_TEAM_YLW				5

public Plugin myinfo =
{
	name        = "Class Restrictions for Bots",
	author      = "luki1412, Roon",
	description = "Restrict classes in TF2C for bots.",
	version     = PLUGIN_VERSION,
	url         = "https://forums.alliedmods.net/member.php?u=43109"
}

bool g_bLateLoad;
ConVar g_hCvEnabled;
ConVar g_hCvLimits[6][10];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{	
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	ConVar hCvVersion = CreateConVar("sm_crb_version", PLUGIN_VERSION, "DO NOT CHANGE THIS CVAR", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_hCvEnabled                                = CreateConVar("sm_crb_enabled",       "1",  "Enables/disables restricting classes for bots.");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_DEMOMAN]  = CreateConVar("sm_crb_blu_demomen",   "-1", "Limits BLU bot demomen");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_ENGINEER] = CreateConVar("sm_crb_blu_engineers", "-1", "Limits BLU bot engineers");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_HEAVY]    = CreateConVar("sm_crb_blu_heavies",   "-1", "Limits BLU bot heavies");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_MEDIC]    = CreateConVar("sm_crb_blu_medics",    "-1", "Limits BLU bot medics");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_PYRO]     = CreateConVar("sm_crb_blu_pyros",     "-1", "Limits BLU bot pyros");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_SCOUT]    = CreateConVar("sm_crb_blu_scouts",    "-1", "Limits BLU bot scouts");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_SNIPER]   = CreateConVar("sm_crb_blu_snipers",   "-1", "Limits BLU bot snipers");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_SOLDIER]  = CreateConVar("sm_crb_blu_soldiers",  "-1", "Limits BLU bot soldiers");
	g_hCvLimits[TF_TEAM_BLU][TF_CLASS_SPY]      = CreateConVar("sm_crb_blu_spies",     "-1", "Limits BLU bot spies");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_DEMOMAN]  = CreateConVar("sm_crb_red_demomen",   "-1", "Limits RED bot demomen");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_ENGINEER] = CreateConVar("sm_crb_red_engineers", "-1", "Limits RED bot engineers");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_HEAVY]    = CreateConVar("sm_crb_red_heavies",   "-1", "Limits RED bot heavies");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_MEDIC]    = CreateConVar("sm_crb_red_medics",    "-1", "Limits RED bot medics");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_PYRO]     = CreateConVar("sm_crb_red_pyros",     "-1", "Limits RED bot pyros");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_SCOUT]    = CreateConVar("sm_crb_red_scouts",    "-1", "Limits RED bot scouts");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_SNIPER]   = CreateConVar("sm_crb_red_snipers",   "-1", "Limits RED bot snipers");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_SOLDIER]  = CreateConVar("sm_crb_red_soldiers",  "-1", "Limits RED bot soldiers");
	g_hCvLimits[TF_TEAM_RED][TF_CLASS_SPY]      = CreateConVar("sm_crb_red_spies",     "-1", "Limits RED bot spies");	
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_DEMOMAN]  = CreateConVar("sm_crb_grn_demomen",   "-1", "(Four-team maps only) Limits GRN bot demomen");
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_ENGINEER] = CreateConVar("sm_crb_grn_engineers", "-1", "(Four-team maps only) Limits GRN bot engineers");
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_HEAVY]    = CreateConVar("sm_crb_grn_heavies",   "-1", "(Four-team maps only) Limits GRN bot heavies");
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_MEDIC]    = CreateConVar("sm_crb_grn_medics",    "-1", "(Four-team maps only) Limits GRN bot medics");
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_PYRO]     = CreateConVar("sm_crb_grn_pyros",     "-1", "(Four-team maps only) Limits GRN bot pyros");
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_SCOUT]    = CreateConVar("sm_crb_grn_scouts",    "-1", "(Four-team maps only) Limits GRN bot scouts");
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_SNIPER]   = CreateConVar("sm_crb_grn_snipers",   "-1", "(Four-team maps only) Limits GRN bot snipers");
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_SOLDIER]  = CreateConVar("sm_crb_grn_soldiers",  "-1", "(Four-team maps only) Limits GRN bot soldiers");
	g_hCvLimits[TF_TEAM_GRN][TF_CLASS_SPY]      = CreateConVar("sm_crb_grn_spies",     "-1", "(Four-team maps only) Limits GRN bot spies");	
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_DEMOMAN]  = CreateConVar("sm_crb_ylw_demomen",   "-1", "(Four-team maps only) Limits YLW bot demomen");
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_ENGINEER] = CreateConVar("sm_crb_ylw_engineers", "-1", "(Four-team maps only) Limits YLW bot engineers");
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_HEAVY]    = CreateConVar("sm_crb_ylw_heavies",   "-1", "(Four-team maps only) Limits YLW bot heavies");
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_MEDIC]    = CreateConVar("sm_crb_ylw_medics",    "-1", "(Four-team maps only) Limits YLW bot medics");
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_PYRO]     = CreateConVar("sm_crb_ylw_pyros",     "-1", "(Four-team maps only) Limits YLW bot pyros");
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_SCOUT]    = CreateConVar("sm_crb_ylw_scouts",    "-1", "(Four-team maps only) Limits YLW bot scouts");
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_SNIPER]   = CreateConVar("sm_crb_ylw_snipers",   "-1", "(Four-team maps only) Limits YLW bot snipers");
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_SOLDIER]  = CreateConVar("sm_crb_ylw_soldiers",  "-1", "(Four-team maps only) Limits YLW bot soldiers");
	g_hCvLimits[TF_TEAM_YLW][TF_CLASS_SPY]      = CreateConVar("sm_crb_ylw_spies",     "-1", "(Four-team maps only) Limits YLW bot spies");	

	AutoExecConfig(true, "Class_Restrictions_For_Bots");
	if (g_bLateLoad)
	{
		OnConfigsExecuted();
	}

	HookEvent("player_spawn", Event_PlayerSpawn);
	SetConVarString(hCvVersion, PLUGIN_VERSION);	
}
//built in class limit needs to be disabled
public void OnConfigsExecuted() 
{
	SetConVarInt(FindConVar("tf_classlimit"), 0);
	SetConVarString(FindConVar("tf_bot_force_class"), "");
	//SetConVarInt(FindConVar("tf_bot_reevaluate_class_in_spawnroom"), 0); // Disabled in TF2C
	char mapName[PLATFORM_MAX_PATH];
	GetCurrentMap(mapName, sizeof(mapName));
	ServerCommand("exec \"%s.cfg\"", mapName);
}
//there is no space, so the server admins set up the cvars incorrectly. lets warn them through logs
void NoSpace()
{
	LogError("There is not enough space for another bot!");
	LogError("Setting BLU/RED/GRN/YLW scouts limit for bots to unlimited. Fix your class limits for bots!");
	SetConVarInt( g_hCvLimits[TF_TEAM_BLU][TF_CLASS_SCOUT], -1, false, false );
	SetConVarInt( g_hCvLimits[TF_TEAM_RED][TF_CLASS_SCOUT], -1, false, false );
	SetConVarInt( g_hCvLimits[TF_TEAM_GRN][TF_CLASS_SCOUT], -1, false, false );
	SetConVarInt( g_hCvLimits[TF_TEAM_YLW][TF_CLASS_SCOUT], -1, false, false );
}
//player spawned, lets do stuff
public void Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if(!GetConVarBool(g_hCvEnabled))
	{
		return;
	}

	int iUser = GetEventInt(event, "userid");
	int iClient = GetClientOfUserId(iUser);
	
	if(IsPlayerHereLoop(iClient))
	{	
		int iTeam = GetEventInt(event, "team");	
	
		switch (iTeam)
		{
			case TF_TEAM_RED:
			{
				if(IsThereEnoughSpace(TF_TEAM_RED) == false)
				{
					if(IsThereEnoughSpace(TF_TEAM_BLU) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_BLU);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_BLU);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					else if(IsThereEnoughSpace(TF_TEAM_GRN) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_GRN);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_GRN);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					else if(IsThereEnoughSpace(TF_TEAM_YLW) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_YLW);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_YLW);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					else
					{
						NoSpace();
						int i = SelectFreeClass(GetClientTeam(iClient));

						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
				}
			}
			case TF_TEAM_BLU:
			{
				if(IsThereEnoughSpace(TF_TEAM_BLU) == false)
				{
					if(IsThereEnoughSpace(TF_TEAM_RED) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_RED);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_RED);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					else if(IsThereEnoughSpace(TF_TEAM_GRN) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_GRN);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_GRN);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					else if(IsThereEnoughSpace(TF_TEAM_YLW) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_YLW);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_YLW);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					else
					{
						NoSpace();
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
				}
			}
			case TF_TEAM_GRN:
			{
				if(IsThereEnoughSpace(TF_TEAM_GRN) == false)
				{
					if(IsThereEnoughSpace(TF_TEAM_YLW) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_YLW);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_YLW);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					if(IsThereEnoughSpace(TF_TEAM_RED) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_RED);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_RED);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					if(IsThereEnoughSpace(TF_TEAM_BLU) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_BLU);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_BLU);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					else
					{
						NoSpace();
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
				}
			}
			case TF_TEAM_YLW:
			{
				if(IsThereEnoughSpace(TF_TEAM_YLW) == false)
				{
					if(IsThereEnoughSpace(TF_TEAM_GRN) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_GRN);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_GRN);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					if(IsThereEnoughSpace(TF_TEAM_BLU) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_BLU);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_BLU);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					if(IsThereEnoughSpace(TF_TEAM_RED) == true)
					{
						if(IsPlayerAlive(iClient)) 
						{
							SetEntProp(iClient, Prop_Send, "m_lifeState", 2);
							ChangeClientTeam(iClient, TF_TEAM_RED);
							SetEntProp(iClient, Prop_Send, "m_lifeState", 0);
						}
						else
						{
							ChangeClientTeam(iClient, TF_TEAM_RED);
						}
						
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
					else
					{
						NoSpace();
						int i = SelectFreeClass(GetClientTeam(iClient));
				
						if(i == 0)
						{
							ChangeClientTeam(iClient, 1);
							return;
						}
						
						TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
						
						if(IsPlayerAlive(iClient)) 
						{
							RequestFrame(RespawnPlayer, iUser);
						}
						
						return;
					}
				}
			}
			default:
			{
				return;
			}		
		}

		int iClass = GetEventInt(event, "class");	
		
		if(IsFull(iTeam, iClass))
		{
			int i = SelectFreeClass(GetClientTeam(iClient));
	
			if(i == 0)
			{
				ChangeClientTeam(iClient, 1);
				return;
			}
			
			TF2_SetPlayerClass(iClient, view_as<TFClassType>(i), _, true);
			
			if(IsPlayerAlive(iClient)) 
			{
				RequestFrame(RespawnPlayer, iUser);
			}
			
			return;
		}
	}
}
//respawn player callback
void RespawnPlayer(int iUser)
{
	int iClient = GetClientOfUserId(iUser);
	
	if(iClient && IsPlayerHereLoop(iClient))
	{
		TF2_RespawnPlayer(iClient);
	}
}
//how many players do have on a team
int GetBotClientsCount(int iTeam) 
{
	int clients = 0;
	
	for(int i = 1; i <= MaxClients; i++) 
	{
		if(IsPlayerHereLoop(i)) 
		{
			if(GetClientTeam(i) == iTeam)
			{
				clients++;
			}
		}
	}
	
	return clients;
}
//is there even enough space for the player on the team
bool IsThereEnoughSpace(int iTeam)
{
	int total = 0, classlimit = 0;
	
	for(int i = 1; i <= 9; i++)
	{
		classlimit = GetConVarInt(g_hCvLimits[iTeam][i]);
		
		if(classlimit != -1)
		{
			total += classlimit;
		}
		else
		{
			total = -1;
			break;
		}
	}
	
	if(total == -1)
	{
		return true;
	}
	else if(total == 0)
	{
		return false;
	}	
	else
	{
		int BotsCount = GetBotClientsCount(iTeam);
		
		if(total >= BotsCount)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}
//is class on that team full
bool IsFull(int iTeam, int iClass)
{
	int iLimit = GetConVarInt(g_hCvLimits[iTeam][iClass]);
	
	if(iLimit == -1)
	{
		return false;
	}
	else if(iLimit == 0)
	{
		return true;
	}
	
	int iCount = 0;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsPlayerHereLoop(i) && GetClientTeam(i) == iTeam && view_as<int>(TF2_GetPlayerClass(i)) == iClass)
		{
			iCount++;
		}
	}
	
	if(iCount > iLimit)
	{
		return true;
	}
	else
	{
		return false;
	}
}
//select a free class for the player
int SelectFreeClass(int iTeam)
{
	int x = 0;
	int classes[9] = {0, ...};

	for(int i = 1; i <= 9; i++)
	{
		if(!IsFull(iTeam, i))
		{
			classes[x] = i;
			x++;
		}
	}

	if(classes[0] == 0)
	{
		return 0;
	}
	
	if(x == 1)
	{
		return classes[0];
	}
	
	x--; 
	return classes[GetRandomUInt(0,x)];	
}
//custom get random int within range function
int GetRandomUInt(int min, int max)
{
	return RoundToFloor(GetURandomFloat() * (max - min + 1)) + min;
}
//basic check for players
bool IsPlayerHereLoop(int client)
{
	return (IsClientInGame(client) && IsFakeClient(client));
}