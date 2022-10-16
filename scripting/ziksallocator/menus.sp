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
    Format( buffer, sizeof(buffer), "%t", "MoneyAvailable", money );

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
    char buffer[64];

    FillMenu( menu, BACK_ITEM_INDEX );

    Format( buffer, sizeof(buffer), "%t", "Back" );
    menu.DrawItem( buffer );

    FillMenu( menu, EXIT_ITEM_INDEX );

    Format( buffer, sizeof(buffer), "%t", "Exit" );
    menu.DrawItem( buffer );
}

bool AddMenuBool( Handle menu, bool value, const char[] display )
{
    return AddMenuItem( menu, value ? "TRUE" : "FALSE", display );
}

bool GetMenuBool( Handle menu, int position, bool defaultValue = false )
{
    char buffer[32];

    if ( !GetMenuItem( menu, position, buffer, sizeof(buffer) ) )
    {
        return defaultValue;
    }

    return strcmp( buffer, "TRUE" ) == 0;
}

bool AddMenuInt( Handle menu, int value, const char[] display )
{
    char buffer[32];

    IntToString( value, buffer, sizeof(buffer) );

    return AddMenuItem( menu, buffer, display );
}

int GetMenuInt( Handle menu, int position, int defaultValue = 0 )
{
    char buffer[32];

    if ( !GetMenuItem( menu, position, buffer, sizeof(buffer) ) )
    {
        return defaultValue;
    }

    return StringToInt( buffer, 10 );
}

#include "ziksallocator/menus/main.sp"
#include "ziksallocator/menus/team.sp"
#include "ziksallocator/menus/resetconfirm.sp"
#include "ziksallocator/menus/loadout.sp"
#include "ziksallocator/menus/weaponcategory.sp"
#include "ziksallocator/menus/weapon.sp"
