int g_SinceLastPistol = 99;

/**
 * Chooses a loadout type for the next round.
 *
 * @return          Loadout type selected for the next round.
 */
RTLoadout GetLoadout()
{
    if ( GetRandomInt( 0, 99 ) < GetRandomLoadoutProbability() )
    {
        return LOADOUT_RANDOM;
    }

    if ( GetWinStreak() == 0 && g_SinceLastPistol >= 5 || GetIsPistolRoundOnly() )
    {
        g_SinceLastPistol = 0;
        return LOADOUT_PISTOL;
    }

    ++g_SinceLastPistol;
    return LOADOUT_FULL;
}

/**
 * Random choice of helmets for each team on LOADOUT_RANDOM rounds.
 */
bool g_RandomHelmet[TEAM_COUNT];

/**
 * Random choice of armour for each team on LOADOUT_RANDOM rounds.
 */
bool g_RandomArmour[TEAM_COUNT];

/**
 * A randomly selected primary weapon for each team on LOADOUT_RANDOM rounds.
 */
CSWeapon g_RandomPrimary[TEAM_COUNT];

/**
 * A randomly selected secondary weapon for each team on LOADOUT_RANDOM rounds.
 */
CSWeapon g_RandomSecondary[TEAM_COUNT];

/**
 * Weapons that can be selected for LOADOUT_RANDOM rounds.
 */
CSWeapon g_RandomWeapons[] = {
    WEAPON_GLOCK,
    WEAPON_HKP2000,
    WEAPON_USP_SILENCER,
    WEAPON_P250,
    WEAPON_ELITE,
    WEAPON_TEC9,
    WEAPON_FIVESEVEN,
    WEAPON_CZ75A,
    WEAPON_DEAGLE,
    WEAPON_REVOLVER,

    WEAPON_MAC10,
    WEAPON_MP9,
    WEAPON_UMP45,
    WEAPON_BIZON,
    WEAPON_MP7,
    WEAPON_MP5SD,
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
};

int GetRandomWeaponWeight( CSWeapon weapon )
{
    switch( weapon )
    {
        case WEAPON_GLOCK, WEAPON_HKP2000, WEAPON_USP_SILENCER:
            return 0;
        case WEAPON_AWP, WEAPON_SSG08:
            return GetIsHeadshotOnly() ? 0 : 1;
    }

    return 1;
}

/**
 * A randomly selected primary weapon for LOADOUT_RANDOM rounds.
 *
 * @param client    Team to select for.
 * @return          Randomly selected primary weapon.
 */
CSWeapon GetRandomPrimary( int team )
{
    return g_RandomPrimary[GetTeamIndex( team )];
}

/**
 * A randomly selected secondary weapon for LOADOUT_RANDOM rounds.
 *
 * @param client    Team to select for.
 * @return          Randomly selected secondary weapon.
 */
CSWeapon GetRandomSecondary( int team )
{
    return g_RandomSecondary[GetTeamIndex( team )];
}

bool GetRandomArmour( int team )
{
    return g_RandomArmour[GetTeamIndex( team )];
}

bool GetRandomHelmet( int team )
{
    return g_RandomHelmet[GetTeamIndex( team )];
}

/**
 * Randomly selects a primary and secondary weapon for LOADOUT_RANDOM rounds.
 *
 * @param client    Team to select for.
 * @noreturn
 */
void SelectRandomLoadout( int team )
{
    int teamIndex = GetTeamIndex( team );

    int totalWeight = 0;
    for ( int index = 0; index < sizeof(g_RandomWeapons); ++index )
    {
        totalWeight += GetRandomWeaponWeight( g_RandomWeapons[index] );
    }

    int selection = GetRandomInt( 0, totalWeight - 1 );
    CSWeapon weapon = WEAPON_NONE;
    
    for ( int index = 0; index < sizeof(g_RandomWeapons); ++index )
    {
        weapon = g_RandomWeapons[index];
        int weight = GetRandomWeaponWeight( weapon );
        if ( selection < weight ) break;
        selection -= weight;
    }

    if ( GetWeaponCategory( weapon ) == WCAT_PISTOL )
    {
        g_RandomPrimary[teamIndex] = WEAPON_NONE;
        g_RandomSecondary[teamIndex] = weapon;
    }
    else
    {
        g_RandomPrimary[teamIndex] = weapon;
        g_RandomSecondary[teamIndex] = WEAPON_NONE;
    }
}

CSWeapon g_ForceWeapons[] = {
    WEAPON_AK47,
    WEAPON_M4A1,
    WEAPON_M4A1_SILENCER,

    WEAPON_FAMAS,
    WEAPON_GALILAR,

    WEAPON_UMP45,
    WEAPON_MAC10,
    
    WEAPON_TEC9,
    WEAPON_P250
};

float GetForceWeaponValue( CSWeapon weapon )
{
    switch ( weapon )
    {
        case WEAPON_AK47:
            return 1.0;
        case WEAPON_M4A1, WEAPON_M4A1_SILENCER:
            return 0.85;
        case WEAPON_FAMAS, WEAPON_GALILAR:
            return 0.7;
        case WEAPON_UMP45:
            return 0.35;
        case WEAPON_MAC10:
            return 0.2;
        case WEAPON_TEC9:
            return 0.1;
        case WEAPON_P250:
            return 0.0;
    }

    return 0.0;
}

float AllocateForceWeapon( int client, int team, float maxValue )
{
    if ( maxValue < 0.0 ) maxValue = 0.0;

    CSWeapon defaultPistol = team == CS_TEAM_CT ? WEAPON_HKP2000 : WEAPON_GLOCK;

    CSWeapon chosenWeapon = WEAPON_P250;
    for ( int i = 0; i < sizeof(g_ForceWeapons); ++i )
    {
        CSWeapon weapon = g_ForceWeapons[i];
        float value = GetForceWeaponValue( weapon );
        if ( value > maxValue ) continue;
        if ( GetRandomInt( 0, 100 ) > 90 ) continue;

        chosenWeapon = weapon;
        maxValue -= value;
        break;
    }

    if ( GetWeaponCategory( chosenWeapon ) == WCAT_PISTOL )
    {
        SetPrimary( client, team, LOADOUT_FORCE, WEAPON_NONE );
        SetSecondary( client, team, LOADOUT_FORCE, chosenWeapon );
    }
    else
    {
        SetPrimary( client, team, LOADOUT_FORCE, chosenWeapon );
        SetSecondary( client, team, LOADOUT_FORCE, defaultPistol );
    }

    SetKevlar( client, team, LOADOUT_FORCE, true );
    SetHelmet( client, team, LOADOUT_FORCE, true );
    SetDefuse( client, team, LOADOUT_FORCE, true );

    return maxValue;
}

void AllocateForceWeapons( int team, ArrayList players )
{
    int wins = GetWinStreak() - GetWinsUntilForceRounds();
    int count = players.Length;

    float totalValue = count * (0.8 - wins * 0.15);

    ArrayList shuffle = players.Clone();

    while ( shuffle.Length > 0 )
    {
        int remaining = shuffle.Length;
        int index = GetRandomInt( 0, remaining - 1 );
        int client = shuffle.Get( index );
        shuffle.Erase( index );

        float availableValue = totalValue / remaining;
        float spareValue = AllocateForceWeapon( client, team, availableValue );

        totalValue -= availableValue + spareValue;
    }

    CloseHandle( shuffle );
}

/**
 * Records which clients were allocated an AWP in the previous round.
 */
bool g_WasSniper[MAXPLAYERS+1];

/**
 * Checks to see if the given client was allocated an AWP in the previous round.
 *
 * @param client    Client to check.
 * @return          True if the given client was allocated an AWP in the last round.
 */
bool GetWasSniper( int client )
{
    return g_WasSniper[client];
}

/**
 * Sets whether the given client was allocated an AWP in the previous round.
 *
 * @param client    Client to set whether they were an AWPer.
 * @param value     True if the client was an AWPer, false if not.
 * @noreturn
 */
void SetWasSniper( int client, bool value )
{
    g_WasSniper[client] = value;
}

/**
 * Randomly selects a player from the given list of clients to
 * give an AWP, or -1 if no players have opted in to AWP rounds.
 *
 * @param players   List of client indexes.
 * @param team      Team of the list of players.
 * @return          Client index of the chosen AWP player, or -1.
 */
int ChooseSniperPlayer( ArrayList players, int team )
{
    int sniper = -1;
    int bestScore = -1;
    int count = GetArraySize( players );

    for ( int i = 0; i < count; i++ )
    {
        int client = GetArrayCell( players, i );

        bool wasSniper = GetWasSniper( client );
        SetWasSniper( client, false );

        if ( !GetSniperFlag( client, team, SNIPER_ENABLED ) ) continue;
        if ( count == 1 && GetSniperFlag( client, team, SNIPER_NEVERALONE ) ) continue;
        if ( wasSniper && GetSniperFlag( client, team, SNIPER_SOMETIMES ) ) continue;

        int score = GetRandomInt( 0, 65535 );

        if ( score > bestScore )
        {
            sniper = client;
            bestScore = score;
        }
    }

    if ( sniper != -1 )
    {
        SetWasSniper( sniper, true );
    }

    return sniper;
}

/**
 * Records how many rounds the terrorists have won in a row.
 */
int g_WinStreak = 0;

void ResetWinStreak()
{
    g_WinStreak = 0;
}

/**
 * Gets the number of rounds the terrorists have won in a row.
 */
int GetWinStreak()
{
    return g_WinStreak;
}

/**
 * Called when the terrorists win a round.
 */
void OnTerroristsWon()
{
    ++g_WinStreak;
    
    int toScramble = GetWinsUntilScramble();
    if ( toScramble > 0 && g_WinStreak >= toScramble )
    {
        ResetWinStreak();
    }
}

/**
 * Called when the counter-terrorists win a round.
 */
void OnCounterTerroristsWon()
{
    ResetWinStreak();
}

/**
 * Decides if there should be a T-side force buy round.
 *
 * @param loadout   Current loadout type.
 * @param tPlayers  List of Terrorist clients.
 * @param ctPlayers List of Counter-Terrorist clients.
 * @return          True if there should be a T-side force buy round.
 */
bool ShouldHaveTerroristForceRound( RTLoadout loadout, ArrayList tPlayers, ArrayList ctPlayers )
{
    return loadout == LOADOUT_FULL && GetWinStreak() >= GetWinsUntilForceRounds();
}

/**
 * Handles allocating weapons to both teams.
 *
 * @param tPlayers  List of Terrorist clients.
 * @param ctPlayers List of Counter-Terrorist clients.
 * @param bombsite  Bombsite to be retaken.
 * @noreturn
 */
void WeaponAllocator( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
    RTLoadout loadout = GetLoadout();

    RTLoadout tLoadout = loadout;
    RTLoadout ctLoadout = loadout;

    if ( ShouldHaveTerroristForceRound( loadout, tPlayers, ctPlayers ) )
    {
        tLoadout = LOADOUT_FORCE;
    }

    if ( loadout == LOADOUT_RANDOM )
    {
        SelectRandomLoadout( CS_TEAM_T );
        SelectRandomLoadout( CS_TEAM_CT );

        bool hasArmour = GetRandomInt( 0, 99 ) <= 90;
        bool hasHelmet = hasArmour && GetRandomInt( 0, 99 ) <= 75;

        g_RandomArmour[GetTeamIndex( CS_TEAM_T )] = hasArmour;
        g_RandomHelmet[GetTeamIndex( CS_TEAM_T )] = hasHelmet;
        
        g_RandomArmour[GetTeamIndex( CS_TEAM_CT )] = hasArmour;
        g_RandomHelmet[GetTeamIndex( CS_TEAM_CT )] = hasHelmet;
    }

    char loadoutNameT[32];
    GetLoadoutName( CS_TEAM_T, tLoadout, loadoutNameT, sizeof(loadoutNameT) );
    
    char loadoutNameCT[32];
    GetLoadoutName( CS_TEAM_CT, ctLoadout, loadoutNameCT, sizeof(loadoutNameCT) );

    //char hudMessage[256];

    if ( strcmp( loadoutNameT, loadoutNameCT, false ) == 0 )
    {
        Retakes_MessageToAll( "%t", "SymmetricRoundMessage", loadoutNameT );
        //Format( hudMessage, sizeof(hudMessage), "Retake %s\n%s Round", SITESTRING( bombsite ), loadoutNameT );
    }
    else
    {
        Retakes_MessageToAll( "%t", "AsymmetricRoundMessage", loadoutNameT, loadoutNameCT );
        //Format( hudMessage, sizeof(hudMessage), "Retake %s\n%s vs %s Round", SITESTRING( bombsite ), loadoutNameT, loadoutNameCT );
    }

/*
    for ( int i = 0; i < tPlayers.Length; ++i )
    {
        int client = tPlayers.Get( i );
        DisplayRoundInfoMessage( client, hudMessage );
    }

    for ( int i = 0; i < ctPlayers.Length; ++i )
    {
        int client = ctPlayers.Get( i );
        DisplayRoundInfoMessage( client, hudMessage );
    }
*/

    HandleTeamLoadout( CS_TEAM_T, tPlayers, tLoadout );
    HandleTeamLoadout( CS_TEAM_CT, ctPlayers, ctLoadout );
}

void DisplayRoundInfoMessage( int client, char[] message ) 
{
    PrintHintText( client, message );
}

void HandleTeamLoadout( int team, ArrayList players, RTLoadout loadout )
{
    if ( loadout == LOADOUT_FORCE )
    {
        AllocateForceWeapons( team, players );
    }

    int sniper = -1;
    if ( !GetIsHeadshotOnly() && loadout == LOADOUT_FULL )
    {
        sniper = ChooseSniperPlayer( players, team );
    }

    int count = GetArraySize( players );
    
    for ( int i = 0; i < count; i++ )
    {
        int client = GetArrayCell( players, i );
        HandleLoadout( client, team, client == sniper ? LOADOUT_SNIPER : loadout );
    }
}

/**
 * Handles allocating weapons for a specific client.
 *
 * @param client    Client to allocate weapons to.
 * @param team      Team that the client will spawn as.
 * @param loadout   Loadout chosen for this client.
 * @noreturn
 */
void HandleLoadout( int client, int team, RTLoadout loadout )
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

    if ( loadout == LOADOUT_RANDOM )
    {
        GetWeaponClassName( GetRandomPrimary( team ), primary, sizeof(primary) );
        GetWeaponClassName( GetRandomSecondary( team ), secondary, sizeof(secondary) );

        kevlar = GetRandomArmour( team ) ? 100 : 0;
        helmet = GetRandomHelmet( team );
    }
    else
    {
        GetWeaponClassName( GetPrimary( client, team, loadout ), primary, sizeof(primary) );
        GetWeaponClassName( GetSecondary( client, team, loadout ), secondary, sizeof(secondary) );
        
        int remaining = GetStartMoney( loadout ) - GetLoadoutCost( client, team, loadout );
        
        if ( remaining > GetMaxNadeValue( team, loadout ) ) remaining = GetMaxNadeValue( team, loadout );

        FillGrenades( team, loadout, remaining, 2, nades, sizeof(nades) );

        kevlar = GetKevlar( client, team, loadout ) ? 100 : 0;
        helmet = GetHelmet( client, team, loadout );
        kit = GetDefuse( client, team, loadout );
    }

    Retakes_SetPlayerInfo( client, primary, secondary, nades, health, kevlar, helmet, kit );
}
