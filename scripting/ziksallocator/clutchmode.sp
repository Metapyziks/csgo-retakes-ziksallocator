#define CLUTCH_MODE_COST 10

bool g_WasClutchMode = false;
bool g_ClutchModeActive = false;

int g_ClutchPoints[MAXPLAYERS+1];

void ClutchMode_OnClientConnected( int client )
{
    g_ClutchPoints[client] = 0;
}

bool CanClutchMode( int client )
{
    return IsClientValidAndInGame( client ) && g_ClutchPoints[client] >= CLUTCH_MODE_COST;
}

void GiveClutchPoints( int client, int points )
{
    if ( points == 0 ) return;

    g_ClutchPoints[client] += points;
    
    char clientName[64];
    GetClientName( client, clientName, sizeof(clientName) );

    char plural[2] = "s";
    if ( points == 1 || points == -1 ) plural[0] = 0;

    Retakes_MessageToAll( "{GREEN}%s{NORMAL} %s {LIGHT_RED}%i{NORMAL} clutch point%s ({LIGHT_RED}%i{NORMAL} total)!",
        clientName, points < 0 ? "lost" : "gained", points < 0 ? -points : points, plural, g_ClutchPoints[client] );
}

void TakeClutchPoints( int client, int points )
{
    g_ClutchPoints[ client ] -= points;
}

void ClutchMode_PlayerDeath( Event event )
{
    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( victim ) ) return;

    int attacker = GetClientOfUserId( event.GetInt( "attacker" ) );
    if ( !IsClientValidAndInGame( attacker ) ) return;

    bool teamKill = GetClientTeam( victim ) == GetClientTeam( attacker );
    if ( teamKill )
    {
        GiveClutchPoints( attacker, -1 );
    }
}

void ClutchMode_OnTeamSizesSet( int& tCount, int& ctCount )
{
    if ( tCount < 2 || ctCount >= 5 )
    {
        g_ClutchModeActive = false;
    }

    if ( g_ClutchModeActive )
    {
        --tCount;
        ++ctCount;
        
        if ( !g_WasClutchMode )
        {
            g_WasClutchMode = true;

            char modeType[8] = "CLUTCH";

            if ( GetRandomInt( 0, 99 ) == 0 )
            {
                modeType[1] = modeType[2];
                modeType[2] = modeType[4];
                modeType[3] = modeType[5] + 3;
                modeType[4] = modeType[5] = 0;
            }
            
            Retakes_MessageToAll( "{GREEN}%s MODE{NORMAL}!", modeType );
        }
    }
    else
    {
        g_WasClutchMode = false;
    }
}

void ClutchMode_OnRoundWon( int winner, ArrayList tPlayers, ArrayList ctPlayers )
{
    ArrayList players = winner == CS_TEAM_CT ? ctPlayers : tPlayers;

    if ( winner == CS_TEAM_CT ) g_ClutchModeActive = false;

    if ( g_ClutchModeActive || tPlayers.Length < 2 || ctPlayers.Length < 2 ) return;

    int totalPoints = 0;    
    for ( int i = 0; i < players.Length; ++i )
    {
        int client = players.Get( i );
        int roundPoints = Retakes_GetRoundPoints( client );

        totalPoints += roundPoints;
    }

    for ( int i = 0; i < players.Length; ++i )
    {
        int client = players.Get( i );
        int roundPoints = Retakes_GetRoundPoints( client );
        
        char clientName[64];
        GetClientName( client, clientName, sizeof(clientName) );

        if ( IsClientValidAndInGame( client ) && (roundPoints * 100) / totalPoints > 75 )
        {
            GiveClutchPoints( client, roundPoints / 50 );
        }

        if ( !g_ClutchModeActive && CanClutchMode( client ) )
        {
            TakeClutchPoints( client, CLUTCH_MODE_COST );
            Retakes_SetRoundPoints( client, roundPoints + 1000 );
            g_ClutchModeActive = true;
        }
    }
}
