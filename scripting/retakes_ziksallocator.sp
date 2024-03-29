#include <sourcemod>
#include <sdkhooks>
#include <sdktools_stringtables>
#include <sdktools_sound>
#include <sdktools_engine>
#include <sdktools_functions>
#include <cstrike>
#include <clientprefs>
#include <retakes>

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
//#include "ziksallocator/zikspoints.sp"
#include "ziksallocator/bombtime.sp"
#include "ziksallocator/oof.sp"
#include "ziksallocator/noscope.sp"
#include "ziksallocator/afk.sp"
#include "ziksallocator/clutchmode.sp"
#include "ziksallocator/menus.sp"

public Plugin myinfo =
{
    name = "CS:GO Retakes: ziks.net weapon allocator",
    author = "Ziks",
    description = "A more complex weapon allocator with extra configurable preferences.",
    version = "1.0.1",
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
    LoadTranslations( "ziksallocator.phrases" );

    SetupClientCookies();
#if defined ZIKS_POINTS
    ZiksPoints_OnPluginStart();
#endif
    Oof_OnPluginStart();

    SetupConVars();

    HookEvent( "player_death", Event_PlayerDeath, EventHookMode_Pre );
    HookEvent( "weapon_fire", Event_WeaponFire, EventHookMode_Pre );
    HookEvent( "bomb_beginplant", Event_BombBeginPlant, EventHookMode_Post );
    HookEvent( "bomb_planted", Event_BombPlanted, EventHookMode_Post );
    HookEvent( "bomb_defused", Event_BombDefused, EventHookMode_Post );
    HookEvent( "bomb_begindefuse", Event_BombBeginDefuse, EventHookMode_Post );
    HookEvent( "bomb_abortdefuse", Event_BombAbortDefuse, EventHookMode_Post );
    HookEvent( "bomb_exploded", Event_BombExploded, EventHookMode_Post );
    HookEvent( "round_poststart", Event_RoundPostStart, EventHookMode_Post );
    HookEvent( "round_end", Event_RoundEnd, EventHookMode_Post );
    HookEvent( "item_equip", Event_ItemEquip, EventHookMode_Post );

    for ( int client = 1; client <= MaxClients; ++client )
    {
        if ( IsClientValidAndInGame( client ) )
        {
            OnClientConnected( client );
            OnClientPutInServer( client );
        }
    }
}

public void OnMapStart()
{
    Oof_OnMapStart();
    ResetWinStreak();
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

    Afk_OnClientConnected( client );
    ClutchMode_OnClientConnected( client );

#if defined ZIKS_POINTS
    ZiksPoints_OnClientConnected( client );
#endif
}

public void OnClientDisconnect( int client )
{
#if defined ZIKS_POINTS
    ZiksPoints_OnClientDisconnect( client );
#endif
}

public void OnClientPutInServer( int client )
{
    SDKHook( client, SDKHook_OnTakeDamage, OnTakeDamage );
}

public Action Event_PlayerDeath( Event event, const char[] name, bool dontBroadcast )
{
    BombTime_PlayerDeath( event );
    NoScope_PlayerDeath( event );
    Oof_PlayerDeath( event );
#if defined ZIKS_POINTS
    ZiksPoints_PlayerDeath( event );
#endif

    return Plugin_Continue;
}

public Action Event_ItemEquip( Event event, const char[] name, bool dontBroadcast )
{
    NoScope_ItemEquip( event );

    return Plugin_Continue;
}

public Action Event_WeaponFire( Event event, const char[] name, bool dontBroadcast )
{
    NoScope_WeaponFire( event );

    return Plugin_Continue;
}

public Action Event_BombBeginPlant( Event event, const char[] name, bool dontBroadcast )
{
    BombTime_BombBeginPlant( event );

    return Plugin_Continue;
}

public Action Event_BombPlanted( Event event, const char[] name, bool dontBroadcast )
{
    BombTime_BombPlanted( event );

    return Plugin_Continue;
}

public Action Event_BombDefused( Event event, const char[] name, bool dontBroadcast )
{
    BombTime_BombDefused( event );

    return Plugin_Continue;
}

public Action Event_BombBeginDefuse( Event event, const char[] name, bool dontBroadcast )
{
    BombTime_BombBeginDefuse( event );

    return Plugin_Continue;
}

public Action Event_BombAbortDefuse( Event event, const char[] name, bool dontBroadcast )
{
    BombTime_BombAbortDefuse( event );

    return Plugin_Continue;
}

public Action Event_BombExploded( Event event, const char[] name, bool dontBroadcast )
{
    BombTime_BombExploded( event );
    
    return Plugin_Continue;
}

public Action Event_RoundPostStart( Event event, const char[] name, bool dontBroadcast )
{
    if ( !Retakes_Enabled() ) return Plugin_Continue;
    
    Afk_OnRoundStart();
    
    return Plugin_Continue;
}

public Action Event_RoundEnd( Event event, const char[] name, bool dontBroadcast )
{
    if ( !Retakes_Enabled() ) return Plugin_Continue;

    Afk_OnRoundEnd();

    return Plugin_Continue;
}

public void OnGameFrame()
{
    Oof_OnGameFrame();
}

public Action OnPlayerRunCmd( int client, int &buttons,
    int &impulse, float vel[3], float angles[3],
    int &weapon, int &subtype, int &cmdnum,
    int &tickcount, int &seed, int mouse[2] )
{
    if ( !Retakes_Enabled() ) return Plugin_Continue;

    Afk_OnPlayerInput( client, buttons, mouse );
    return Plugin_Continue;
}

public Action OnTakeDamage( int victim,
    int &attacker, int &inflictor,
    float &damage, int &damagetype, int &weapon,
    float damageForce[3], float damagePosition[3], int damagecustom )
{
    if ( !IsClientValidAndInGame( victim ) ) return Plugin_Continue;

    bool ignored = false;

    if ( GetIsHeadshotOnly() )
    {
        bool defusing = g_DefusingClient == victim && g_CurrentlyDefusing;
        bool willDie = GetClientHealth( victim ) <= damage;
        bool headShot = (damagetype & CS_DMG_HEADSHOT) == CS_DMG_HEADSHOT;

        ignored = !defusing && !willDie && !headShot;
    }

    if ( !ignored )
    {
        NoScope_OnTakeDamage( victim, attacker, inflictor, damage,
            damagetype, weapon, damageForce, damagePosition, damagecustom );

#if defined ZIKS_POINTS
        ZiksPoints_OnTakeDamage( victim, attacker, inflictor, damage,
            damagetype, weapon, damageForce, damagePosition, damagecustom );
#endif
    }

    return ignored ? Plugin_Handled : Plugin_Continue;
}

public void Retakes_OnTeamSizesSet( int& tCount, int& ctCount )
{
    ClutchMode_OnTeamSizesSet( tCount, ctCount );
}

public Action OnClientSayCommand( int client, const char[] command, const char[] args )
{
    Action result = Oof_OnClientSayCommand( client, command, args );
    if ( result != Plugin_Continue )
    {
        return result;
    }

#if defined ZIKS_POINTS
    static char ziksPointsChatCommands[][] = {
        "points", "zikspoints",
        ".points", ".zikspoints", ".ziks",
        "!points", "!zikspoints", "!ziks"
    };

    for ( int i = 0; i < sizeof(ziksPointsChatCommands); i++ )
    {
        if ( strcmp( args[0], ziksPointsChatCommands[i], false ) == 0 )
        {
            ZiksPoints_OnChatCommand( client );
            break;
        }
    }
#endif

    return Plugin_Continue;
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

public void Retakes_OnPostRoundEnqueue( ArrayList rankingQueue, ArrayList waitingQueue )
{
    ClutchMode_OnPostRoundEnqueue( rankingQueue );
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
