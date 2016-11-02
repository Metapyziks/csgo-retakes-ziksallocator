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
 * Appends the given grenade character to an array at the given position if it
 * costs less than the given amount of money, and the given count is less than
 * the maximum number of grenades that can be held of that grenade type.
 *
 * @param nades     Destination list of array characters.
 * @param index     Index to write this grenade character to.
 * @param nade      Grenade character to append.
 * @param team      Team of the client that available grenades are being found for.
 * @param loadout   Current loadout for the client.
 * @param money     Remaining money for the client.
 * @param count     Number of grenades held by the client of the given grenade type.
 * @return          Either the old index value if the grenade wasn't appended, or
 *                  (index + 1) if the grenade was appended.
 */
int AppendGrenadeIfAvailable( char[] nades, int index, char nade, int team, RTLoadout loadout, int money, int count )
{
    if ( count >= GetMaxGrenades( team, loadout, nade ) ) return index;
    if ( money < GetGrenadeCost( team, nade ) ) return index;

    if ( nade == 'm' && team == CS_TEAM_CT ) nade = 'i';
    if ( nade == 'i' && team == CS_TEAM_T ) nade = 'm';

    nades[index] = nade;
    return index + 1;
}

/**
 * Gets a string containing characters for each type of grenade available to be
 * purchased by a client given their team, loadout, and money remaining.
 *
 * @param team          Team of the client.
 * @param loadout       Current loadout of the client.
 * @param money         Remaining money of the client.
 * @param currentNades  Grenades currently held by the client.
 * @param available     Output array to write available grenade characters to.
 * @return              Number of available grenades written.
 */
int GetAvailableGrenades( int team, RTLoadout loadout, int money, char[] currentNades, char[] available )
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

/**
 * Appends some randomly chosen grenade characters to the given array,
 * limited by the given amount of money and keeping within the maximum
 * grenade counts.
 *
 * @param team      Team of the client to allocate grenades to.
 * @param loadout   Current loadout of the client.
 * @param money     Remaining money that can be used to allocate grenades.
 * @param nades     Output grenade character array, can already contain
 *                  grenades currently owned by the client.
 * @param maxLength Size of nades array.
 */
void FillGrenades( int team, RTLoadout loadout, int money, char[] nades, int maxLength )
{
    int index = strlen( nades );

    char available[NADE_STRING_LENGTH];
    while ( index < maxLength - 1 )
    {
        int availableCount = GetAvailableGrenades( team, loadout, money, nades, available );
        if ( availableCount == 0 ) break;

        int rand = GetRandomInt( 0, availableCount - 1 );
        nades[index++] = available[rand];
        money -= GetGrenadeCost( team, available[rand] );
    }

    nades[index] = 0;
}
