#include <sourcemod>
#include <srccoop_api>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
	name = "SourceCoop Thirdperson",
	author = "Alienmario (Original thirdperson code by Dr. McKay)",
	description = "Thirdperson view switcher",
	version = "1.0.0",
	url = "https://github.com/ampreeT/SourceCoop"
};

#define MENUITEM_TOGGLE "Toggle thirdperson"

ConVar pEnabledCvar;
ConVar pCheatsCvar;
bool bIsInThirdperson[MAXPLAYERS+1];

public void OnPluginStart()
{
	RegConsoleCmd("sm_thirdperson", Command_Thirdperson, "Type !thirdperson to go into thirdperson mode");
	RegConsoleCmd("sm_firstperson", Command_Firstperson, "Type !firstperson to exit thirdperson mode");
	pEnabledCvar = CreateConVar("sourcecoop_thirdperson_enabled", "1", "Is thirdperson enabled?");
	pCheatsCvar = FindConVar("sv_cheats");
	HookConVarChange(pEnabledCvar, CvarChanged);
	
	if (LibraryExists(SRCCOOP_LIBRARY))
	{
		OnSourceCoopStarted();
	}
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, SRCCOOP_LIBRARY))
	{
		OnSourceCoopStarted();
	}
}

void OnSourceCoopStarted()
{
	TopMenu pCoopMenu = GetCoopTopMenu();
	TopMenuObject pSettingsMenu = pCoopMenu.FindCategory(COOPMENU_CATEGORY_PLAYER);
	if(pSettingsMenu != INVALID_TOPMENUOBJECT)
	{
		pCoopMenu.AddItem(MENUITEM_TOGGLE, ThirdPersonMenuHandler, pSettingsMenu);
	}
}

public void ThirdPersonMenuHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, MENUITEM_TOGGLE);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		FakeClientCommand(param, bIsInThirdperson[param]? "sm_firstperson" : "sm_thirdperson");
		topmenu.Display(param, TopMenuPosition_LastCategory);
	}
}

public void CvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(pEnabledCvar.BoolValue)
			{
				SendConVarValue(i, pCheatsCvar, "1");
			}
			else
			{
				ClientCommand(i, "firstperson");
				SendConVarValue(i, pCheatsCvar, "0");
				bIsInThirdperson[i] = false;
			}
		}
	}
}

public void OnClientPutInServer(int client)
{
	bIsInThirdperson[client] = false;
	if(pEnabledCvar.BoolValue) {
		SendConVarValue(client, pCheatsCvar, "1");
	}
}

public Action Command_Thirdperson(int client, int args)
{
	if(!pEnabledCvar.BoolValue)
	{
		MsgReply(client, "Thirdperson mode is currently disabled.");
		return Plugin_Handled;
	}
	SetThirdperson(client, true);
	MsgReply(client, "You are now in thirdperson mode.");
	return Plugin_Handled;
}

public Action Command_Firstperson(int client, int args)
{
	if(!pEnabledCvar.BoolValue)
	{
		MsgReply(client, "Thirdperson mode is currently disabled");
		return Plugin_Handled;
	}
	SetThirdperson(client, false);
	MsgReply(client, "You are no longer in thirdperson mode.");
	return Plugin_Handled;
}

void SetThirdperson(int client, bool enable)
{
	if(enable)
	{
		SendConVarValue(client, pCheatsCvar, "1");
		ClientCommand(client, "thirdperson");
		bIsInThirdperson[client] = true;
	}
	else
	{
		ClientCommand(client, "firstperson");
		bIsInThirdperson[client] = false;
	}
}