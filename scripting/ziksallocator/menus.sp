#define BACK_ITEM_INDEX 7
#define EXIT_ITEM_INDEX 9

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

void FillMenu( Panel menu, int targetKey )
{
    while ( menu.CurrentKey < targetKey )
    {
        menu.DrawItem( " ", ITEMDRAW_RAWLINE  );
        menu.CurrentKey += 1;
    }
}

void AddBackExitItems( Panel menu )
{
    FillMenu( menu, BACK_ITEM_INDEX );
    menu.DrawItem( "Back" );
    FillMenu( menu, EXIT_ITEM_INDEX );
    menu.DrawItem( "Exit" );
}

#include "menus/main.sp"
#include "menus/team.sp"
#include "menus/loadout.sp"
#include "menus/weaponcategory.sp"
#include "menus/weapon.sp"
