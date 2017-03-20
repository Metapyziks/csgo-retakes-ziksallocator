#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#include "ziksallocator/defines.sp"
#include "ziksallocator/types.sp"
#include "ziksallocator/config.sp"
#include "ziksallocator/helpers.sp"
#include "ziksallocator/weapons.sp"
#include "ziksallocator/grenades.sp"
#include "ziksallocator/loadouts.sp"
#include "ziksallocator/preferences.sp"
#include "ziksallocator/persistence.sp"
#include "ziksallocator/allocator.sp"
#include "ziksallocator/noscope.sp"
#include "ziksallocator/menus.sp"

public Plugin myinfo =
{
    name = "CS:GO Retakes: ziks.net weapon allocator",
    author = "Ziks",
    description = "A more complex weapon allocator with extra configurable preferences.",
    version = PLUGIN_VERSION,
    url = "https://github.com/Metapyziks/retakes-ziksallocator"
};

/**
 * Called when the plugin is fully initialized and all known external
 * references are resolved.
 *
 * @noreturn
 */
public void OnPluginStart()
{
    SetupClientCookies();
    SetupConVars();
    
    HookEvent( "player_death", Event_PlayerDeath, EventHookMode_Pre );
    HookEvent( "bomb_beginplant", Event_BombBeginPlant, EventHookMode_Post );
    HookEvent( "bomb_planted", Event_BombPlanted, EventHookMode_Post );
    HookEvent( "bomb_defused", Event_BombDefused, EventHookMode_Post );
    HookEvent( "bomb_begindefuse", Event_BombBeginDefuse, EventHookMode_Post );
    HookEvent( "bomb_exploded", Event_BombExploded, EventHookMode_Post );

    for( int client = 1; client <= MaxClients; client++ )
    {
		if( IsClientInGame( client ) )
        {
            OnClientConnected( client );
            OnClientPutInServer( client );
		}
	}
}

/**
 * Called once a client successfully connects.
 *
 * @param client    Client index.
 * @noreturn
 */
public void OnClientConnected( int client )
{
    ResetAllLoadouts( client );
    InvalidateLoadedCookies( client );
}

public void OnClientPutInServer( int client )
{
    SDKHook( client, SDKHook_OnTakeDamage, OnTakeDamage );
}

public Action Event_PlayerDeath( Event event, const char[] name, bool dontBroadcast )
{
    NoScope_PlayerDeath( event );
    return Plugin_Continue;
}

public Action Event_BombBeginPlant( Event event, const char[] name, bool dontBroadcast )
{
    int bomb = FindEntityByClassname( -1, "weapon_c4" );
    if ( bomb != -1 )
    {
        float armedTime = GetEntPropFloat( bomb, Prop_Send, "m_fArmedTime", 0 );
        SetEntPropFloat( bomb, Prop_Send, "m_fArmedTime", armedTime - 3, 0 );
    }

    return Plugin_Continue;
}

float g_DetonateTime = 0.0;
float g_DefuseEndTime = 0.0;
int g_DefusingClient = -1;

public Action Event_BombPlanted( Event event, const char[] name, bool dontBroadcast )
{
    g_DetonateTime = GetGameTime() + GetC4Timer();
    g_DefusingClient = -1;

    return Plugin_Continue;
}

public Action Event_BombDefused( Event event, const char[] name, bool dontBroadcast )
{
    int defuser = GetClientOfUserId( event.GetInt( "userid" ) );

    if ( defuser > MAXPLAYERS || !IsClientInGame( defuser ) ) return Plugin_Continue;

    float timeRemaining = g_DetonateTime - GetGameTime();

    char defuserName[64];
    GetClientName( defuser, defuserName, sizeof(defuserName) );

    char timeString[32];
    FloatToStringFixedPoint( timeRemaining, 2, timeString, sizeof(timeString) );

    Retakes_MessageToAll( "{GREEN}%s{NORMAL} defused with {LIGHT_RED}%s seconds{NORMAL} remaining!",
        defuserName, timeString );

    return Plugin_Continue;
}

public Action Event_BombBeginDefuse( Event event, const char[] name, bool dontBroadcast )
{
    int defuser = GetClientOfUserId( event.GetInt( "userid" ) );
    bool hasKit = event.GetBool( "haskit" );

    g_DefuseEndTime = GetGameTime() + (hasKit ? 5.0 : 10.0);
    g_DefusingClient = defuser;

    return Plugin_Continue;
}

public Action Event_BombExploded( Event event, const char[] name, bool dontBroadcast )
{
    float timeRemaining = g_DefuseEndTime - g_DetonateTime;

    if ( g_DefusingClient != -1 && IsClientInGame( g_DefusingClient ) && timeRemaining >= 0.0 )
    {
        char defuserName[64];
        GetClientName( g_DefusingClient, defuserName, sizeof(defuserName) );

        char timeString[32];
        FloatToStringFixedPoint( timeRemaining, 2, timeString, sizeof(timeString) );

        Retakes_MessageToAll( "{GREEN}%s{NORMAL} was too late by {LIGHT_RED}%s seconds{NORMAL}!",
            defuserName, timeString );
    }

    g_DetonateTime = GetGameTime() + GetC4Timer();
    return Plugin_Continue;
}

public Action OnTakeDamage( int victim,
    int &attacker, int &inflictor,
    float &damage, int &damagetype, int &weapon,
    float damageForce[3], float damagePosition[3], int damagecustom )
{
    if ( victim > MAXPLAYERS || !IsClientInGame( victim ) ) return Plugin_Continue;

    NoScope_OnTakeDamage( victim, attacker, inflictor, damage,
        damagetype, weapon, damageForce, damagePosition, damagecustom );

    if ( !GetIsHeadshotOnly() ) return Plugin_Continue;

    bool willDie = GetClientHealth( victim ) <= damage;
    bool headShot = (damagetype & CS_DMG_HEADSHOT) == CS_DMG_HEADSHOT;

    return (headShot || willDie) ? Plugin_Continue : Plugin_Handled;
}

/**
 * Called when a client issues a command to bring up a "guns" menu.
 *
 * @param client    Client index.
 * @noreturn
 */
public void Retakes_OnGunsCommand( int client )
{
    CheckForSavedLoadouts( client );
    GiveMainMenu( client );
}

public void Retakes_OnRoundWon( int winner, ArrayList tPlayers, ArrayList ctPlayers )
{
    if ( winner == CS_TEAM_T ) OnTerroristsWon();
    else OnCounterTerroristsWon();
}

/**
 * Called when player weapons are being allocated for the round.
 *
 * @param tPlayers  An ArrayList of the players on the terrorist team.
 * @param ctPlayers An ArrayList of the players on the counter-terrorist team.
 * @param bombsite
 * @noreturn
 */
public void Retakes_OnWeaponsAllocated( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
    int tCount = GetArraySize( tPlayers );
    int ctCount = GetArraySize( ctPlayers );

    for ( int i = 0; i < tCount; i++ )
    {
        int client = GetArrayCell( tPlayers, i );
        CheckForSavedLoadouts( client );
    }
    
    for ( int i = 0; i < ctCount; i++ )
    {
        int client = GetArrayCell( ctPlayers, i );
        CheckForSavedLoadouts( client );
    }

    WeaponAllocator( tPlayers, ctPlayers, bombsite );
}
