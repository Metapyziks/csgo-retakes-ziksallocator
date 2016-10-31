#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#define TEAM_COUNT 2

#define MENU_TIME_LENGTH 15

#define MAX_NADE_VALUE 800

#define LOADOUT_KEVLAR_COST 650
#define LOADOUT_HELMET_COST 350
#define LOADOUT_DEFUSE_COST 400

public Plugin myinfo = {
    name = "CS:GO Retakes: ziks.net weapon allocator",
    author = "Ziks",
    description = "A more complex weapon allocator with customizability",
    version = PLUGIN_VERSION,
    url = "https://github.com/Metapyziks/retakes-ziksallocator"
};

/**
 * Enumeration of all weapons available in the menu.
 * Weapons in the same category are contiguous.
 */
enum CSWeapon
{
    WEAPON_NONE,

    WEAPON_GLOCK,
    WEAPON_HKP2000,
    WEAPON_P250,
    WEAPON_ELITE,
    WEAPON_TEC9,
    WEAPON_FIVESEVEN,
    WEAPON_CZ75A,
    WEAPON_DEAGLE,

    WEAPON_MAC10,
    WEAPON_MP9,
    WEAPON_UMP45,
    WEAPON_BIZON,
    WEAPON_MP7,
    WEAPON_P90,

    WEAPON_NOVA,
    WEAPON_XM1014,
    WEAPON_SAWEDOFF,
    WEAPON_MAG7,
    WEAPON_M249,
    WEAPON_NEGEV,

    WEAPON_GALILAR,
    WEAPON_FAMAS,
    WEAPON_SSG08,
    WEAPON_AK47,
    WEAPON_M4A1,
    WEAPON_M4A1_SILENCER,
    WEAPON_SG556,
    WEAPON_AUG,
    WEAPON_AWP,
    WEAPON_G3SG1,
    WEAPON_SCAR20
}

/**
 * Weapon allocator loadout types.
 */
enum LoadoutType
{
    LOADOUT_PISTOL,
    LOADOUT_FORCE,
    LOADOUT_FULL,
    LOADOUT_SNIPER
}

/**
 * Weapon selection menu categories.
 */
enum CSWeaponCategory
{
    WCAT_PISTOL,
    WCAT_SMG,
    WCAT_HEAVY,
    WCAT_RIFLE
}

/**
 * Categories for primary weapons.
 */
CSWeaponCategory g_PrimaryCategories[] = {
    WCAT_SMG,
    WCAT_HEAVY,
    WCAT_RIFLE
};

/**
 * Gets the display name of the given loadout type.
 *
 * @param loadout   Loadout type to get the name of.
 * @param buffer    Character array to write the name to.
 * @param maxLength Size of the destination character array.
 */
void GetLoadoutName( LoadoutType loadout, char[] buffer, int maxLength )
{
    switch ( loadout )
    {
        case LOADOUT_PISTOL: strcopy( buffer, maxLength, "Pistol" );
        case LOADOUT_FORCE:  strcopy( buffer, maxLength, "Force Buy" );
        case LOADOUT_FULL:   strcopy( buffer, maxLength, "Full Buy" );
        case LOADOUT_SNIPER: strcopy( buffer, maxLength, "AWP" );
    }
}

/**
 * Gets the display name of the given weapon category.
 *
 * @param loadout   Weapon category to get the name of.
 * @param buffer    Character array to write the name to.
 * @param maxLength Size of the destination character array.
 */
void GetWeaponCategoryName( CSWeaponCategory category, char[] buffer, int maxLength )
{
    switch ( category )
    {
        case WCAT_PISTOL: strcopy( buffer, maxLength, "Pistols" );
        case WCAT_SMG:    strcopy( buffer, maxLength, "SMGs" );
        case WCAT_HEAVY:  strcopy( buffer, maxLength, "Heavys" );
        case WCAT_RIFLE:  strcopy( buffer, maxLength, "Rifles" );
    }
}

/**
 * Gets an initialism of the given team number.
 *
 * @param loadout   Team number to get the abbreviation of.
 * @param buffer    Character array to write the abbreviation to.
 * @param maxLength Size of the destination character array.
 */
void GetTeamAbbreviation( int team, char[] buffer, int maxLength )
{
    switch ( team )
    {
        case CS_TEAM_T:  strcopy( buffer, maxLength, "T" );
        case CS_TEAM_CT: strcopy( buffer, maxLength, "CT" );
    }
}

/**
 * Gets the display name of the given weapon.
 *
 * @param loadout   Weapon to get the name of.
 * @param buffer    Character array to write the name to.
 * @param maxLength Size of the destination character array.
 */
void GetWeaponName( CSWeapon weapon, char[] buffer, int maxLength )
{
    switch ( weapon )
    {
        case WEAPON_NONE:      strcopy( buffer, maxLength, "None" );

        case WEAPON_GLOCK:     strcopy( buffer, maxLength, "Glock" );
        case WEAPON_HKP2000:   strcopy( buffer, maxLength, "P2000 / USP-S" );
        case WEAPON_P250:      strcopy( buffer, maxLength, "P250" );
        case WEAPON_ELITE:     strcopy( buffer, maxLength, "Dual Barettas" );
        case WEAPON_TEC9:      strcopy( buffer, maxLength, "Tec-9" );
        case WEAPON_FIVESEVEN: strcopy( buffer, maxLength, "Five-SeveN" );
        case WEAPON_CZ75A:     strcopy( buffer, maxLength, "CZ75 Auto" );
        case WEAPON_DEAGLE:    strcopy( buffer, maxLength, "Desert Eagle" );

        case WEAPON_MAC10:     strcopy( buffer, maxLength, "MAC-10" );
        case WEAPON_MP9:       strcopy( buffer, maxLength, "MP9" );
        case WEAPON_UMP45:     strcopy( buffer, maxLength, "UMP-45" );
        case WEAPON_BIZON:     strcopy( buffer, maxLength, "PP-Bizon" );
        case WEAPON_MP7:       strcopy( buffer, maxLength, "MP7" );
        case WEAPON_P90:       strcopy( buffer, maxLength, "P90" );

        case WEAPON_NOVA:      strcopy( buffer, maxLength, "Nova" );
        case WEAPON_SAWEDOFF:  strcopy( buffer, maxLength, "Sawed-Off" );
        case WEAPON_MAG7:      strcopy( buffer, maxLength, "MAG-7" );
        case WEAPON_XM1014:    strcopy( buffer, maxLength, "XM1014" );
        case WEAPON_M249:      strcopy( buffer, maxLength, "M249" );
        case WEAPON_NEGEV:     strcopy( buffer, maxLength, "Negev" );

        case WEAPON_GALILAR:       strcopy( buffer, maxLength, "Galil AR" );
        case WEAPON_FAMAS:         strcopy( buffer, maxLength, "FAMAS" );
        case WEAPON_SSG08:         strcopy( buffer, maxLength, "SSG 08" );
        case WEAPON_AK47:          strcopy( buffer, maxLength, "AK-47" );
        case WEAPON_M4A1:          strcopy( buffer, maxLength, "M4A4" );
        case WEAPON_M4A1_SILENCER: strcopy( buffer, maxLength, "M4A1-S" );
        case WEAPON_SG556:         strcopy( buffer, maxLength, "SG 553" );
        case WEAPON_AUG:           strcopy( buffer, maxLength, "AUG" );
        case WEAPON_AWP:           strcopy( buffer, maxLength, "AWP" );
        case WEAPON_G3SG1:         strcopy( buffer, maxLength, "G3SG1" );
        case WEAPON_SCAR20:        strcopy( buffer, maxLength, "SCAR-20" );
    }

    /*
    char weaponClass[WEAPON_STRING_LENGTH];
    GetWeaponClassName( weapon, weaponClass, sizeof(weaponClass) );

    return CS_GetTranslatedWeaponAlias( weaponClass, buffer, maxLength );
    */
}

/**
 * Gets the class name of the given weapon.
 *
 * @param loadout   Weapon to get the class of.
 * @param buffer    Character array to write the class to.
 * @param maxLength Size of the destination character array.
 */
void GetWeaponClassName( CSWeapon weapon, char[] buffer, int maxLength )
{
    switch ( weapon )
    {
        case WEAPON_NONE:      strcopy( buffer, maxLength, "" );

        case WEAPON_GLOCK:     strcopy( buffer, maxLength, "weapon_glock" );
        case WEAPON_HKP2000:   strcopy( buffer, maxLength, "weapon_hkp2000" );
        case WEAPON_P250:      strcopy( buffer, maxLength, "weapon_p250" );
        case WEAPON_ELITE:     strcopy( buffer, maxLength, "weapon_elite" );
        case WEAPON_TEC9:      strcopy( buffer, maxLength, "weapon_tec9" );
        case WEAPON_FIVESEVEN: strcopy( buffer, maxLength, "weapon_fiveseven" );
        case WEAPON_CZ75A:     strcopy( buffer, maxLength, "weapon_cz75a" );
        case WEAPON_DEAGLE:    strcopy( buffer, maxLength, "weapon_deagle" );

        case WEAPON_MAC10:     strcopy( buffer, maxLength, "weapon_mac10" );
        case WEAPON_MP9:       strcopy( buffer, maxLength, "weapon_mp9" );
        case WEAPON_UMP45:     strcopy( buffer, maxLength, "weapon_ump45" );
        case WEAPON_BIZON:     strcopy( buffer, maxLength, "weapon_bizon" );
        case WEAPON_MP7:       strcopy( buffer, maxLength, "weapon_mp7" );
        case WEAPON_P90:       strcopy( buffer, maxLength, "weapon_p90" );

        case WEAPON_NOVA:      strcopy( buffer, maxLength, "weapon_nova" );
        case WEAPON_SAWEDOFF:  strcopy( buffer, maxLength, "weapon_sawedoff" );
        case WEAPON_MAG7:      strcopy( buffer, maxLength, "weapon_mag7" );
        case WEAPON_XM1014:    strcopy( buffer, maxLength, "weapon_xm1014" );
        case WEAPON_M249:      strcopy( buffer, maxLength, "weapon_m249" );
        case WEAPON_NEGEV:     strcopy( buffer, maxLength, "weapon_negev" );

        case WEAPON_GALILAR:       strcopy( buffer, maxLength, "weapon_galilar" );
        case WEAPON_FAMAS:         strcopy( buffer, maxLength, "weapon_famas" );
        case WEAPON_SSG08:         strcopy( buffer, maxLength, "weapon_ssg08" );
        case WEAPON_AK47:          strcopy( buffer, maxLength, "weapon_ak47" );
        case WEAPON_M4A1:          strcopy( buffer, maxLength, "weapon_m4a1" );
        case WEAPON_M4A1_SILENCER: strcopy( buffer, maxLength, "weapon_m4a1_silencer" );
        case WEAPON_SG556:         strcopy( buffer, maxLength, "weapon_sg556" );
        case WEAPON_AUG:           strcopy( buffer, maxLength, "weapon_aug" );
        case WEAPON_AWP:           strcopy( buffer, maxLength, "weapon_awp" );
        case WEAPON_G3SG1:         strcopy( buffer, maxLength, "weapon_g3sg1" );
        case WEAPON_SCAR20:        strcopy( buffer, maxLength, "weapon_scar20" );
    }
}

/**
 * AWP round enabled state for each client on either team.
 */
bool g_Sniper[MAXPLAYERS+1][TEAM_COUNT];

/**
 * Kevlar enabled state for each client on either team for all loadout types.
 */
bool g_Kevlar[MAXPLAYERS+1][TEAM_COUNT][LoadoutType];

/**
 * Helmet enabled state for each client on either team for all loadout types.
 */
bool g_Helmet[MAXPLAYERS+1][TEAM_COUNT][LoadoutType];

/**
 * Defuse kit enabled state for each client for all loadout types.
 */
bool g_Defuse[MAXPLAYERS+1][LoadoutType];

/**
 * Primary weapon selection for each client on either team for all loadout types.
 */
CSWeapon g_Primary[MAXPLAYERS+1][TEAM_COUNT][LoadoutType];

/**
 * Secondary weapon selection for each client on either team for all loadout types.
 */
CSWeapon g_Secondary[MAXPLAYERS+1][TEAM_COUNT][LoadoutType];

/**
 * Maps team types to the range [0,1].
 *
 * @param team      CS_TEAM_T or CS_TEAM_CT.
 * @return          0 for CS_TEAM_T, 1 for CS_TEAM_CT.
 */
int GetTeamIndex( int team )
{
    return team - CS_TEAM_T;
}

/**
 * Sets AWP round enabled state for a client when on the given team.
 *
 * @param client    Client to set AWP round enabled state for.
 * @param team      Team for which to set AWP round enabled state for.
 * @param enabled   If true, the client is set to possibly receive an AWP
 *                  on full buy rounds when on the given team.
 */
void SetSniper( int client, int team, bool enabled )
{
    g_Sniper[client][GetTeamIndex( team )] = enabled;
}

/**
 * Gets AWP round enabled state for a client when on the given team.
 *
 * @param client    Client to get AWP round enabled state for.
 * @param team      Team for which to get AWP round enabled state for.
 * @return          True if the client is set to possibly receive an AWP
 *                  on full buy rounds when on the given team.
 */
bool GetSniper( int client, int team )
{
    return g_Sniper[client][GetTeamIndex( team )];
}

/**
 * Sets kevlar enabled state for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to set kevlar enabled state for.
 * @param team      Team for which to set kevlar enabled state for.
 * @param loadout   Loadout type for which to set kevlar enabled state for.
 * @param enabled   If true, the client is set to receive kevlar during
 *                  loadouts of the given type when on the given team.
 */
void SetKevlar( int client, int team, LoadoutType loadout, bool enabled )
{
    g_Kevlar[client][GetTeamIndex( team )][loadout] = enabled;
    if ( !enabled ) SetHelmet( client, team, loadout, false );
}

/**
 * Gets kevlar enabled state for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to get kevlar enabled state for.
 * @param team      Team for which to get kevlar enabled state for.
 * @param loadout   Loadout type for which to get kevlar enabled state for.
 * @return          True if the client is set to receive kevlar during
 *                  loadouts of the given type when on the given team.
 */
bool GetKevlar( int client, int team, LoadoutType loadout )
{
    return g_Kevlar[client][GetTeamIndex( team )][loadout];
}

/**
 * Sets helmet enabled state for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to set helmet enabled state for.
 * @param team      Team for which to set helmet enabled state for.
 * @param loadout   Loadout type for which to set helmet enabled state for.
 * @param enabled   If true, the client is set to receive a helmet during
 *                  loadouts of the given type when on the given team.
 */
void SetHelmet( int client, int team, LoadoutType loadout, bool enabled )
{
    g_Helmet[client][GetTeamIndex( team )][loadout] = enabled;
    if ( enabled ) SetKevlar( client, team, loadout, true );
}

/**
 * Gets helmet enabled state for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to get helmet enabled state for.
 * @param team      Team for which to get helmet enabled state for.
 * @param loadout   Loadout type for which to get helmet enabled state for.
 * @return          True if the client is set to receive a helmet during
 *                  loadouts of the given type when on the given team.
 */
bool GetHelmet( int client, int team, LoadoutType loadout )
{
    return GetKevlar( client, team, loadout ) && g_Helmet[client][GetTeamIndex( team )][loadout];
}

/**
 * Sets defuse kit enabled state for a client during loadouts of the given type.
 *
 * @param client    Client to set defuse kit enabled state for.
 * @param team      Must be CS_TEAM_CT, or nothing will be set.
 * @param loadout   Loadout type for which to set defuse kit enabled state for.
 * @param enabled   If true, the client is set to receive a defuse kit during
 *                  loadouts of the given type.
 */
void SetDefuse( int client, int team, LoadoutType loadout, bool enabled )
{
    if ( team != CS_TEAM_CT ) return;
    g_Defuse[client][loadout] = enabled;
}

/**
 * Gets defuse kit enabled state for a client during loadouts of the given type.
 *
 * @param client    Client to get defuse kit enabled state for.
 * @param team      Must be CS_TEAM_CT, or will return false.
 * @param loadout   Loadout type for which to get defuse kit enabled state for.
 * @return          True if the client is set to receive a defuse kit during
 *                  loadouts of the given type.
 */
bool GetDefuse( int client, int team, LoadoutType loadout )
{
    if ( team != CS_TEAM_CT ) return false;
    return g_Defuse[client][loadout];
}

/**
 * Sets primary weapon selection for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to set primary weapon selection for.
 * @param team      Team for which to set primary weapon selection for.
 * @param loadout   Loadout type for which to set primary weapon selection for.
 * @param weapon    Primary weapon to equip during loadouts of the given type
 *                  when the client is on the given team.
 */
void SetPrimary( int client, int team, LoadoutType loadout, CSWeapon weapon )
{
    g_Primary[client][GetTeamIndex( team )][loadout] = weapon;
}

/**
 * Gets primary weapon selection for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to get primary weapon selection for.
 * @param team      Team for which to get primary weapon selection for.
 * @param loadout   Loadout type for which to get primary weapon selection for.
 * @return          Primary weapon to equip during loadouts of the given type
 *                  when the client is on the given team.
 */
CSWeapon GetPrimary( int client, int team, LoadoutType loadout )
{
    return g_Primary[client][GetTeamIndex( team )][loadout];
}

/**
 * Sets secondary weapon selection for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to set secondary weapon selection for.
 * @param team      Team for which to set secondary weapon selection for.
 * @param loadout   Loadout type for which to set secondary weapon selection for.
 * @param weapon    Secondary weapon to equip during loadouts of the given type
 *                  when the client is on the given team.
 */
void SetSecondary( int client, int team, LoadoutType loadout, CSWeapon weapon )
{
    g_Secondary[client][GetTeamIndex( team )][loadout] = weapon;
}

/**
 * Gets secondary weapon selection for a client when on the given team for
 * loadouts of the given type.
 *
 * @param client    Client to get secondary weapon selection for.
 * @param team      Team for which to get secondary weapon selection for.
 * @param loadout   Loadout type for which to get secondary weapon selection for.
 * @return          Secondary weapon to equip during loadouts of the given type
 *                  when the client is on the given team.
 */
CSWeapon GetSecondary( int client, int team, LoadoutType loadout )
{
    return g_Secondary[client][GetTeamIndex( team )][loadout];
}

/**
 * Resets a client's preferences for all loadouts to their defaults.
 *
 * @param client    Client to reset loadout preferences for.
 */
void ResetAllLoadouts( int client )
{
    for ( var i = 0; i < view_as<int>(LoadoutType); ++i )
    {
        LoadoutType loadout = view_as<LoadoutType>(i);
        ResetLoadout( client, i );
    }
}

/**
 * Resets a client's preferences for a given loadout to their defaults.
 *
 * @param client    Client to reset loadout preferences for.
 * @param loadout   Loadout type to reset preferences for.
 */
void ResetLoadout( int client, LoadoutType loadout )
{
    SetHelmet( client, CS_TEAM_T,  loadout, false );
    SetHelmet( client, CS_TEAM_CT, loadout, false );

    SetKevlar( client, CS_TEAM_T,  loadout, false );
    SetKevlar( client, CS_TEAM_CT, loadout, false );

    SetDefuse( client, CS_TEAM_CT, loadout, false );

    SetPrimary( client, CS_TEAM_T,  loadout, WEAPON_NONE );
    SetPrimary( client, CS_TEAM_CT, loadout, WEAPON_NONE );

    SetSecondary( client, CS_TEAM_T,  loadout, WEAPON_GLOCK );
    SetSecondary( client, CS_TEAM_CT, loadout, WEAPON_HKP2000 );

    switch ( loadout )
    {
        case LOADOUT_PISTOL:
        {
            SetKevlar( client, CS_TEAM_T,  loadout, true );
            SetKevlar( client, CS_TEAM_CT, loadout, true );
        }
        case LOADOUT_FORCE:
        {
            SetHelmet( client, CS_TEAM_T,  loadout, true );
            SetHelmet( client, CS_TEAM_CT, loadout, true );

            SetKevlar( client, CS_TEAM_T,  loadout, true );
            SetKevlar( client, CS_TEAM_CT, loadout, true );
            
            SetPrimary( client, CS_TEAM_T,  loadout, WEAPON_UMP45 );
            SetPrimary( client, CS_TEAM_CT, loadout, WEAPON_UMP45 );
        }
        case LOADOUT_FULL:
        {
            SetHelmet( client, CS_TEAM_T,  loadout, true );
            SetHelmet( client, CS_TEAM_CT, loadout, true );

            SetKevlar( client, CS_TEAM_T,  loadout, true );
            SetKevlar( client, CS_TEAM_CT, loadout, true );

            SetDefuse( client, CS_TEAM_CT, loadout, true );

            SetPrimary( client, CS_TEAM_T,  loadout, WEAPON_AK47 );
            SetPrimary( client, CS_TEAM_CT, loadout, WEAPON_M4A1 );
        }
        case LOADOUT_SNIPER:
        {
            SetSniper( client, CS_TEAM_T,  false );
            SetSniper( client, CS_TEAM_CT, false );

            SetHelmet( client, CS_TEAM_T,  loadout, true );
            SetHelmet( client, CS_TEAM_CT, loadout, true );

            SetKevlar( client, CS_TEAM_T,  loadout, true );
            SetKevlar( client, CS_TEAM_CT, loadout, true );

            SetDefuse( client, CS_TEAM_CT, loadout, true );

            SetPrimary( client, CS_TEAM_T,  loadout, WEAPON_AWP );
            SetPrimary( client, CS_TEAM_CT, loadout, WEAPON_AWP );
            
            SetSecondary( client, CS_TEAM_T,  loadout, WEAPON_TEC9 );
            SetSecondary( client, CS_TEAM_CT, loadout, WEAPON_FIVESEVEN );
        }
    }
}

/**
 * Gets the amount of money that a client can allocate between
 * different gear and weapons on a given loadout type.
 *
 * @param loadout   Loadout type to get start money for.
 * @return          Money available for loadouts of the given type.
 */
int GetStartMoney( LoadoutType loadout )
{
    switch ( loadout )
    {
        case LOADOUT_PISTOL:
            return 800;
        case LOADOUT_FORCE:
            return 2400;
        case LOADOUT_FULL:
            return 16000;
        case LOADOUT_SNIPER:
            return 16000;
    }

    return 0;
}

/**
 * Gets whether money available and items costs should be shown
 * in loadout menus for the given loadout.
 *
 * @param loadout   Loadout type to get money visibility for.
 * @return          True if money available and item costs should
                    be shown in loadout menus for the given loadout.
 */
bool ShouldShowMoney( LoadoutType loadout )
{
    return loadout != LOADOUT_FULL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given weapon category should be visible to the given client
 * in loadout menus for the given team and loadout type. A weapon category is visible
 * if there is at least one weapon in that category priced at leass than the start money
 * of the given loadout type.
 *
 * @param client    Client to check weapon category visibility for.
 * @param team      Team to check weapon category visibility for.
 * @param loadout   Loadout to check weapon category visibility for.
 * @param category  Weapon category to check visibility for.
 * @return          True if the given weapon category should be visible.
 */
bool ShouldShowWeaponCategory( int client, int team, LoadoutType loadout, CSWeaponCategory category )
{
    return CanSelectWeaponCategory( client, team, loadout, GetStartMoney( loadout ), category );
}

/**
 * Gets whether the given weapon category can be selected by the given client in loadout
 * menus for the given team and loadout type. A weapon category is selectable if there is
 * at least one weapon in that category that is currently affordable.
 *
 * @param client    Client to check weapon category selectability for.
 * @param team      Team to check weapon category selectability for.
 * @param loadout   Loadout to check weapon category selectability for.
 * @param money     Maximum price that a weapon can be purchased for.
 * @param category  Weapon category to check selectability for.
 * @return          True if the given weapon category should be selectable.
 */
bool CanSelectWeaponCategory( int client, int team, LoadoutType loadout, int money, CSWeaponCategory category )
{
    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);

        if ( !CanBuyWeapon( client, team, loadout, weapon ) ) continue;
        if ( GetWeaponCost( client, weapon ) > money ) continue;

        return true;
    }

    return false;
}

/**
 * Gets the first weapon index of weapons in the given category.
 *
 * @param category  Weapon category to get the first index of.
 * @return          Weapon index of the first weapon in the given category.
 */
int GetWeaponListMin( CSWeaponCategory category )
{
    switch ( category )
    {
        case WCAT_PISTOL: return view_as<int>( WEAPON_GLOCK );
        case WCAT_SMG: return view_as<int>( WEAPON_MAC10 );
        case WCAT_HEAVY: return view_as<int>( WEAPON_NOVA );
        case WCAT_RIFLE: return view_as<int>( WEAPON_GALILAR );
    }

    return -1;
}

/**
 * Gets the last weapon index of weapons in the given category.
 *
 * @param category  Weapon category to get the last index of.
 * @return          Weapon index of the last weapon in the given category.
 */
int GetWeaponListMax( CSWeaponCategory category )
{
    switch ( category )
    {
        case WCAT_PISTOL: return view_as<int>( WEAPON_DEAGLE );
        case WCAT_SMG: return view_as<int>( WEAPON_P90 );
        case WCAT_HEAVY: return view_as<int>( WEAPON_NEGEV );
        case WCAT_RIFLE: return view_as<int>( WEAPON_AUG );
    }

    return -1;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, can purchase the given weapon.
 *
 * @param client    Client to check for weapon availability.
 * @param team      Team to check for weapon availability.
 * @param loadout   Loadout to check for weapon availability.
 * @param weapon    Weapon to check for availability.
 * @return          True if the given weapon can be purchased.
 */
bool CanBuyWeapon( int client, int team, LoadoutType loadout, CSWeapon weapon )
{
    if ( GetWeaponCost( client, weapon ) > GetStartMoney( loadout ) ) return false;

    switch ( weapon )
    {
        case WEAPON_GLOCK, WEAPON_TEC9, WEAPON_MAC10, WEAPON_SAWEDOFF,
            WEAPON_GALILAR, WEAPON_AK47, WEAPON_SG556, WEAPON_G3SG1:
            return team == CS_TEAM_T;
        case WEAPON_HKP2000, WEAPON_FIVESEVEN, WEAPON_MP9, WEAPON_MAG7,
            WEAPON_FAMAS, WEAPON_M4A1, WEAPON_M4A1_SILENCER, WEAPON_AUG, WEAPON_SCAR20:
            return team == CS_TEAM_CT;
    }

    return true;
}

/**
 * Gets the price of the given weapon when purchased by the given client.
 *
 * @param client    Client to check weapon price for.
 * @param weapon    Weapon to check price for.
 * @return          Weapon price for the given weapon.
 */
int GetWeaponCost( int client, CSWeapon weapon )
{
    switch ( weapon )
    {
        case WEAPON_NONE, WEAPON_GLOCK, WEAPON_HKP2000:
            return 0;
        case WEAPON_P250:
            return 300;
        case WEAPON_ELITE, WEAPON_TEC9, WEAPON_FIVESEVEN, WEAPON_CZ75A:
            return 500;
        case WEAPON_DEAGLE:
            return 700;

        case WEAPON_MAC10:
            return 1050;
        case WEAPON_MP9:
            return 1250;
        case WEAPON_UMP45:
            return 1200;
        case WEAPON_BIZON:
            return 1400;
        case WEAPON_MP7:
            return 1700;
        case WEAPON_P90:
            return 2350;

        case WEAPON_NOVA, WEAPON_SAWEDOFF:
            return 1200;
        case WEAPON_MAG7:
            return 1800;
        case WEAPON_XM1014:
            return 2000;
        case WEAPON_M249:
            return 5200;
        case WEAPON_NEGEV:
            return 5700;

        case WEAPON_GALILAR:
            return 2000;
        case WEAPON_FAMAS:
            return 2250;
        case WEAPON_SSG08:
            return 1700;
        case WEAPON_AK47:
            return 2700;
        case WEAPON_M4A1, WEAPON_M4A1_SILENCER:
            return 3100;
        case WEAPON_SG556:
            return 3000;
        case WEAPON_AUG:
            return 3300;
        case WEAPON_AWP:
            return 4750;
        case WEAPON_G3SG1, WEAPON_SCAR20:
            return 5000;
    }

    /*
    char weaponClass[WEAPON_STRING_LENGTH];
    GetWeaponClassName( weapon, weaponClass, sizeof(weaponClass) );

    CSWeaponID weaponId = CS_AliasToWeaponID( weaponClass );
    if ( !CS_IsValidWeaponID( weaponId ) ) return 0;

    return CS_GetWeaponPrice( client, weaponId, true );
    */

    return 0;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to toggle kevlar.
 *
 * @param client    Client to check for kevlar togglability.
 * @param team      Team to check for kevlar togglability.
 * @param loadout   Loadout to check for kevlar togglability.
 * @return          True if kevlar can be toggled.
 */
bool ShowKevlarOption( int client, int team, LoadoutType loadout )
{
    return loadout != LOADOUT_FULL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to toggle helmets.
 *
 * @param client    Client to check for helmet togglability.
 * @param team      Team to check for helmet togglability.
 * @param loadout   Loadout to check for helmet togglability.
 * @return          True if helmets can be toggled.
 */
bool ShowHelmetOption( int client, int team, LoadoutType loadout )
{
    return loadout != LOADOUT_PISTOL && loadout != LOADOUT_FULL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to toggle defuse kits.
 *
 * @param client    Client to check for defuse kit togglability.
 * @param team      Team to check for defuse kit togglability.
 * @param loadout   Loadout to check for defuse kit togglability.
 * @return          True if defuse kits can be toggled.
 */
bool ShowDefuseOption( int client, int team, LoadoutType loadout )
{
    return team == CS_TEAM_CT && loadout != LOADOUT_FULL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to select a primary weapon.
 *
 * @param client    Client to check for primary weapon selectability.
 * @param team      Team to check for primary weapon selectability.
 * @param loadout   Loadout to check for primary weapon selectability.
 * @return          True if primary weapons can be selected.
 */
bool ShowPrimaryOption( int client, int team, LoadoutType loadout )
{
    return loadout != LOADOUT_PISTOL && loadout != LOADOUT_SNIPER;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, should be given the option to select a secondary weapon.
 *
 * @param client    Client to check for secondary weapon selectability.
 * @param team      Team to check for secondary weapon selectability.
 * @param loadout   Loadout to check for secondary weapon selectability.
 * @return          True if secondary weapons can be selected.
 */
bool ShowSecondaryOption( int client, int team, LoadoutType loadout )
{
    return loadout != LOADOUT_SNIPER || GetSniper( client, team );
}

/**
 * Gets the maximum number of grenades that a player can hold when on the
 * given team during loadouts of the given type.
 *
 * @param team      Team to get maximum grenade count for.
 * @param loadout   Loadout type to get maximum grenade count for.
 * @return          Maximum number of grenades that can be held.
 */
int GetMaxTotalGrenades( int team, LoadoutType loadout )
{
    return 4;
}

/**
 * Gets the maximum number of grenades of the given type that a player
 * can hold when on the given team during loadouts of the given type.
 *
 * @note            Valid grenade chars are {h, f, m, i, s, d}.
 * @param team      Team to get maximum grenade count for.
 * @param loadout   Loadout type to get maximum grenade count for.
 * @param nadeChar  Grenade type to get maximum grenade count for.
 * @return          Maximum number of grenades that can be held.
 */
int GetMaxGrenades( int team, LoadoutType loadout, char nadeChar )
{
    switch ( nadeChar )
    {
        case 'h': return 1;
        case 'f': return 2;
        case 'm': return 1;
        case 'i': return 1;
        case 's': return 1;
        case 'd': return 1;
    }

    return 0;
}

/**
 * Gets the cost of the given grenade type when purchased by a client
 * on the given team.
 *
 * @note            Valid grenade chars are {h, f, m, i, s, d}.
 * @param team      Team to get grenade price for.
 * @param nadeChar  Grenade type to get price for.
 * @return          Grenade price of the given grenade.
 */
int GetGrenadeCost( int team, char nadeChar )
{
    switch ( nadeChar )
    {
        case 'h': return 300;
        case 'f': return 200;
        case 'm', 'i': return team == CS_TEAM_CT ? 600 : 400;
        case 's': return 300;
        case 'd': return 50;
    }
    
    return 0;
}

/**
 * Percentage probability of a decoy being available when randomly
 * selecting a grenade.
 *
 * @param loadout   Loadout type to get decoy probability for.
 * @return          Probability of a decoy being available for randomly
 *                  selection, in percent. 
 */
int GetDecoyProbability( LoadoutType loadout )
{
    return 10;
}

/**
 * Gets the total cost of the loadout preference for the given client
 * when on the given team during loadouts of the given type.
 *
 * @param client    Client to get loadout cost for.
 * @param team      Team to get loadout cost for.
 * @param loadout   Loadout type to get cost for.
 * @return          Loadout cost for the given client.
 */
int GetLoadoutCost( int client, int team, LoadoutType loadout )
{
    int total = 0;

    if ( GetKevlar( client, team, loadout ) ) total += LOADOUT_KEVLAR_COST;
    if ( GetHelmet( client, team, loadout ) ) total += LOADOUT_HELMET_COST;
    if ( GetDefuse( client, team, loadout ) ) total += LOADOUT_DEFUSE_COST;

    total += GetWeaponCost( client, GetSecondary( client, team, loadout ) );
    total += GetWeaponCost( client, GetPrimary( client, team, loadout ) );

    return total;
}

/**
 * Writes the given boolean array containing values for each team / loadout
 * to a character array.
 *
 * @note            Encodes 'true' as '1', and 'false' as '0'.
 * @param array     Input boolean array.
 * @param dest      Output character array.
 * @param maxLength Size of the output character array.
 */
void EncodeTeamLoadoutBools( bool array[TEAM_COUNT][LoadoutType], char[] dest, int maxLength )
{
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(LoadoutType); ++loadout )
    {
        for ( int team = 0; team < TEAM_COUNT; ++team )
        {
            if ( index >= maxLength - 1 ) break;
            dest[index++] = array[team][loadout] ? '1' : '0';
        }
    }

    dest[index] = 0;
}

/**
 * Reads the given boolean array containing values for each team / loadout
 * from a character array.
 *
 * @note            Decodes '1' as 'true', and '0' as 'false'.
 * @param array     Output boolean array.
 * @param src       Input character array.
 */
void DecodeTeamLoadoutBools( bool array[TEAM_COUNT][LoadoutType], char[] src )
{
    int length = strlen(src);
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(LoadoutType); ++loadout )
    {
        for ( int team = 0; team < TEAM_COUNT; ++team )
        {
            if ( index >= length ) return;
            array[team][loadout] = src[index++] == '1';
        }
    }
}

void EncodeLoadoutBools( bool array[LoadoutType], char[] dest, int maxLength )
{
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(LoadoutType); ++loadout )
    {
        if ( index >= maxLength - 1 ) break;
        dest[index++] = array[loadout] ? '1' : '0';
    }

    dest[index] = 0;
}

void DecodeLoadoutBools( bool array[LoadoutType], char[] src )
{
    int length = strlen(src);
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(LoadoutType); ++loadout )
    {
        if ( index >= length ) return;
        array[loadout] = src[index++] == '1';
    }
}

void EncodeTeamBools( bool array[TEAM_COUNT], char[] dest, int maxLength )
{
    int index = 0;
    for ( int team = 0; team < TEAM_COUNT; ++team )
    {
        if ( index >= maxLength - 1 ) break;
        dest[index++] = array[team] ? '1' : '0';
    }

    dest[index] = 0;
}

void DecodeTeamBools( bool array[TEAM_COUNT], char[] src )
{
    int length = strlen(src);
    int index = 0;
    for ( int team = 0; team < TEAM_COUNT; ++team )
    {
        if ( index >= length ) return;
        array[team] = src[index++] == '1';
    }
}

void EncodeWeapons( CSWeapon array[TEAM_COUNT][LoadoutType], char[] dest, int maxLength )
{
    char buffer[8];

    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(LoadoutType); ++loadout )
    {
        for ( int team = 0; team < TEAM_COUNT; ++team )
        {
            CSWeapon weapon = array[team][loadout];
            IntToString( view_as<int>(weapon), buffer, sizeof(buffer) );

            int numLen = strlen(buffer);
            if ( index + numLen + 2 >= maxLength ) break;

            for ( int c = 0; c < numLen; ++c )
            {
                dest[index++] = buffer[c];
            }

            dest[index++] = ';';
        }
    }
    
    dest[index] = 0;
}

void DecodeWeapons( CSWeapon array[TEAM_COUNT][LoadoutType], char[] src )
{
    char buffer[8];

    int length = strlen(src);
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(LoadoutType); ++loadout )
    {
        for ( int team = 0; team < TEAM_COUNT; ++team )
        {
            if ( index >= length ) return;

            int numLen = 0;
            while ( index < length && src[index++] != ';' )
            {
                buffer[numLen++] = src[index - 1];
            }
            buffer[numLen] = 0;

            array[team][loadout] = view_as<CSWeapon>(StringToInt( buffer, 10 ));
        }
    }
}

Handle g_hKevlarCookie = INVALID_HANDLE;
Handle g_hHelmetCookie = INVALID_HANDLE;
Handle g_hDefuseCookie = INVALID_HANDLE;
Handle g_hSniperCookie = INVALID_HANDLE;

Handle g_hPrimaryCookie = INVALID_HANDLE;
Handle g_hSecondaryCookie = INVALID_HANDLE;

void SetupClientCookies()
{
    g_hKevlarCookie = RegClientCookie( "retakes_ziks_kevlar", "Kevlar preferences", CookieAccess_Protected );
    g_hHelmetCookie = RegClientCookie( "retakes_ziks_helmet", "Helmet preferences", CookieAccess_Protected );
    g_hDefuseCookie = RegClientCookie( "retakes_ziks_defuse", "Defuse preferences", CookieAccess_Protected );
    g_hSniperCookie = RegClientCookie( "retakes_ziks_sniper", "Sniper preferences", CookieAccess_Protected );

    g_hPrimaryCookie = RegClientCookie( "retakes_ziks_primary", "Primary preferences", CookieAccess_Protected );
    g_hSecondaryCookie = RegClientCookie( "retakes_ziks_secondary", "Secondary preferences", CookieAccess_Protected );
}

void SaveLoadouts( int client )
{
    char buffer[64];

    EncodeTeamLoadoutBools( g_Kevlar[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hKevlarCookie, buffer );

    EncodeTeamLoadoutBools( g_Helmet[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hHelmetCookie, buffer );

    EncodeLoadoutBools( g_Defuse[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hDefuseCookie, buffer );

    EncodeTeamBools( g_Sniper[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hSniperCookie, buffer );

    EncodeWeapons( g_Primary[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hPrimaryCookie, buffer );

    EncodeWeapons( g_Secondary[client], buffer, sizeof(buffer) );
    SetClientCookie( client, g_hSecondaryCookie, buffer );
}

void RestoreLoadouts( int client )
{
    ResetAllLoadouts( client );

    char buffer[64];

    GetClientCookie( client, g_hKevlarCookie, buffer, sizeof(buffer) );
    DecodeTeamLoadoutBools( g_Kevlar[client], buffer );

    GetClientCookie( client, g_hHelmetCookie, buffer, sizeof(buffer) );
    DecodeTeamLoadoutBools( g_Helmet[client], buffer );

    GetClientCookie( client, g_hDefuseCookie, buffer, sizeof(buffer) );
    DecodeLoadoutBools( g_Defuse[client], buffer );

    GetClientCookie( client, g_hSniperCookie, buffer, sizeof(buffer) );
    DecodeTeamBools( g_Sniper[client], buffer );

    GetClientCookie( client, g_hPrimaryCookie, buffer, sizeof(buffer) );
    DecodeWeapons( g_Primary[client], buffer );

    GetClientCookie( client, g_hSecondaryCookie, buffer, sizeof(buffer) );
    DecodeWeapons( g_Secondary[client], buffer );
}

//
// Callbacks
//

public void OnPluginStart()
{
    SetupClientCookies();
}

public void OnClientConnected( int client )
{
    if ( AreClientCookiesCached( client ) )
    {
        RestoreLoadouts( client );
    }
    else
    {
        ResetAllLoadouts( client );
    }
}

public void Retakes_OnGunsCommand( int client )
{
    GiveWeaponsMenu( client );
}

public void Retakes_OnWeaponsAllocated( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
    WeaponAllocator( tPlayers, ctPlayers, bombsite );
}

public void OnClientCookiesCached( int client )
{
    if ( IsFakeClient( client ) ) return;

    RestoreLoadouts( client );
}

//
// Weapon allocator
//

LoadoutType GetLoadout()
{
    int rand = GetRandomInt( 0, 99 );

    if ( rand < 30 )
    {
        return LOADOUT_PISTOL;
    }

    if ( rand < 50 )
    {
        return LOADOUT_FORCE;
    }

    return LOADOUT_FULL;
}

int ChooseSniperPlayer( ArrayList players, int team )
{
    int sniper = -1;
    int bestScore = -1;
    int count = GetArraySize( players );

    for ( int i = 0; i < count; i++ )
    {
        int client = GetArrayCell( players, i );
        if ( !GetSniper( client, team ) ) continue;

        int score = GetRandomInt( 0, 65535 );

        if ( score > bestScore )
        {
            sniper = client;
            bestScore = score;
        }
    }

    return sniper;
}

void WeaponAllocator( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
    int tCount = GetArraySize( tPlayers );
    int ctCount = GetArraySize( ctPlayers );

    LoadoutType loadout = GetLoadout();

    int tSniper = -1; 
    int ctSniper = -1;

    if ( loadout == LOADOUT_FULL )
    {
        tSniper = ChooseSniperPlayer( tPlayers, CS_TEAM_T );
        ctSniper = ChooseSniperPlayer( ctPlayers, CS_TEAM_CT );
    }

    for ( int i = 0; i < tCount; i++ )
    {
        int client = GetArrayCell( tPlayers, i );
        HandleLoadout( client, CS_TEAM_T, client == tSniper ? LOADOUT_SNIPER : loadout );
    }

    for ( int i = 0; i < ctCount; i++ )
    {
        int client = GetArrayCell(ctPlayers, i);
        HandleLoadout( client, CS_TEAM_CT, client == ctSniper ? LOADOUT_SNIPER : loadout );
    }
}

void HandleLoadout( int client, int team, LoadoutType loadout )
{
    char primary[WEAPON_STRING_LENGTH];
    char secondary[WEAPON_STRING_LENGTH];
    char nades[NADE_STRING_LENGTH];
    int health = 100;
    int kevlar = 100;
    bool helmet = true;
    bool kit = true;

    primary = "";
    secondary = "";
    nades = "";

    GetWeaponClassName( GetPrimary( client, team, loadout ), primary, sizeof(primary) );
    GetWeaponClassName( GetSecondary( client, team, loadout ), secondary, sizeof(secondary) );

    int remaining = GetStartMoney( loadout ) - GetLoadoutCost( client, team, loadout );
    
    if ( remaining > MAX_NADE_VALUE ) remaining = MAX_NADE_VALUE;

    FillGrenades( team, loadout, remaining, nades );

    health = 100;
    kevlar = GetKevlar( client, team, loadout ) ? 100 : 0;
    helmet = GetHelmet( client, team, loadout );
    kit = GetDefuse( client, team, loadout );

    Retakes_SetPlayerInfo( client, primary, secondary, nades, health, kevlar, helmet, kit );
}

int AppendGrenadeIfAvailable( char[] nades, int index, char nade, int team, LoadoutType loadout, int money, int count )
{
    if ( count >= GetMaxGrenades( team, loadout, nade ) ) return index;
    if ( money < GetGrenadeCost( team, loadout, nade ) ) return index;

    if ( nade == 'm' && team == CS_TEAM_CT ) nade = 'i';
    if ( nade == 'i' && team == CS_TEAM_T ) nade = 'm';

    nades[index] = nade;
    return index + 1;
}

int GetAvailableGrenades( int team, LoadoutType loadout, int money, char[] currentNades, char[] available )
{
    available[0] = 0;
    int count = 0;

    int smokes = 0;
    int flashes = 0;
    int molotovs = 0;
    int explosives = 0;
    int decoys = 0;

    for ( int i = 0; i < strlen( currentNades ); ++i )
    {
        switch ( currentNades[i] )
        {
            case 's': ++smokes;
            case 'f': ++flashes;
            case 'm', 'i': ++molotovs;
            case 'h': ++explosives;
            case 'd': ++decoys;
        }
    }

    if ( strlen( currentNades ) >= GetMaxTotalGrenades( team, loadout ) ) return 0;
    count = AppendGrenadeIfAvailable( available, count, 's', team, loadout, money, smokes );
    count = AppendGrenadeIfAvailable( available, count, 'f', team, loadout, money, flashes );
    count = AppendGrenadeIfAvailable( available, count, 'm', team, loadout, money, molotovs );
    count = AppendGrenadeIfAvailable( available, count, 'h', team, loadout, money, explosives );

    if ( GetRandomInt( 0, 99 ) < GetDecoyProbability( loadout ) )
    {
        count = AppendGrenadeIfAvailable( available, count, 'd', team, loadout, money, decoys );
    }

    available[count] = 0;

    return count;
}

void FillGrenades( int team, LoadoutType loadout, int money, char[] nades )
{
    int index = strlen( nades );

    char available[NADE_STRING_LENGTH];
    while ( true )
    {
        int availableCount = GetAvailableGrenades( team, loadout, money, nades, available );
        if ( availableCount == 0 ) break;

        int rand = GetRandomInt( 0, availableCount - 1 );
        nades[index++] = available[rand];
        money -= GetGrenadeCost( team, available[rand] );
    }

    nades[index] = 0;
}

//
// Menu creation
//

int g_MenuStateTeam[MAXPLAYERS+1];
LoadoutType g_MenuStateLoadout[MAXPLAYERS+1];
CSWeaponCategory g_MenuStateCategory[MAXPLAYERS+1];

void GiveWeaponsMenu( int client )
{
    Handle menu = CreateMenu( MenuHandler_Loadout );
    SetMenuTitle( menu, "Configure loadouts:" );
    AddMenuInt( menu, view_as<int>( LOADOUT_PISTOL ), "Pistol loadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_FORCE ), "Force Buy loadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_FULL ), "Full Buy loadout" );
    AddMenuInt( menu, view_as<int>( LOADOUT_SNIPER ), "AWP loadout" );
    AddMenuInt( menu, -1, "Reset all" );
    DisplayMenu( menu, client, MENU_TIME_LENGTH );
}

void GiveTeamSelectMenu( int client, LoadoutType loadout )
{
    g_MenuStateLoadout[client] = loadout;

    char loadoutName[16];
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "Configure %s loadout:", loadoutName );

    Handle menu = CreateMenu( MenuHandler_TeamLoadout );
    SetMenuTitle( menu, buffer );
    AddMenuInt( menu, CS_TEAM_T, "Terrorist" );
    AddMenuInt( menu, CS_TEAM_CT, "Counter-Terrorist" );
    AddMenuInt( menu, -1, "Back" );
    DisplayMenu( menu, client, MENU_TIME_LENGTH );
}

void AddGearOption( Panel menu, char[] name, int available, int cost, bool equipped )
{
    char buffer[64];
    bool enabled = true;

    if ( equipped )
    {
        Format( buffer, sizeof(buffer), "Disable %s (+$%i)", name, cost );
    }
    else
    {
        Format( buffer, sizeof(buffer), "Enable %s (-$%i)", name, cost );
        enabled = available >= cost;
    }

    menu.DrawItem( buffer, enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
}

void AddMoneyAvailableItems( Panel menu, LoadoutType loadout, int moneyAvailable )
{
    if ( !ShouldShowMoney( loadout ) ) return;

    char buffer[64];
    Format( buffer, sizeof(buffer), "Money available: $%i", moneyAvailable );

    menu.DrawItem( buffer, ITEMDRAW_RAWLINE );
}

void AddBackItem( Panel menu )
{
    menu.DrawItem( " ", ITEMDRAW_RAWLINE  );
    menu.CurrentKey = 9;
    menu.DrawItem( "Back" );
}

void GiveLoadoutMenu( int client, int team, LoadoutType loadout )
{
    g_MenuStateTeam[client] = team;
    g_MenuStateLoadout[client] = loadout;

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char loadoutName[16];
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "%s %s loadout:", teamAbbrev, loadoutName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
    
    int currentCost = GetLoadoutCost( client, team, loadout );
    int moneyAvailable = GetStartMoney( loadout ) - currentCost;
    AddMoneyAvailableItems( menu, loadout, moneyAvailable );

    if ( loadout == LOADOUT_SNIPER )
    {
        menu.DrawItem( GetSniper( client, team ) ? "Disable AWP rounds" : "Enable AWP rounds" );
    }

    if ( ShowKevlarOption( client, team, loadout ) )
    {
        AddGearOption( menu, "Kevlar", moneyAvailable,
            LOADOUT_KEVLAR_COST, GetKevlar( client, team, loadout ) );
    }

    if ( ShowHelmetOption( client, team, loadout ) )
    {
        int cost = LOADOUT_HELMET_COST;
        if ( !GetKevlar( client, team, loadout ) )
        {
            cost += LOADOUT_KEVLAR_COST;
        }

        AddGearOption( menu, "Helmet", moneyAvailable,
            cost, GetHelmet( client, team, loadout ) );
    }

    if ( ShowDefuseOption( client, team, loadout ) )
    {
        AddGearOption( menu, "Defuse Kit", moneyAvailable,
            LOADOUT_DEFUSE_COST, GetDefuse( client, team, loadout ) );
    }

    if ( ShowPrimaryOption( client, team, loadout ) )
    {
        char weaponName[32];
        GetWeaponName( GetPrimary( client, team, loadout ), weaponName, sizeof(weaponName) );

        Format( buffer, sizeof(buffer), "Primary: %s", weaponName );

        menu.DrawItem( buffer );
    }

    if ( ShowSecondaryOption( client, team, loadout ) )
    {
        char pistolName[32];
        GetWeaponName( GetSecondary( client, team, loadout ), pistolName, sizeof(pistolName) );

        Format( buffer, sizeof(buffer), "Sidearm: %s", pistolName );

        menu.DrawItem( buffer );
    }

    AddBackItem( menu );
    menu.Send( client, MenuHandler_Loadout, MENU_TIME_LENGTH );

    delete menu;
}

void GiveWeaponCategoryListMenu( int client, int team, LoadoutType loadout )
{
    g_MenuStateTeam[client] = team;
    g_MenuStateLoadout[client] = loadout;

    int available = 0;
    CSWeaponCategory lastValid;

    for ( int i = 0; i < sizeof(g_PrimaryCategories); ++i )
    {
        CSWeaponCategory category = g_PrimaryCategories[i];
        if ( !ShouldShowWeaponCategory( client, team, loadout, category ) ) continue;

        ++available;
        lastValid = category;
    }

    if ( available == 0 ) return;

    if ( available == 1 )
    {
        GiveWeaponCategoryMenu( client, team, loadout, lastValid );
        return;
    }

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char loadoutName[16];
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "%s %s primary:", teamAbbrev, loadoutName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
    
    int currentCost = GetLoadoutCost( client, team, loadout );
    int moneyAvailable = GetStartMoney( loadout ) - currentCost;
    AddMoneyAvailableItems( menu, loadout, moneyAvailable );

    CSWeapon weapon = GetPrimary( client, team, loadout );
    int cost = GetWeaponCost( client, weapon );
    moneyAvailable += cost;

    if ( weapon != WEAPON_NONE && ShouldShowMoney( loadout ) )
    {
        Format( buffer, sizeof(buffer), "No weapon (+$%i)", cost );
        menu.DrawItem( buffer );
    }
    else
    {
        menu.DrawItem( "No weapon" );
    }

    for ( int i = 0; i < sizeof(g_PrimaryCategories); ++i )
    {
        CSWeaponCategory category = g_PrimaryCategories[i];
        if ( !ShouldShowWeaponCategory( client, team, loadout, category ) ) continue;

        bool enabled = CanSelectWeaponCategory( client, team, loadout, moneyAvailable, category );

        GetWeaponCategoryName( category, buffer, sizeof(buffer) );
        menu.DrawItem( buffer, enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
    }

    AddBackItem( menu );
    menu.Send( client, MenuHandler_WeaponCategoryList, MENU_TIME_LENGTH );

    delete menu;
}

void GiveWeaponCategoryMenu( int client, int team, LoadoutType loadout, CSWeaponCategory category )
{
    g_MenuStateTeam[client] = team;
    g_MenuStateLoadout[client] = loadout;
    g_MenuStateCategory[client] = category;

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char loadoutName[16];
    GetLoadoutName( loadout, loadoutName, sizeof(loadoutName) );

    char weaponCategoryName[16];

    if ( category == WCAT_PISTOL )
    {
        weaponCategoryName = "sidearm";
    }
    else
    {
        weaponCategoryName = "primary";
    }

    char buffer[128];
    Format( buffer, sizeof(buffer), "%s %s %s:", teamAbbrev, loadoutName, weaponCategoryName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
        
    int currentCost = GetLoadoutCost( client, team, loadout );
    int moneyAvailable = GetStartMoney( loadout ) - currentCost;
    AddMoneyAvailableItems( menu, loadout, moneyAvailable );

    char weaponName[32];

    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);

        if ( !CanBuyWeapon( client, team, loadout, weapon ) ) continue;

        GetWeaponName( weapon, weaponName, sizeof(weaponName) );

        CSWeapon current = category == WCAT_PISTOL
            ? GetSecondary( client, team, loadout )
            : GetPrimary( client, team, loadout ); 

        int cost = GetWeaponCost( client, weapon );
        int curCost = GetWeaponCost( client, current );
        int diff = cost - curCost;

        if ( diff == 0 || !ShouldShowMoney( loadout ) )
        {
            Format( buffer, sizeof(buffer), "%s", weaponName );
        }
        else if ( diff < 0 )
        {
            Format( buffer, sizeof(buffer), "%s (+$%i)", weaponName, -diff );
        }
        else
        {
            Format( buffer, sizeof(buffer), "%s (-$%i)", weaponName, diff );
        }

        if ( diff > moneyAvailable )
        {
            menu.DrawItem( buffer, ITEMDRAW_DISABLED );
        }
        else
        {
            menu.DrawItem( buffer );
        }
    }

    AddBackItem( menu );
    menu.Send( client, MenuHandler_WeaponCategory, MENU_TIME_LENGTH );

    delete menu;
}

//
// Menu handlers
//

public int MenuHandler_Loadout( Handle menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_End )
    {
        CloseHandle( menu );
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;

    if ( GetMenuInt( menu, param2 ) == -1 )
    {
        ResetAllLoadouts( client );
        SaveLoadouts( client );
        return;
    }

    LoadoutType choice = view_as<LoadoutType>( GetMenuInt( menu, param2 ) );

    GiveTeamSelectMenu( client, choice );
}

public int MenuHandler_TeamLoadout( Handle menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_End )
    {
        CloseHandle( menu );
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;
    int team = GetMenuInt( menu, param2 );
    LoadoutType loadout = g_MenuStateLoadout[client];

    if (team == -1)
    {
        GiveWeaponsMenu( client );
        return;
    }

    GiveLoadoutMenu( client, team, loadout );
}

public int MenuHandler_Loadout( Menu menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_End )
    {
        delete menu;
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;
    int team = g_MenuStateTeam[client];
    LoadoutType loadout = g_MenuStateLoadout[client];

    if ( param2 == 9 ) // Go back
    {
        GiveTeamSelectMenu( client, loadout );
        return;
    }

    if ( loadout == LOADOUT_SNIPER )
    {
        if ( param2 == 1 )
        {
            SetSniper( client, team, !GetSniper( client, team ) );
            SaveLoadouts( client );
        }

        param2 -= 1;
    }

    if ( ShowKevlarOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            SetKevlar( client, team, loadout, !GetKevlar( client, team, loadout ) );
            SaveLoadouts( client );
        }

        param2 -= 1;
    }

    if ( ShowHelmetOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            SetHelmet( client, team, loadout, !GetHelmet( client, team, loadout ) );
            SaveLoadouts( client );
        }

        param2 -= 1;
    }

    if ( ShowDefuseOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            SetDefuse( client, team, loadout, !GetDefuse( client, team, loadout ) );
            SaveLoadouts( client );
        }

        param2 -= 1;
    }

    if ( ShowPrimaryOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            GiveWeaponCategoryListMenu( client, team, loadout );
            return;
        }

        param2 -= 1;
    }

    if ( ShowSecondaryOption( client, team, loadout ) )
    {
        if ( param2 == 1 )
        {
            GiveWeaponCategoryMenu( client, team, loadout, WCAT_PISTOL );
            return;
        }

        param2 -= 1;
    }

    GiveLoadoutMenu( client, team, loadout );
}

public int MenuHandler_WeaponCategoryList( Menu menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_End )
    {
        delete menu;
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;
    int team = g_MenuStateTeam[client];
    LoadoutType loadout = g_MenuStateLoadout[client];

    if ( param2 == 9 ) // Go back
    {
        GiveLoadoutMenu( client, team, loadout );
        return;
    }
    
    if ( param2 == 1 ) // No weapon
    {
        SetPrimary( client, team, loadout, WEAPON_NONE );
        SaveLoadouts( client );
        GiveLoadoutMenu( client, team, loadout );
    }

    int categoryIndex = param2 - 2;

    CSWeaponCategory category = g_PrimaryCategories[categoryIndex];
    GiveWeaponCategoryMenu( client, team, loadout, category );
}

public int MenuHandler_WeaponCategory( Menu menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_End )
    {
        delete menu;
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;
    int team = g_MenuStateTeam[client];
    LoadoutType loadout = g_MenuStateLoadout[client];
    CSWeaponCategory category = g_MenuStateCategory[client];

    int index = 0;
    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);
        if ( !CanBuyWeapon( client, team, loadout, weapon ) ) continue;

        ++index;
        if ( param2 == index )
        {
            if ( category == WCAT_PISTOL )
            {
                SetSecondary( client, team, loadout, weapon );
            }
            else
            {
                SetPrimary( client, team, loadout, weapon );
            }

            SaveLoadouts( client );
        }
    }
    
    GiveLoadoutMenu( client, team, loadout );
}
