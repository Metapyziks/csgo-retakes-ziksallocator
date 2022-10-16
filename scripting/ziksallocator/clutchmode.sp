#include <priorityqueue>

#define MAX_ROLLING_AVERAGE_ROUNDS 10
#define POINTS_LOSS 5000

bool g_ClutchModeActive = false;

int g_RoundIndex = 0;
int g_RoundScores[MAXPLAYERS+1][MAX_ROLLING_AVERAGE_ROUNDS];

ArrayList g_RankingQueue;

void ClutchMode_OnClientConnected( int client )
{
    for ( int i = 0; i < MAX_ROLLING_AVERAGE_ROUNDS; ++i )
    {
        g_RoundScores[client][i] = -POINTS_LOSS;
    }
}

void ClutchMode_OnPostRoundEnqueue( ArrayList rankingQueue )
{
    g_RankingQueue = rankingQueue;
    g_RoundIndex = (g_RoundIndex + 1) % MAX_ROLLING_AVERAGE_ROUNDS;

    for ( int client = 1; client < MaxClients; ++client )
    {
        if ( !IsClientValidAndInGame( client ) ) continue;

        int index = PQ_FindClient( rankingQueue, client );
        int score = -POINTS_LOSS;

        if ( index != -1 )
        {
            score = rankingQueue.Get( index, 1 );
        }

        g_RoundScores[client][g_RoundIndex] = score;
    }
}

int ClutchMode_GetRollingTotal( int client, int rounds )
{
    if ( rounds > MAX_ROLLING_AVERAGE_ROUNDS )
    {
        rounds = MAX_ROLLING_AVERAGE_ROUNDS;
    }

    if ( !IsClientValidAndInGame( client ) )
    {
        return -POINTS_LOSS * rounds;
    }

    int total = 0;
    for ( int round = 0; round < rounds; ++round )
    {
        int index = (g_RoundIndex - round + MAX_ROLLING_AVERAGE_ROUNDS) % MAX_ROLLING_AVERAGE_ROUNDS;
        total += g_RoundScores[client][index];
    }

    return total;
}

void ClutchMode_OnTeamSizesSet( int& tCount, int& ctCount )
{
    if ( tCount != ctCount || tCount <= 1 )
    {
        g_ClutchModeActive = false;
        return;
    }

    if ( GetWinStreak() == 0 && g_ClutchModeActive )
    {
        g_ClutchModeActive = false;
        return;
    }

    if ( !g_ClutchModeActive && GetWinStreak() >= 5 )
    {
        g_ClutchModeActive = true;

        ResetWinStreak();

        for ( int client = 1; client < MaxClients; ++client )
        {
            if ( !IsClientValidAndInGame( client ) )
            {
                continue;
            }

            PQ_Enqueue( g_RankingQueue, client, ClutchMode_GetRollingTotal( client, 3 ) );
        }

        Retakes_MessageToAll( "%t", "ClutchModeMessage" );
    }

    if ( g_ClutchModeActive )
    {
        --tCount;
        ++ctCount;
    }
}
