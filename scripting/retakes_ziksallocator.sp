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

public Action OnTakeDamage( int victim,
    int &attacker, int &inflictor,
    float &damage, int &damagetype, int &weapon,
    float damageForce[3], float damagePosition[3], int damagecustom )
{
    if ( !IsClientInGame( victim ) ) return Plugin_Continue;

    bool willDie = GetClientHealth( victim ) <= damage;
    if ( IsClientInGame( attacker ) )
    {
        char weaponClassName[64];
        GetClientWeapon( attacker, weaponClassName, sizeof(weaponClassName) );

        bool canNoScope = GetWeaponCanNoScope( weaponClassName );
        bool scoped = GetEntProp( attacker, Prop_Send, "m_bIsScoped" ) != 0;

        if ( canNoScope && !scoped )
        {
            float posDiff[3];
            GetClientAbsOrigin( attacker, posDiff );

            posDiff[0] -= damagePosition[0];
            posDiff[1] -= damagePosition[1];
            posDiff[2] -= damagePosition[2];

            float distance = SquareRoot(
                posDiff[0] * posDiff[0] +
                posDiff[1] * posDiff[1] +
                posDiff[2] * posDiff[2] ) * 0.01905;

            int distanceInt = RoundToFloor( distance );
            int distanceFrac = RoundFloat( (distance - distanceInt) * 10 );

            char attackerName[64];
            char victimName[64];

            GetClientName( attacker, attackerName, sizeof(attackerName) );
            GetClientName( victim, victimName, sizeof(victimName) );

            Retakes_MessageToAll( "{GREEN}%s{NORMAL} noscoped {GREEN}%s{NORMAL} from {LIGHT_RED}%i.%im{NORMAL} away!",
                attackerName, victimName, distanceInt, distanceFrac );
        }
    }

    if ( !GetIsHeadshotOnly() ) return Plugin_Continue;

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
