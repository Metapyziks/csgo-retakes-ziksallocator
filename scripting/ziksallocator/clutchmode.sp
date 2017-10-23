bool g_ClutchModeActive = false;
int g_SinceLastClutchMode = 0;

void ClutchMode_OnTeamSizesSet( int& tCount, int& ctCount )
{
    if ( tCount != ctCount || tCount <= 1 )
    {
        g_ClutchModeActive = false;
        g_SinceLastClutchMode = 0;
        return;
    }
    
    if ( GetWinStreak() == 0 )
    {
        if ( g_ClutchModeActive )
        {
            g_SinceLastClutchMode = 0;
            g_ClutchModeActive = false;
        }
        else
        {
            ++g_SinceLastClutchMode;
        }
    }
    
    if ( !g_ClutchModeActive && g_SinceLastClutchMode >= 3 )
    {
        g_ClutchModeActive = true;
        g_SinceLastClutchMode = 0;
        
        Retakes_MessageToAll( "%t", "ClutchModeMessage" );
    }

    if ( g_ClutchModeActive )
    {
        --tCount;
        ++ctCount;
    }
}
