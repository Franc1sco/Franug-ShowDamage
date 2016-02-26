#include <sourcemod>

new bool:g_damage[MAXPLAYERS+1] = true;
Handle cvar_style;
int g_style;

public Plugin:myinfo =
{
	name = "SM Show Health Victim",
	author = "Franc1sco Steam: franug",
	description = "Show health victim for attacker",
	version = "3.1",
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	HookEvent("player_hurt", Event_PlayerHurt);
	cvar_style = CreateConVar("sm_showdamage_style", "1", "Choose the style that you prefer. Possible style are 1 or 2. By default is style 1");
	CreateConVar("sm_showhealthvictim_version", "3.1", "Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	RegConsoleCmd("sm_showdamage",HookSay);
	RegConsoleCmd("sm_sd",HookSay);
	
	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			g_damage[client] = true;
		}
	}
	g_style = GetConVarInt(cvar_style);
	HookConVarChange(cvar_style, CVarChange);
}

public CVarChange(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
	g_style = StringToInt(newValue);
}


public Action:HookSay(client,args)
{
	if(!client) return Plugin_Continue;
	
	if(g_damage[client]) 
	{
		PrintToChat(client, "Showdamage Disabled");
		g_damage[client] = false;
	}
	else 
	{
		PrintToChat(client, "Showdamage Enabled");
		g_damage[client] = true;
	}
	return Plugin_Handled;
}

public OnClientPostAdminCheck(client)
{
	g_damage[client] = true;
}

// al herir un jugador
public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{	
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!attacker || !g_damage[attacker]) // si no hay atacante no se sigue con el codigo
		return;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	new restante = GetClientHealth(client); // se obtiene la vida del cliente
	decl String:input[512];
	
	if(restante > 0) // si la vida del cliente es mayor a 0 (por lo que no esta muerto)
	{
		new damage = GetEventInt(event, "dmg_health"); // se obtiene el daño hecho
		
		if(g_style == 1) Format(input, 512, "<font color='#FFFFFF'>You did</font> <font color='#FF0000'>%i</font> <font color='#FFFFFF'>Damage to <font color='#0066FF'>%N</font>\n<font color='#FFFFFF'>Health Remaining:</font> <font color='#00CC00'>%i</font>", damage, client, restante); // se muestra el mensaje del daño
		else Format(input, 512, "<font color='#2EFE2E'>Zombie:</font> <font color='#FFFFFF'>-%N</font> \n<font size='30' color='#2EFE2E'>%i</font>           <font size='30' color='#B40404'>- %i</font>", client, restante, damage);
	}
	else
	{
		Format(input, 512, "<font color='#FFFFFF'>You Killed to</font> <font color='#0066FF'>%N</font>", client); // se muestra el mensaje de que le ha matado
	}
	
	PrintHintText(attacker, input);
}