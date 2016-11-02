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

/**
 * Appends a text entry to the given menu describing how much money
 * is available, but only if the given loadout specifies that money
 * should be shown.
 *
 * @param menu      Menu to add the text entry to.
 * @param loadout   Loadout this menu corresponds to.
 * @param money     Amount of money to display.
 * @noreturn
 */
void AddMoneyAvailableItems( Panel menu, RTLoadout loadout, int money )
{
    if ( !ShouldShowMoney( loadout ) ) return;

    char buffer[64];
    Format( buffer, sizeof(buffer), "Money available: $%i", money );

    menu.DrawItem( buffer, ITEMDRAW_RAWLINE );
}

/**
 * Adds blank entries to a menu until its current key is equal to
 * the given value.
 *
 * @param menu      Menu to fill.
 * @param targetKey Key value to fill up to.
 * @noreturn
 */
void FillMenu( Panel menu, int targetKey )
{
    while ( menu.CurrentKey < targetKey )
    {
        menu.DrawItem( " ", ITEMDRAW_RAWLINE  );
        menu.CurrentKey += 1;
    }
}

/**
 * Adds Back and Exit buttons to the end of the given menu.
 *
 * @note            Added at the keys given by BACK_ITEM_INDEX
 *                  and EXIT_ITEM_INDEX respectively.
 * @param menu      Menu to append the buttons to.
 * @noreturn
 */
void AddBackExitItems( Panel menu )
{
    FillMenu( menu, BACK_ITEM_INDEX );
    menu.DrawItem( "Back" );
    FillMenu( menu, EXIT_ITEM_INDEX );
    menu.DrawItem( "Exit" );
}

#include "menus/main.sp"
#include "menus/team.sp"
#include "menus/resetconfirm.sp"
#include "menus/loadout.sp"
#include "menus/weaponcategory.sp"
#include "menus/weapon.sp"
