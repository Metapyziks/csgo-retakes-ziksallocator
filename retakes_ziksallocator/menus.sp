/**
 * Stores the last team selected in the guns menu by each client.
 */
int g_MenuStateTeam[MAXPLAYERS+1];

/**
 * Stores the last loadout type selected in the guns menu by each client.
 */
RTLoadout g_MenuStateLoadout[MAXPLAYERS+1];

/**
 * Stores the last weapon category selected in the guns menu by each client.
 */
CSWeaponCategory g_MenuStateCategory[MAXPLAYERS+1];

#include "retakes_ziksallocator/menus/main.sp"
#include "retakes_ziksallocator/menus/team.sp"
#include "retakes_ziksallocator/menus/loadout.sp"
#include "retakes_ziksallocator/menus/weaponcategory.sp"
#include "retakes_ziksallocator/menus/weapon.sp"
