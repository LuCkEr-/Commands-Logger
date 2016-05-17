#include <sourcemod>
#include <sdktools>

// Require new syntax and semicolons
#pragma newdecls required
#pragma semicolon 1

char g_sCmdLogPath[256];

#define DATA "1.0"

public Plugin myinfo =
{
    name = "SM Client Command Logging",
    author = "Franc1sco franug", 
    description = "Logging every command that the client use", 
    version = DATA, 
    url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	CreateConVar("sm_clientcommandlogging_version", DATA, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	for(int i=0;;i++)
	{
		BuildPath(Path_SM, g_sCmdLogPath, sizeof(g_sCmdLogPath), "logs/ChatLog_%d.log", i);
		if ( !FileExists(g_sCmdLogPath) )
			break;
	}
}

public void OnAllPluginsLoaded()
{
	AddCommandListener(Commands_CommandListener);
}

public Action Commands_CommandListener(int client, const char[] command, int argc)
{
	if ( !client || !IsClientInGame(client))
		return Plugin_Continue;

	int i_CmdLength;
	char s_Cmd[256];
	char s_steamID[32];
	char s_Timestamp[32];
	Handle h_LogFile = OpenFile(g_sCmdLogPath, "a");
	
	GetCmdArgString(s_Cmd, sizeof(s_Cmd));
	GetClientAuthId(client, AuthId_Steam2, s_steamID, 32, true);
	FormatTime(s_Timestamp, sizeof(s_Timestamp), "%X | %d/%m/%Y");
	strcopy(s_Cmd, sizeof(s_Cmd), s_Cmd[1]);
	i_CmdLength = strlen(s_Cmd);
	
	if(i_CmdLength) 
		s_Cmd[i_CmdLength-1] = 0;
	
	WriteFileLine(h_LogFile, "%s [%s | %N]: %s | %s", s_Timestamp, s_steamID, client, command, s_Cmd);
	
	CloseHandle(h_LogFile);

	return Plugin_Continue;
}