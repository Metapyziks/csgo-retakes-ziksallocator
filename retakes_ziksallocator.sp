#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#define MENU_TIME_LENGTH 15

#define LOADOUT_KEVLAR_COST 650
#define LOADOUT_HELMET_COST 350
#define LOADOUT_DEFUSE_COST 400

enum CSWeaponCategory
{
    WCAT_PISTOL,
    WCAT_SMG,
    WCAT_HEAVY,
    WCAT_RIFLE
}

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
    WEAPON_SG553,
    WEAPON_AUG,
    WEAPON_AWP,
    WEAPON_G3SG1,
    WEAPON_SCAR20
}

enum RoundType
{
    ROUND_PISTOL,
    ROUND_FORCE,
    ROUND_FULL,
    ROUND_RESET
}

public Plugin myinfo = {
    name = "CS:GO Retakes: ziks.net weapon allocator",
    author = "Ziks",
    description = "A more complex weapon allocator with customizability",
    version = PLUGIN_VERSION,
    url = "https://csgo.ziks.net"
};

//
// Loadout fields
//

bool g_Kevlar[MAXPLAYERS+1][4][4];
void SetKevlar( int client, int team, RoundType roundType, bool enabled )
{
    g_Kevlar[client][team][roundType] = enabled;

    if ( !enabled )
    {
        SetHelmet( client, team, roundType, false );
    }
}

bool GetKevlar( int client, int team, RoundType roundType )
{
    return g_Kevlar[client][team][roundType];
}

bool g_Helmet[MAXPLAYERS+1][4][4];
void SetHelmet( int client, int team, RoundType roundType, bool enabled )
{
    g_Helmet[client][team][roundType] = enabled;

    if ( enabled )
    {
        SetKevlar( client, team, roundType, true );
    }
}

bool GetHelmet( int client, int team, RoundType roundType )
{
    return GetKevlar( client, team, roundType ) && g_Helmet[client][team][roundType];
}

bool g_Defuse[MAXPLAYERS+1][4];
void SetDefuse( int client, int team, RoundType roundType, bool enabled )
{
    if ( team != CS_TEAM_CT ) return;
    g_Defuse[client][roundType] = enabled;
}

bool GetDefuse( int client, int team, RoundType roundType )
{
    if ( team != CS_TEAM_CT ) return false;
    return g_Defuse[client][roundType];
}

CSWeapon g_Primary[MAXPLAYERS+1][4][4];
void SetPrimary( int client, int team, RoundType roundType, CSWeapon weapon )
{
    g_Primary[client][team][roundType] = weapon;
}

CSWeapon GetPrimary( int client, int team, RoundType roundType )
{
    return g_Primary[client][team][roundType];
}

CSWeapon g_Secondary[MAXPLAYERS+1][4][4];
void SetSecondary( int client, int team, RoundType roundType, CSWeapon weapon )
{
    g_Secondary[client][team][roundType] = weapon;
}

CSWeapon GetSecondary( int client, int team, RoundType roundType )
{
    return g_Secondary[client][team][roundType];
}

void ResetAllLoadouts( int client )
{
    ResetPistolRoundLoadout( client );
    ResetForceBuyRoundLoadout( client );
    ResetFullBuyRoundLoadout( client );
}

void ResetPistolRoundLoadout( int client )
{
    SetHelmet( client, CS_TEAM_T, ROUND_PISTOL, false );
    SetHelmet( client, CS_TEAM_CT, ROUND_PISTOL, false );

    SetKevlar( client, CS_TEAM_T, ROUND_PISTOL, true );
    SetKevlar( client, CS_TEAM_CT, ROUND_PISTOL, true );

    SetDefuse( client, CS_TEAM_CT, ROUND_PISTOL, false );

    SetPrimary( client, CS_TEAM_T, ROUND_PISTOL, WEAPON_NONE );
    SetPrimary( client, CS_TEAM_CT, ROUND_PISTOL, WEAPON_NONE );
    SetSecondary( client, CS_TEAM_T, ROUND_PISTOL, WEAPON_GLOCK );
    SetSecondary( client, CS_TEAM_CT, ROUND_PISTOL, WEAPON_HKP2000 );
}

void ResetForceBuyRoundLoadout( int client )
{
    SetHelmet( client, CS_TEAM_T, ROUND_FORCE, true );
    SetHelmet( client, CS_TEAM_CT, ROUND_FORCE, true );

    SetKevlar( client, CS_TEAM_T, ROUND_FORCE, true );
    SetKevlar( client, CS_TEAM_CT, ROUND_FORCE, true );

    SetDefuse( client, CS_TEAM_CT, ROUND_FORCE, false );

    SetPrimary( client, CS_TEAM_T, ROUND_FORCE, WEAPON_UMP45 );
    SetPrimary( client, CS_TEAM_CT, ROUND_FORCE, WEAPON_UMP45 );
    SetSecondary( client, CS_TEAM_T, ROUND_FORCE, WEAPON_GLOCK );
    SetSecondary( client, CS_TEAM_CT, ROUND_FORCE, WEAPON_HKP2000 );
}

void ResetFullBuyRoundLoadout( int client )
{
    SetHelmet( client, CS_TEAM_T, ROUND_FULL, true );
    SetHelmet( client, CS_TEAM_CT, ROUND_FULL, true );

    SetKevlar( client, CS_TEAM_T, ROUND_FULL, true );
    SetKevlar( client, CS_TEAM_CT, ROUND_FULL, true );

    SetDefuse( client, CS_TEAM_CT, ROUND_FULL, true );

    SetPrimary( client, CS_TEAM_T, ROUND_FULL, WEAPON_AK47 );
    SetPrimary( client, CS_TEAM_CT, ROUND_FULL, WEAPON_M4A1 );
    SetSecondary( client, CS_TEAM_T, ROUND_FULL, WEAPON_GLOCK );
    SetSecondary( client, CS_TEAM_CT, ROUND_FULL, WEAPON_HKP2000 );
}

//
// Economy
//

int GetStartMoney( RoundType roundType )
{
    switch ( roundType )
    {
        case ROUND_PISTOL:
            return 800;
        case ROUND_FORCE:
            return 2400;
        case ROUND_FULL:
            return 8000;
    }

    return 16000;
}

bool CanShowWeaponCategory( int client, int team, RoundType roundType, CSWeaponCategory category )
{
    return CanSelectWeaponCategory( client, team, roundType, GetStartMoney( roundType ), category );
}

bool CanSelectWeaponCategory( int client, int team, RoundType roundType, int money, CSWeaponCategory category )
{
    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);

        if ( !CanBuyWeapon( client, team, roundType, weapon ) ) continue;
        if ( GetWeaponCost( client, weapon ) > money ) continue;

        return true;
    }

    return false;
}

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

bool CanBuyWeapon( int client, int team, RoundType roundType, CSWeapon weapon )
{
    if ( GetWeaponCost( client, weapon ) > GetStartMoney( roundType ) ) return false;

    switch ( weapon )
    {
        case WEAPON_GLOCK, WEAPON_TEC9, WEAPON_MAC10, WEAPON_SAWEDOFF,
            WEAPON_GALILAR, WEAPON_AK47, WEAPON_SG553, WEAPON_G3SG1:
            return team == CS_TEAM_T;
        case WEAPON_HKP2000, WEAPON_FIVESEVEN, WEAPON_MP9, WEAPON_MAG7,
            WEAPON_FAMAS, WEAPON_M4A1, WEAPON_M4A1_SILENCER, WEAPON_AUG, WEAPON_SCAR20:
            return team == CS_TEAM_CT;
    }

    return true;
}

bool ShowKevlarOption( int team, RoundType roundType )
{
    return roundType != ROUND_FULL;
}

bool ShowHelmetOption( int team, RoundType roundType )
{
    return roundType != ROUND_PISTOL && roundType != ROUND_FULL;
}

bool ShowDefuseOption( int team, RoundType roundType )
{
    return team == CS_TEAM_CT && roundType != ROUND_FULL;
}

bool ShowPrimaryOption( int team, RoundType roundType )
{
    return roundType != ROUND_PISTOL;
}

bool ShowSecondaryOption( int team, RoundType roundType )
{
    return true;
}

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
        case WEAPON_SG553:
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

int GetMaxTotalGrenades( int team )
{
    return 4;
}

int GetMaxGrenades( int team, char nadeChar )
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

int GetDecoyProbability()
{
    return 10;
}

int GetLoadoutCost( int client, int team, RoundType roundType )
{
    int total = 0;

    if ( GetKevlar( client, team, roundType ) ) total += LOADOUT_KEVLAR_COST;
    if ( GetHelmet( client, team, roundType ) ) total += LOADOUT_HELMET_COST;
    if ( GetDefuse( client, team, roundType ) ) total += LOADOUT_DEFUSE_COST;

    total += GetWeaponCost( client, GetSecondary( client, team, roundType ) );
    total += GetWeaponCost( client, GetPrimary( client, team, roundType ) );

    return total;
}

//
// String lookups
//

void GetRoundTypeName( RoundType roundType, char[] buffer, int maxLength )
{
    switch ( roundType )
    {
        case ROUND_PISTOL: strcopy( buffer, maxLength, "Pistol" );
        case ROUND_FORCE:  strcopy( buffer, maxLength, "Force Buy" );
        case ROUND_FULL:   strcopy( buffer, maxLength, "Full Buy" );
    }
}

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

void GetTeamAbbreviation( int team, char[] buffer, int maxLength )
{
    switch ( team )
    {
        case CS_TEAM_T:  strcopy( buffer, maxLength, "T" );
        case CS_TEAM_CT: strcopy( buffer, maxLength, "CT" );
    }
}

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
        case WEAPON_SG553:         strcopy( buffer, maxLength, "SG 553" );
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
        case WEAPON_SG553:         strcopy( buffer, maxLength, "weapon_sg553" );
        case WEAPON_AUG:           strcopy( buffer, maxLength, "weapon_aug" );
        case WEAPON_AWP:           strcopy( buffer, maxLength, "weapon_awp" );
        case WEAPON_G3SG1:         strcopy( buffer, maxLength, "weapon_g3sg1" );
        case WEAPON_SCAR20:        strcopy( buffer, maxLength, "weapon_scar20" );
    }
}

//
// Callbacks
//

public void OnPluginStart()
{

}

public void OnClientConnected( int client )
{
    ResetAllLoadouts( client );
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

}

//
// Weapon allocator
//

int g_RoundCounter = 0;

RoundType GetRoundType( int roundNumber )
{
    if ( (roundNumber % 10) < 3 )
    {
        return ROUND_PISTOL;
    }

    if ( (roundNumber % 10) < 5 )
    {
        return ROUND_FORCE;
    }

    return ROUND_FULL;
}

void WeaponAllocator( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
    int tCount = GetArraySize( tPlayers );
    int ctCount = GetArraySize( ctPlayers );

    RoundType roundType = GetRoundType( g_RoundCounter++ );

    for (int i = 0; i < tCount; i++)
    {
        int client = GetArrayCell( tPlayers, i );
        HandleLoadout( client, CS_TEAM_T, roundType );
    }

    for (int i = 0; i < ctCount; i++)
    {
        int client = GetArrayCell(ctPlayers, i);
        HandleLoadout( client, CS_TEAM_CT, roundType );
    }
}

void HandleLoadout( int client, int team, RoundType roundType )
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

    GetWeaponClassName( GetPrimary( client, team, roundType ), primary, sizeof(primary) );
    GetWeaponClassName( GetSecondary( client, team, roundType ), secondary, sizeof(secondary) );

    int remaining = GetStartMoney( roundType ) - GetLoadoutCost( client, team, roundType );
    FillGrenades( team, remaining, nades );

    health = 100;
    kevlar = GetKevlar( client, team, roundType ) ? 100 : 0;
    helmet = GetHelmet( client, team, roundType );
    kit = GetDefuse( client, team, roundType );

    Retakes_SetPlayerInfo( client, primary, secondary, nades, health, kevlar, helmet, kit );
}

int AppendGrenadeIfAvailable( char[] nades, int index, char nade, int team, int money, int count )
{
    if ( count >= GetMaxGrenades( team, nade ) ) return index;
    if ( money < GetGrenadeCost( team, nade ) ) return index;

    if ( nade == 'm' && team == CS_TEAM_CT ) nade = 'i';
    if ( nade == 'i' && team == CS_TEAM_T ) nade = 'm';

    nades[index] = nade;
    return index + 1;
}

int GetAvailableGrenades( int team, int money, char[] currentNades, char[] available )
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

    if ( strlen( currentNades ) >= GetMaxTotalGrenades( team ) ) return 0;
    count = AppendGrenadeIfAvailable( available, count, 's', team, money, smokes );
    count = AppendGrenadeIfAvailable( available, count, 'f', team, money, flashes );
    count = AppendGrenadeIfAvailable( available, count, 'm', team, money, molotovs );
    count = AppendGrenadeIfAvailable( available, count, 'h', team, money, explosives );

    if ( GetRandomInt( 0, 99 ) < GetDecoyProbability() )
    {
        count = AppendGrenadeIfAvailable( available, count, 'd', team, money, decoys );
    }

    available[count] = 0;

    return count;
}

void FillGrenades( int team, int money, char[] nades )
{
    int index = strlen( nades );

    char available[NADE_STRING_LENGTH];
    while ( true )
    {
        int availableCount = GetAvailableGrenades( team, money, nades, available );
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

int g_LoadoutMenuTeam[MAXPLAYERS+1];
RoundType g_LoadoutMenuRoundType[MAXPLAYERS+1];
CSWeaponCategory g_LoadoutMenuCategory[MAXPLAYERS+1];

void GiveWeaponsMenu( int client )
{
    Handle menu = CreateMenu( MenuHandler_RoundType );
    SetMenuTitle( menu, "Configure loadouts:" );
    AddMenuInt( menu, view_as<int>( ROUND_PISTOL ), "Pistol rounds" );
    AddMenuInt( menu, view_as<int>( ROUND_FORCE ), "Force Buy rounds" );
    AddMenuInt( menu, view_as<int>( ROUND_FULL ), "Full Buy rounds" );
    AddMenuInt( menu, view_as<int>( ROUND_RESET ), "Reset all" );
    DisplayMenu( menu, client, MENU_TIME_LENGTH );
}

void GiveTeamSelectMenu( int client, RoundType roundType )
{
    g_LoadoutMenuRoundType[client] = roundType;

    char roundTypeName[16];
    GetRoundTypeName( roundType, roundTypeName, sizeof(roundTypeName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "Configure %s round loadout:", roundTypeName );

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

void AddMoneyAvailableItems( Panel menu, int moneyAvailable )
{
    char buffer[64];
    Format( buffer, sizeof(buffer), "Money available: $%i", moneyAvailable );

    menu.DrawItem( buffer, ITEMDRAW_RAWLINE );
    menu.DrawItem( " ", ITEMDRAW_RAWLINE  );
}

void GiveLoadoutMenu( int client, int team, RoundType roundType )
{
    g_LoadoutMenuTeam[client] = team;
    g_LoadoutMenuRoundType[client] = roundType;

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char roundTypeName[16];
    GetRoundTypeName( roundType, roundTypeName, sizeof(roundTypeName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "Loadout for %s %s rounds:", teamAbbrev, roundTypeName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
    
    int currentCost = GetLoadoutCost( client, team, roundType );
    int moneyAvailable = GetStartMoney( roundType ) - currentCost;
    AddMoneyAvailableItems( menu, moneyAvailable );

    if ( ShowKevlarOption( team, roundType ) )
    {
        AddGearOption( menu, "Kevlar", moneyAvailable,
            LOADOUT_KEVLAR_COST, GetKevlar( client, team, roundType ) );
    }

    if ( ShowHelmetOption( team, roundType ) )
    {
        int cost = LOADOUT_HELMET_COST;
        if ( !GetKevlar( client, team, roundType ) )
        {
            cost += LOADOUT_KEVLAR_COST;
        }

        AddGearOption( menu, "Helmet", moneyAvailable,
            cost, GetHelmet( client, team, roundType ) );
    }

    if ( ShowDefuseOption( team, roundType ) )
    {
        AddGearOption( menu, "Defuse Kit", moneyAvailable,
            LOADOUT_DEFUSE_COST, GetDefuse( client, team, roundType ) );
    }

    if ( ShowPrimaryOption( team, roundType ) )
    {
        char weaponName[32];
        GetWeaponName( GetPrimary( client, team, roundType ), weaponName, sizeof(weaponName) );

        Format( buffer, sizeof(buffer), "Primary: %s", weaponName );

        menu.DrawItem( buffer );
    }

    if ( ShowSecondaryOption( team, roundType ) )
    {
        char pistolName[32];
        GetWeaponName( GetSecondary( client, team, roundType ), pistolName, sizeof(pistolName) );

        Format( buffer, sizeof(buffer), "Sidearm: %s", pistolName );

        menu.DrawItem( buffer );
    }

    menu.DrawItem( " ", ITEMDRAW_RAWLINE  );

    menu.DrawItem( "Back" );
    menu.Send( client, MenuHandler_Loadout, MENU_TIME_LENGTH );

    delete menu;
}

CSWeaponCategory g_PrimaryCategories[] = {
    WCAT_SMG,
    WCAT_HEAVY,
    WCAT_RIFLE
};

void GiveWeaponCategoryListMenu( int client, int team, RoundType roundType )
{
    g_LoadoutMenuTeam[client] = team;
    g_LoadoutMenuRoundType[client] = roundType;

    int available = 0;
    CSWeaponCategory lastValid;

    for ( int i = 0; i < sizeof(g_PrimaryCategories); ++i )
    {
        CSWeaponCategory category = g_PrimaryCategories[i];
        if ( !CanShowWeaponCategory( client, team, roundType, category ) ) continue;

        ++available;
        lastValid = category;
    }

    if ( available == 0 ) return;

    if ( available == 1 )
    {
        GiveWeaponCategoryMenu( client, team, roundType, lastValid );
        return;
    }

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char roundTypeName[16];
    GetRoundTypeName( roundType, roundTypeName, sizeof(roundTypeName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "%s %s round primary:", teamAbbrev, roundTypeName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
    
    int currentCost = GetLoadoutCost( client, team, roundType );
    int moneyAvailable = GetStartMoney( roundType ) - currentCost;
    AddMoneyAvailableItems( menu, moneyAvailable );

    CSWeapon weapon = GetPrimary( client, team, roundType );
    if ( weapon != WEAPON_NONE )
    {
        int cost = GetWeaponCost( client, weapon );
        Format( buffer, sizeof(buffer), "No weapon (+$%i)", cost );
        menu.DrawItem( buffer );

        moneyAvailable += cost;
    }
    else
    {
        menu.DrawItem( "No weapon" );
    }

    for ( int i = 0; i < sizeof(g_PrimaryCategories); ++i )
    {
        CSWeaponCategory category = g_PrimaryCategories[i];
        if ( !CanShowWeaponCategory( client, team, roundType, category ) ) continue;

        bool enabled = CanSelectWeaponCategory( client, team, roundType, moneyAvailable, category );

        GetWeaponCategoryName( category, buffer, sizeof(buffer) );
        menu.DrawItem( buffer, enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
    }

    menu.DrawItem( " ", ITEMDRAW_RAWLINE  );

    menu.DrawItem( "Back" );
    menu.Send( client, MenuHandler_WeaponCategoryList, MENU_TIME_LENGTH );

    delete menu;
}

void GiveWeaponCategoryMenu( int client, int team, RoundType roundType, CSWeaponCategory category )
{
    g_LoadoutMenuTeam[client] = team;
    g_LoadoutMenuRoundType[client] = roundType;
    g_LoadoutMenuCategory[client] = category;

    char teamAbbrev[8];
    GetTeamAbbreviation( team, teamAbbrev, sizeof(teamAbbrev) );

    char roundTypeName[16];
    GetRoundTypeName( roundType, roundTypeName, sizeof(roundTypeName) );

    char buffer[128];
    Format( buffer, sizeof(buffer), "%s %s round sidearm:", teamAbbrev, roundTypeName );

    Panel menu = new Panel();
    menu.SetTitle( buffer );
        
    int currentCost = GetLoadoutCost( client, team, roundType );
    int moneyAvailable = GetStartMoney( roundType ) - currentCost;
    AddMoneyAvailableItems( menu, moneyAvailable );

    char weaponName[32];

    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);

        if ( !CanBuyWeapon( client, team, roundType, weapon ) ) continue;

        GetWeaponName( weapon, weaponName, sizeof(weaponName) );

        CSWeapon current = category == WCAT_PISTOL
            ? GetSecondary( client, team, roundType )
            : GetPrimary( client, team, roundType ); 

        int cost = GetWeaponCost( client, weapon );
        int curCost = GetWeaponCost( client, current );
        int diff = cost - curCost;

        if ( diff == 0 )
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

    menu.DrawItem( " ", ITEMDRAW_RAWLINE  );

    menu.DrawItem( "Back" );
    menu.Send( client, MenuHandler_WeaponCategory, MENU_TIME_LENGTH );

    delete menu;
}

//
// Menu handlers
//

public int MenuHandler_RoundType( Handle menu, MenuAction action, int param1, int param2 )
{
    if ( action == MenuAction_End )
    {
        CloseHandle( menu );
        return;
    }

    if ( action != MenuAction_Select ) return;

    int client = param1;
    RoundType choice = view_as<RoundType>( GetMenuInt( menu, param2 ) );

    if ( choice == ROUND_RESET )
    {
        ResetAllLoadouts( client );
        return;
    }

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
    RoundType roundType = g_LoadoutMenuRoundType[client];

    if (team == -1)
    {
        GiveWeaponsMenu( client );
        return;
    }

    GiveLoadoutMenu( client, team, roundType );
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
    int team = g_LoadoutMenuTeam[client];
    RoundType roundType = g_LoadoutMenuRoundType[client];

    if ( ShowKevlarOption( team, roundType ) )
    {
        if ( param2 == 1 )
        {
            SetKevlar( client, team, roundType, !GetKevlar( client, team, roundType ) );
        }

        param2 -= 1;
    }

    if ( ShowHelmetOption( team, roundType ) )
    {
        if ( param2 == 1 )
        {
            SetHelmet( client, team, roundType, !GetHelmet( client, team, roundType ) );
        }

        param2 -= 1;
    }

    if ( ShowDefuseOption( team, roundType ) )
    {
        if ( param2 == 1 )
        {
            SetDefuse( client, team, roundType, !GetDefuse( client, team, roundType ) );
        }

        param2 -= 1;
    }

    if ( ShowPrimaryOption( team, roundType ) )
    {
        if ( param2 == 1 )
        {
            GiveWeaponCategoryListMenu( client, team, roundType );
            return;
        }

        param2 -= 1;
    }

    if ( ShowSecondaryOption( team, roundType ) )
    {
        if ( param2 == 1 )
        {
            GiveWeaponCategoryMenu( client, team, roundType, WCAT_PISTOL );
            return;
        }

        param2 -= 1;
    }

    if ( param2 == 1 ) // Go back
    {
        GiveTeamSelectMenu( client, roundType );
        return;
    }

    GiveLoadoutMenu( client, team, roundType );
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
    int team = g_LoadoutMenuTeam[client];
    RoundType roundType = g_LoadoutMenuRoundType[client];

    if ( param2 == 1 ) // No weapon
    {
        SetPrimary( client, team, roundType, WEAPON_NONE );
    }

    int categoryIndex = param2 - 2;
    if ( categoryIndex < 0 || categoryIndex >= sizeof(g_PrimaryCategories) )
    {
        GiveLoadoutMenu( client, team, roundType );
        return;
    }

    CSWeaponCategory category = g_PrimaryCategories[categoryIndex];
    GiveWeaponCategoryMenu( client, team, roundType, category );
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
    int team = g_LoadoutMenuTeam[client];
    RoundType roundType = g_LoadoutMenuRoundType[client];
    CSWeaponCategory category = g_LoadoutMenuCategory[client];

    int index = 0;
    for ( int i = GetWeaponListMin( category ); i <= GetWeaponListMax( category ); ++i )
    {
        CSWeapon weapon = view_as<CSWeapon>(i);
        if ( !CanBuyWeapon( client, team, roundType, weapon ) ) continue;

        ++index;
        if ( param2 == index )
        {
            if ( category == WCAT_PISTOL )
            {
                SetSecondary( client, team, roundType, weapon );
            }
            else
            {
                SetPrimary( client, team, roundType, weapon );
            }
        }
    }
    
    GiveLoadoutMenu( client, team, roundType );
}
