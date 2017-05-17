bool CanClutchMode( int client )
{
    return IsClientValidAndInGame( client ) && false;
}

bool IsClutchModePossible()
{
    return Retakes_Enabled() && Retakes_GetNumActivePlayers() >= 4 && Retakes_GetNumActivePlayers() <= 6;
}

void ClutchMode_OnTeamSizesSet( int& tCount, int& ctCount )
{
    // TODO
}

void ClutchMode_OnTeamsSet( ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite )
{
    // TODO
}

void ClutchMode_OnRoundWon( int winner, ArrayList tPlayers, ArrayList ctPlayers )
{
    // TODO
}
