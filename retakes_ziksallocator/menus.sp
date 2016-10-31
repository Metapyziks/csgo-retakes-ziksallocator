#define BACK_ITEM_INDEX 8
#define EXIT_ITEM_INDEX (BACK_ITEM_INDEX + 1)

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

void AddMoneyAvailableItems( Panel menu, RTLoadout loadout, int moneyAvailable )
{
    if ( !ShouldShowMoney( loadout ) ) return;

    char buffer[64];
    Format( buffer, sizeof(buffer), "Money available: $%i", moneyAvailable );

    menu.DrawItem( buffer, ITEMDRAW_RAWLINE );
}

void AddBackExitItems( Panel menu )
{
    menu.DrawItem( " ", ITEMDRAW_RAWLINE  );
    menu.CurrentKey = BACK_ITEM_INDEX;
    menu.DrawItem( "Back" );
    menu.DrawItem( "Exit" );
}

#include "retakes_ziksallocator/menus/main.sp"
#include "retakes_ziksallocator/menus/team.sp"
#include "retakes_ziksallocator/menus/loadout.sp"
#include "retakes_ziksallocator/menus/weaponcategory.sp"
#include "retakes_ziksallocator/menus/weapon.sp"
