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
 * Gets an initialism of the given team number.
 *
 * @param loadout   Team number to get the abbreviation of.
 * @param buffer    Character array to write the abbreviation to.
 * @param maxLength Size of the destination character array.
 * @noreturn
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
 * Writes the given boolean array containing values for each team / loadout
 * to a character array.
 *
 * @note            Encodes 'true' as '1', and 'false' as '0'.
 * @param array     Input boolean array.
 * @param dest      Output character array.
 * @param maxLength Size of the output character array.
 * @noreturn
 */
void EncodeTeamLoadoutBools( bool array[TEAM_COUNT][RTLoadout], char[] dest, int maxLength )
{
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(RTLoadout); ++loadout )
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
 * @noreturn
 */
void DecodeTeamLoadoutBools( bool array[TEAM_COUNT][RTLoadout], char[] src )
{
    int length = strlen(src);
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(RTLoadout); ++loadout )
    {
        for ( int team = 0; team < TEAM_COUNT; ++team )
        {
            if ( index >= length ) return;
            array[team][loadout] = src[index++] == '1';
        }
    }
}

/**
 * Writes the given boolean array containing values for each loadout to a
 * character array.
 *
 * @note            Encodes 'true' as '1', and 'false' as '0'.
 * @param array     Input boolean array.
 * @param dest      Output character array.
 * @param maxLength Size of the output character array.
 * @noreturn
 */
void EncodeLoadoutBools( bool array[RTLoadout], char[] dest, int maxLength )
{
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(RTLoadout); ++loadout )
    {
        if ( index >= maxLength - 1 ) break;
        dest[index++] = array[loadout] ? '1' : '0';
    }

    dest[index] = 0;
}

/**
 * Reads the given boolean array containing values for each loadout from
 * a character array.
 *
 * @note            Decodes '1' as 'true', and '0' as 'false'.
 * @param array     Output boolean array.
 * @param src       Input character array.
 * @noreturn
 */
void DecodeLoadoutBools( bool array[RTLoadout], char[] src )
{
    int length = strlen(src);
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(RTLoadout); ++loadout )
    {
        if ( index >= length ) return;
        array[loadout] = src[index++] == '1';
    }
}

/**
 * Writes the given boolean array containing values for each team to a
 * character array.
 *
 * @note            Encodes 'true' as '1', and 'false' as '0'.
 * @param array     Input boolean array.
 * @param dest      Output character array.
 * @param maxLength Size of the output character array.
 * @noreturn
 */
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

/**
 * Reads the given boolean array containing values for each team from
 * a character array.
 *
 * @note            Decodes '1' as 'true', and '0' as 'false'.
 * @param array     Output boolean array.
 * @param src       Input character array.
 * @noreturn
 */
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

/**
 * Writes the given weapon array containing values for each team / loadout
 * to a character array.
 *
 * @note            Encodes values as a semi-colon delimited list of integers.
 * @param array     Input weapon array.
 * @param dest      Output character array.
 * @param maxLength Size of the output character array.
 * @noreturn
 */
void EncodeWeapons( CSWeapon array[TEAM_COUNT][RTLoadout], char[] dest, int maxLength )
{
    char buffer[8];

    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(RTLoadout); ++loadout )
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

/**
 * Reads the given weapon array containing values for each team / loadout
 * from a character array.
 *
 * @note            Decodes values from a semi-colon delimited list of integers.
 * @param array     Output weapon array.
 * @param src       Input character array.
 * @noreturn
 */
void DecodeWeapons( CSWeapon array[TEAM_COUNT][RTLoadout], char[] src )
{
    char buffer[8];

    int length = strlen(src);
    int index = 0;
    for ( int loadout = 0; loadout < view_as<int>(RTLoadout); ++loadout )
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
