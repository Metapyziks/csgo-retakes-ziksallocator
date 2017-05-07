bool g_WasClutchMode = false;
bool g_ClutchModeActive = false;

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
            Retakes_MessageToAll( "{GREEN}CLUTCH MODE{NORMAL}!" );
        }
    }
    else
    {
        g_WasClutchMode = false;
    }
}

void ClutchMode_OnRoundWon( int winner, ArrayList tPlayers, ArrayList ctPlayers )
{
    if ( winner == CS_TEAM_CT )
    {
        g_ClutchModeActive = false;
        return;
    }

    if ( g_ClutchModeActive ) return;

    for ( int i = 0; i < tPlayers.Length; ++i )
    {
        int client = tPlayers.Get( i );
        int roundPoints = Retakes_GetRoundPoints( client );

        char clientName[64];
        GetClientName( client, clientName, sizeof(clientName) );

        if ( roundPoints < 50 )
        {
            g_ClutchModeActive = true;
        }
        else if ( !IsClientValidAndInGame( client ) || GetClientTeam( client ) != CS_TEAM_T )
        {
            g_ClutchModeActive = false;
            return;
        }
    }
}
