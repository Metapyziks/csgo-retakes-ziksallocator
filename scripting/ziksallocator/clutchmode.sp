bool g_WasClutchMode = false;
bool g_ClutchModeActive = false;

int g_ClutchModeTarget = -1;

bool CanClutchMode( int client )
{
    return IsClientValidAndInGame( client ) && g_ClutchPoints[client] >= CLUTCH_MODE_COST;
}

bool IsClutchModePossible()
{
    return Retakes_Enabled() && Retakes_GetNumActivePlayers() >= 4 && Retakes_GetNumActivePlayers() <= 7;
}

void GiveClutchPoints( int client, int points )
{
    if ( !IsClutchModePossible() ) return;
    if ( points == 0 ) return;

    g_ClutchPoints[client] += points;
    SaveClutchPoints( client );
    
    char clientName[64];
    GetClientName( client, clientName, sizeof(clientName) );

    char plural[2] = "s";
    if ( points == 1 || points == -1 ) plural[0] = 0;

    Retakes_MessageToAll( "{GREEN}%s{NORMAL} %s {LIGHT_RED}%i{NORMAL} clutch point%s ({LIGHT_RED}%i{NORMAL} total)!",
        clientName, points < 0 ? "lost" : "gained", points < 0 ? -points : points, plural, g_ClutchPoints[client] );
}

void TakeClutchPoints( int client, int points )
{
    if ( !Retakes_Enabled() ) return;
    if ( points == 0 ) return;

    g_ClutchPoints[ client ] -= points;
    SaveClutchPoints( client );
}

void ClutchMode_PlayerDeath( Event event )
{
    if ( !Retakes_Enabled() ) return;

    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( victim ) ) return;

    int attacker = GetClientOfUserId( event.GetInt( "attacker" ) );
    if ( !IsClientValidAndInGame( attacker ) ) return;

    bool teamKill = GetClientTeam( victim ) == GetClientTeam( attacker );
    if ( teamKill && victim != attacker )
    {
        GiveClutchPoints( attacker, g_ClutchPoints[attacker] <= 0 ? -1 : -g_ClutchPoints[attacker] );
    }
}

void ClutchMode_OnTeamSizesSet( int& tCount, int& ctCount )
{
    if ( tCount < 2 || ctCount >= 5 || !IsClientValidAndInGame( g_ClutchModeTarget ) )
    {
        g_ClutchModeActive = false;
        g_ClutchModeTarget = -1;
    }

    if ( g_ClutchModeActive )
    {
        --tCount;
        ++ctCount;
        
        Retakes_SetRoundPoints( g_ClutchModeTarget, 1000 );
        
        if ( !g_WasClutchMode )
        {
            g_WasClutchMode = true;

            TakeClutchPoints( g_ClutchModeTarget, CLUTCH_MODE_COST );

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

    bool clutchModeAvailable = !g_ClutchModeActive && tPlayers.Length >= 2 && ctPlayers.Length >= 2;

    for ( int i = 0; i < players.Length; ++i )
    {
        int client = players.Get( i );
        int roundPoints = Retakes_GetRoundPoints( client );

        roundPoints /= 100;

        int clutchPoints = roundPoints - 1;

        if ( IsClientValidAndInGame( client ) && clutchPoints > 0 )
        {
            GiveClutchPoints( client, clutchPoints );
        }

        if ( clutchModeAvailable && CanClutchMode( client ) )
        {
            g_ClutchModeTarget = client;
            g_ClutchModeActive = true;
        }
    }
}
