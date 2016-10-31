#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#include "retakes_ziksallocator/defines.sp"
#include "retakes_ziksallocator/types.sp"
#include "retakes_ziksallocator/helpers.sp"
#include "retakes_ziksallocator/weapons.sp"
#include "retakes_ziksallocator/grenades.sp"
#include "retakes_ziksallocator/loadouts.sp"
#include "retakes_ziksallocator/preferences.sp"
#include "retakes_ziksallocator/persistence.sp"
#include "retakes_ziksallocator/allocator.sp"
#include "retakes_ziksallocator/menus.sp"

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
}

/**
 * Called once a client successfully connects.
 *
 * @param client    Client index.
 * @noreturn
 */
public void OnClientConnected( int client )
{
    if ( !RestoreLoadouts( client ) )
    {
        ResetAllLoadouts( client );
    }
}

/**
 * Called once a client's saved cookies have been loaded from the database.
 *
 * @param client    Client index.
 * @noreturn
 */
public void OnClientCookiesCached( int client )
{
    if ( IsFakeClient( client ) ) return;

    RestoreLoadouts( client );
}

/**
 * Called when a client issues a command to bring up a "guns" menu.
 *
 * @param client    Client index.
 * @noreturn
 */
public void Retakes_OnGunsCommand( int client )
{
    GiveMainMenu( client );
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
    WeaponAllocator( tPlayers, ctPlayers, bombsite );
}
