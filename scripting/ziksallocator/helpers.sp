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
 * Gets the index into an array storing values for each
 * team/loadout of the value corresponding to the given
 * team and loadout.
 *
 * @param team      Team to get the index of.
 * @param loadout   Loadout to get the index of.
 * @return          Index corresponding to the given
 *                  team and loadout.
 */
int GetTeamLoadoutIndex( int team, RTLoadout loadout )
{
    return GetTeamIndex( team ) + view_as<int>(loadout) * TEAM_COUNT;
}

/**
 * Gets the index into an array storing values for each
 * team/sniper flag of the value corresponding to the given
 * team and sniper flag.
 *
 * @param team      Team to get the index of.
 * @param flag      Sniper flag to get the index of.
 * @return          Index corresponding to the given
 *                  team and sniper flag.
 */
int GetTeamSniperFlagIndex( int team, RTSniperFlag flag )
{
    return GetTeamIndex( team ) + view_as<int>(flag) * TEAM_COUNT;
}

bool IsClientValidAndInGame( int client )
{
    return client > 0 && client <= MaxClients && !IsFakeClient( client ) && IsClientInGame( client );
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

int FloatToStringFixedPoint( float value, int fractionalDigits, char[] buffer, int maxLength )
{
    if ( fractionalDigits == 0 )
    {
        return IntToString( RoundFloat( value ), buffer, maxLength );
    }

    int scale = RoundFloat( Pow( 10.0, fractionalDigits * 1.0 ) );
    int valueInt = view_as<int>( RoundFloat( value * scale ) );

    int offset = IntToString( valueInt / scale, buffer, maxLength );
    if ( offset >= maxLength - 2 ) return offset;

    buffer[offset++] = '.';

    for ( int i = 0; i < fractionalDigits && offset < maxLength - 1; ++i, ++offset )
    {
        scale /= 10;
        buffer[offset] = '0' + ((valueInt / scale) % 10);
    }

    buffer[offset] = 0;

    return offset;
}

/**
 * Maps values within the range [0, 63] to a single character.
 *
 * @param value     Value to map to a base64 character.
 * @return          Character corresponding to the given value.
 */
char GetBase64Char( int value )
{
    static char lookup[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    return lookup[value];
}

/**
 * Maps a base64 character into the integer value it represents.
 *
 * @param encoded   Base64 character to decode.
 * @return          Integer value of the base64 character.
 */
int GetBase64CharValue( char encoded )
{
    static int lookup[96] =
    { // 0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
/* 2 */  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 62,  0,  0,  0, 63,
/* 3 */ 52, 53, 54, 55, 56, 57, 58, 59, 60, 61,  0,  0,  0,  0,  0,  0,
/* 4 */  0,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
/* 5 */ 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,  0,  0,  0,  0,  0,
/* 6 */  0, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
/* 7 */ 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,  0,  0,  0,  0,  0
    };

    int index = view_as<int>(encoded) - 32;
    return index >= 0 && index < sizeof(lookup) ? lookup[index] : 0;
}

/**
 * Converts 6 booleans read from an array at the given index into
 * a base64 character.
 *
 * @param array     Array containing the values to encode.
 * @param length    Total length of the array, to avoid being OOB.
 * @param start     Start index of the 6 booleans to encode.
 * @return          Base64 character encoded from the read booleans.
 */
char EncodeBase64Char( bool[] array, int length, int start )
{
    int count = length - start;
    if ( count > 6 ) count = 6;

    int value = 0;
    for ( int i = 0; i < count; ++ i )
    {
        if ( array[start + i] ) value |= 1 << i;
    }

    char encoded = GetBase64Char( value );

    // TEMP
    if ( GetBase64CharValue( encoded ) != value )
    {
        LogError( "Incorrect base64 encoding for %i, tell the dev!", value );
    }

    return encoded;
}

/**
 * Decodes a base64 character into 6 bits, which are then written
 * to the given boolean array starting at the given index.
 *
 * @param array     Boolean array to write to.
 * @param length    Length of the array, to avoid being OOB.
 * @param start     First index to write to in the array.
 * @param encoded   Base64 character to decode.
 */
void DecodeBase64Char( bool[] array, int length, int start, char encoded )
{
    int value = GetBase64CharValue( encoded );
    int count = length - start;
    if ( count > 6 ) count = 6;

    for ( int i = 0; i < count; ++ i )
    {
        array[start + i] = ((value >> i) & 1) == 1;
    }
}

/**
 * Encodes the given boolean array into a base64 string, which is
 * then written to the given destination character array.
 *
 * @param array     Boolean array to encode.
 * @param length    Length of the boolean array.
 * @param dest      Destination character array to write to.
 * @param maxLength Length of the destination character array.
 * @return          Number of characters written.
 */
int EncodeBoolArray( bool[] array, int length, char[] dest, int maxLength )
{
    int writeIndex = 0;
    for ( int i = 0; i < length && writeIndex < maxLength - 1; i += 6 )
    {
         dest[writeIndex++] = EncodeBase64Char( array, length, i );
    }

    dest[writeIndex] = 0;
    return writeIndex;
}

/**
 * Decodes the given base64 string into bits, which are then
 * written to the given boolean array.
 * 
 * @param array     Destination boolean array to write to.
 * @param length    Length of the destination boolean array.
 * @param src       Base64 string to decode.
 * @noreturn
 */
void DecodeBoolArray( bool[] array, int length, char[] src )
{
    int srcLen = strlen(src);
    int readIndex = 0;
    for ( int i = 0; i < length && readIndex < srcLen; i += 6 )
    {
        DecodeBase64Char( array, length, i, src[readIndex++] );
    }
}

/**
 * Writes the given weapon array containing values for each team / loadout
 * to a character array.
 *
 * @note            Encodes values as a semi-colon delimited list of integers.
 * @param array     Input weapon array.
 * @param length    Length of the weapon array.
 * @param dest      Output character array.
 * @param maxLength Size of the output character array.
 * @noreturn
 */
void EncodeWeaponArray( CSWeapon[] array, int length, char[] dest, int maxLength )
{
    char buffer[8];

    int index = 0;
    for ( int i = 0; i < length; ++i )
    {
        IntToString( view_as<int>(array[i]), buffer, sizeof(buffer) );

        int numLen = strlen(buffer);
        if ( index + numLen + 2 >= maxLength ) break;

        for ( int c = 0; c < numLen; ++c )
        {
            dest[index++] = buffer[c];
        }

        dest[index++] = ';';
    }
    
    dest[index] = 0;
}

/**
 * Reads the given weapon array containing values for each team / loadout
 * from a character array.
 *
 * @note            Decodes values from a semi-colon delimited list of integers.
 * @param array     Output weapon array.
 * @param length    Length of the weapon array.
 * @param src       Input character array.
 * @noreturn
 */
void DecodeWeaponArray( CSWeapon[] array, int length, char[] src )
{
    char buffer[8];

    int strLength = strlen(src);
    int index = 0;
    for ( int i = 0; i < length; ++i )
    {
        if ( index >= strLength ) return;

        int numLen = 0;
        while ( index < strLength && src[index++] != ';' )
        {
            buffer[numLen++] = src[index - 1];
        }
        buffer[numLen] = 0;

        array[i] = view_as<CSWeapon>(StringToInt( buffer, 10 ));
    }
}
