/**
 * Categories for primary weapons.
 */
CSWeaponCategory g_PrimaryCategories[] = {
    WCAT_SMG,
    WCAT_HEAVY,
    WCAT_RIFLE
};

/**
 * Gets the display name of the given weapon.
 *
 * @param loadout   Weapon to get the name of.
 * @param buffer    Character array to write the name to.
 * @param maxLength Size of the destination character array.
 * @noreturn
 */
void GetWeaponName( CSWeapon weapon, char[] buffer, int maxLength )
{
    switch ( weapon )
    {
        case WEAPON_NONE:      strcopy( buffer, maxLength, "None" );

        case WEAPON_GLOCK:     strcopy( buffer, maxLength, "Glock" );
        case WEAPON_HKP2000:   strcopy( buffer, maxLength, "P2000 / USP-S" );
        case WEAPON_P250:      strcopy( buffer, maxLength, "P250" );
        case WEAPON_ELITE:     strcopy( buffer, maxLength, "Dual Barettas" );
        case WEAPON_TEC9:      strcopy( buffer, maxLength, "Tec-9" );
        case WEAPON_FIVESEVEN: strcopy( buffer, maxLength, "Five-SeveN" );
        case WEAPON_CZ75A:     strcopy( buffer, maxLength, "CZ75 Auto" );
        case WEAPON_DEAGLE:    strcopy( buffer, maxLength, "Desert Eagle" );
        case WEAPON_REVOLVER:  strcopy( buffer, maxLength, "R8 Revolver" );

        case WEAPON_MAC10:     strcopy( buffer, maxLength, "MAC-10" );
        case WEAPON_MP9:       strcopy( buffer, maxLength, "MP9" );
        case WEAPON_UMP45:     strcopy( buffer, maxLength, "UMP-45" );
        case WEAPON_BIZON:     strcopy( buffer, maxLength, "PP-Bizon" );
        case WEAPON_MP7:       strcopy( buffer, maxLength, "MP7" );
        case WEAPON_MP5SD:     strcopy( buffer, maxLength, "MP5-SD" );
        case WEAPON_P90:       strcopy( buffer, maxLength, "P90" );

        case WEAPON_NOVA:      strcopy( buffer, maxLength, "Nova" );
        case WEAPON_SAWEDOFF:  strcopy( buffer, maxLength, "Sawed-Off" );
        case WEAPON_MAG7:      strcopy( buffer, maxLength, "MAG-7" );
        case WEAPON_XM1014:    strcopy( buffer, maxLength, "XM1014" );
        case WEAPON_M249:      strcopy( buffer, maxLength, "M249" );
        case WEAPON_NEGEV:     strcopy( buffer, maxLength, "Negev" );

        case WEAPON_GALILAR:       strcopy( buffer, maxLength, "Galil AR" );
        case WEAPON_FAMAS:         strcopy( buffer, maxLength, "FAMAS" );
        case WEAPON_SSG08:         strcopy( buffer, maxLength, "SSG 08" );
        case WEAPON_AK47:          strcopy( buffer, maxLength, "AK-47" );
        case WEAPON_M4A1:          strcopy( buffer, maxLength, "M4A4" );
        case WEAPON_M4A1_SILENCER: strcopy( buffer, maxLength, "M4A1-S" );
        case WEAPON_SG556:         strcopy( buffer, maxLength, "SG 553" );
        case WEAPON_AUG:           strcopy( buffer, maxLength, "AUG" );
        case WEAPON_AWP:           strcopy( buffer, maxLength, "AWP" );
        case WEAPON_G3SG1:         strcopy( buffer, maxLength, "G3SG1" );
        case WEAPON_SCAR20:        strcopy( buffer, maxLength, "SCAR-20" );
    }

    /*
    char weaponClass[WEAPON_STRING_LENGTH];
    GetWeaponClassName( weapon, weaponClass, sizeof(weaponClass) );

    return CS_GetTranslatedWeaponAlias( weaponClass, buffer, maxLength );
    */
}

/**
 * Gets the class name of the given weapon.
 *
 * @param loadout   Weapon to get the class of.
 * @param buffer    Character array to write the class to.
 * @param maxLength Size of the destination character array.
 * @noreturn
 */
void GetWeaponClassName( CSWeapon weapon, char[] buffer, int maxLength )
{
    switch ( weapon )
    {
        case WEAPON_NONE:      strcopy( buffer, maxLength, "" );

        case WEAPON_GLOCK:     strcopy( buffer, maxLength, "weapon_glock" );
        case WEAPON_HKP2000:   strcopy( buffer, maxLength, "weapon_hkp2000" );
        case WEAPON_P250:      strcopy( buffer, maxLength, "weapon_p250" );
        case WEAPON_ELITE:     strcopy( buffer, maxLength, "weapon_elite" );
        case WEAPON_TEC9:      strcopy( buffer, maxLength, "weapon_tec9" );
        case WEAPON_FIVESEVEN: strcopy( buffer, maxLength, "weapon_fiveseven" );
        case WEAPON_CZ75A:     strcopy( buffer, maxLength, "weapon_cz75a" );
        case WEAPON_DEAGLE:    strcopy( buffer, maxLength, "weapon_deagle" );
        case WEAPON_REVOLVER:  strcopy( buffer, maxLength, "weapon_revolver" );

        case WEAPON_MAC10:     strcopy( buffer, maxLength, "weapon_mac10" );
        case WEAPON_MP9:       strcopy( buffer, maxLength, "weapon_mp9" );
        case WEAPON_UMP45:     strcopy( buffer, maxLength, "weapon_ump45" );
        case WEAPON_BIZON:     strcopy( buffer, maxLength, "weapon_bizon" );
        case WEAPON_MP7:       strcopy( buffer, maxLength, "weapon_mp7" );
        case WEAPON_MP5SD:     strcopy( buffer, maxLength, "weapon_mp5sd" );
        case WEAPON_P90:       strcopy( buffer, maxLength, "weapon_p90" );

        case WEAPON_NOVA:      strcopy( buffer, maxLength, "weapon_nova" );
        case WEAPON_SAWEDOFF:  strcopy( buffer, maxLength, "weapon_sawedoff" );
        case WEAPON_MAG7:      strcopy( buffer, maxLength, "weapon_mag7" );
        case WEAPON_XM1014:    strcopy( buffer, maxLength, "weapon_xm1014" );
        case WEAPON_M249:      strcopy( buffer, maxLength, "weapon_m249" );
        case WEAPON_NEGEV:     strcopy( buffer, maxLength, "weapon_negev" );

        case WEAPON_GALILAR:       strcopy( buffer, maxLength, "weapon_galilar" );
        case WEAPON_FAMAS:         strcopy( buffer, maxLength, "weapon_famas" );
        case WEAPON_SSG08:         strcopy( buffer, maxLength, "weapon_ssg08" );
        case WEAPON_AK47:          strcopy( buffer, maxLength, "weapon_ak47" );
        case WEAPON_M4A1:          strcopy( buffer, maxLength, "weapon_m4a1" );
        case WEAPON_M4A1_SILENCER: strcopy( buffer, maxLength, "weapon_m4a1_silencer" );
        case WEAPON_SG556:         strcopy( buffer, maxLength, "weapon_sg556" );
        case WEAPON_AUG:           strcopy( buffer, maxLength, "weapon_aug" );
        case WEAPON_AWP:           strcopy( buffer, maxLength, "weapon_awp" );
        case WEAPON_G3SG1:         strcopy( buffer, maxLength, "weapon_g3sg1" );
        case WEAPON_SCAR20:        strcopy( buffer, maxLength, "weapon_scar20" );
    }
}

CSWeapon GetWeaponFromEntity( int weapon )
{
    if ( weapon == -1 ) return WEAPON_NONE;
    
    char classname[WEAPON_STRING_LENGTH];
    if ( !GetEntityClassname( weapon, classname, sizeof(classname) ) ) return WEAPON_NONE;

    return GetWeaponFromClassname( classname );
}

CSWeapon GetWeaponFromClassname( char[] classname )
{
    if ( strcmp( classname, "weapon_glock" ) == 0 ) return WEAPON_GLOCK;
    if ( strcmp( classname, "weapon_hkp2000" ) == 0 ) return WEAPON_HKP2000;
    if ( strcmp( classname, "weapon_p250" ) == 0 ) return WEAPON_P250;
    if ( strcmp( classname, "weapon_elite" ) == 0 ) return WEAPON_ELITE;
    if ( strcmp( classname, "weapon_tec9" ) == 0 ) return WEAPON_TEC9;
    if ( strcmp( classname, "weapon_fiveseven" ) == 0 ) return WEAPON_FIVESEVEN;
    if ( strcmp( classname, "weapon_cz75a" ) == 0 ) return WEAPON_CZ75A;
    if ( strcmp( classname, "weapon_deagle" ) == 0 ) return WEAPON_DEAGLE;
    if ( strcmp( classname, "weapon_revolver" ) == 0 ) return WEAPON_REVOLVER;

    if ( strcmp( classname, "weapon_mac10" ) == 0 ) return WEAPON_MAC10;
    if ( strcmp( classname, "weapon_mp9" ) == 0 ) return WEAPON_MP9;
    if ( strcmp( classname, "weapon_ump45" ) == 0 ) return WEAPON_UMP45;
    if ( strcmp( classname, "weapon_bizon" ) == 0 ) return WEAPON_BIZON;
    if ( strcmp( classname, "weapon_mp7" ) == 0 ) return WEAPON_MP7;
    if ( strcmp( classname, "weapon_mp5sd" ) == 0 ) return WEAPON_MP5SD;
    if ( strcmp( classname, "weapon_p90" ) == 0 ) return WEAPON_P90;

    if ( strcmp( classname, "weapon_nova" ) == 0 ) return WEAPON_NOVA;
    if ( strcmp( classname, "weapon_sawedoff" ) == 0 ) return WEAPON_SAWEDOFF;
    if ( strcmp( classname, "weapon_mag7" ) == 0 ) return WEAPON_MAG7;
    if ( strcmp( classname, "weapon_xm1014" ) == 0 ) return WEAPON_XM1014;
    if ( strcmp( classname, "weapon_m249" ) == 0 ) return WEAPON_M249;
    if ( strcmp( classname, "weapon_negev" ) == 0 ) return WEAPON_NEGEV;

    if ( strcmp( classname, "weapon_galilar" ) == 0 ) return WEAPON_GALILAR;
    if ( strcmp( classname, "weapon_famas" ) == 0 ) return WEAPON_FAMAS;
    if ( strcmp( classname, "weapon_ssg08" ) == 0 ) return WEAPON_SSG08;
    if ( strcmp( classname, "weapon_ak47" ) == 0 ) return WEAPON_AK47;
    if ( strcmp( classname, "weapon_m4a1" ) == 0 ) return WEAPON_M4A1;
    if ( strcmp( classname, "weapon_m4a1_silencer" ) == 0 ) return WEAPON_M4A1_SILENCER;
    if ( strcmp( classname, "weapon_sg556" ) == 0 ) return WEAPON_SG556;
    if ( strcmp( classname, "weapon_aug" ) == 0 ) return WEAPON_AUG;
    if ( strcmp( classname, "weapon_awp" ) == 0 ) return WEAPON_AWP;
    if ( strcmp( classname, "weapon_g3sg1" ) == 0 ) return WEAPON_G3SG1;
    if ( strcmp( classname, "weapon_scar20" ) == 0 ) return WEAPON_SCAR20;

    return WEAPON_NONE;
}

/**
 * Gets the display name of the given weapon category.
 *
 * @param loadout   Weapon category to get the name of.
 * @param buffer    Character array to write the name to.
 * @param maxLength Size of the destination character array.
 * @noreturn
 */
void GetWeaponCategoryName( CSWeaponCategory category, char[] buffer, int maxLength )
{
    switch ( category )
    {
        case WCAT_PISTOL:  strcopy( buffer, maxLength, "Pistols" );
        case WCAT_SMG:     strcopy( buffer, maxLength, "SMGs" );
        case WCAT_HEAVY:   strcopy( buffer, maxLength, "Heavys" );
        case WCAT_RIFLE:   strcopy( buffer, maxLength, "Rifles" );
        case WCAT_UNKNOWN: strcopy( buffer, maxLength, "Unknown" );
    }
}

/**
 * Gets the weapon category of the given weapon.
 *
 * @param weapon    Weapon to get the category for.
 * @return          Weapon category of the given weapon.
 */
CSWeaponCategory GetWeaponCategory( CSWeapon weapon )
{
    CSWeaponCategory categories[] = {
        WCAT_PISTOL,
        WCAT_SMG,
        WCAT_HEAVY,
        WCAT_RIFLE
    };

    int index = view_as<int>( weapon );

    for ( int i = 0; i < sizeof(categories); ++i )
    {
        CSWeaponCategory category = categories[i];

        if ( index >= GetWeaponListMin( category ) && index <= GetWeaponListMax( category ) )
        {
            return category;
        }
    }

    return WCAT_UNKNOWN;
}

/**
 * Gets the first weapon index of weapons in the given category.
 *
 * @param category  Weapon category to get the first index of.
 * @return          Weapon index of the first weapon in the given category.
 */
int GetWeaponListMin( CSWeaponCategory category )
{
    switch ( category )
    {
        case WCAT_PISTOL: return view_as<int>( WEAPON_GLOCK );
        case WCAT_SMG: return view_as<int>( WEAPON_MAC10 );
        case WCAT_HEAVY: return view_as<int>( WEAPON_NOVA );
        case WCAT_RIFLE: return view_as<int>( WEAPON_GALILAR );
    }

    return -1;
}

/**
 * Gets the last weapon index of weapons in the given category.
 *
 * @param category  Weapon category to get the last index of.
 * @return          Weapon index of the last weapon in the given category.
 */
int GetWeaponListMax( CSWeaponCategory category )
{
    switch ( category )
    {
        case WCAT_PISTOL: return view_as<int>( WEAPON_REVOLVER );
        case WCAT_SMG: return view_as<int>( WEAPON_P90 );
        case WCAT_HEAVY: return view_as<int>( WEAPON_NEGEV );
        case WCAT_RIFLE: return view_as<int>( WEAPON_AUG );
    }

    return -1;
}

/**
 * Gets whether the given client, when on the given team and during loadouts of
 * the given type, can purchase the given weapon.
 *
 * @param client    Client to check for weapon availability.
 * @param team      Team to check for weapon availability.
 * @param loadout   Loadout to check for weapon availability.
 * @param weapon    Weapon to check for availability.
 * @return          True if the given weapon can be purchased.
 */
bool CanBuyWeapon( int client, int team, RTLoadout loadout, CSWeapon weapon )
{
    if ( GetWeaponCost( client, weapon ) > GetStartMoney( loadout ) ) return false;

    switch ( weapon )
    {
        case WEAPON_GLOCK, WEAPON_TEC9, WEAPON_MAC10, WEAPON_SAWEDOFF,
            WEAPON_GALILAR, WEAPON_AK47, WEAPON_SG556, WEAPON_G3SG1:
            return team == CS_TEAM_T;
        case WEAPON_HKP2000, WEAPON_FIVESEVEN, WEAPON_MP9, WEAPON_MAG7,
            WEAPON_FAMAS, WEAPON_M4A1, WEAPON_M4A1_SILENCER, WEAPON_AUG, WEAPON_SCAR20:
            return team == CS_TEAM_CT;
    }

    return true;
}

/**
 * Gets the price of the given weapon when purchased by the given client.
 *
 * @param client    Client to check weapon price for.
 * @param weapon    Weapon to check price for.
 * @return          Weapon price for the given weapon.
 */
int GetWeaponCost( int client, CSWeapon weapon )
{
    switch ( weapon )
    {
        case WEAPON_NONE, WEAPON_GLOCK, WEAPON_HKP2000:
            return 0;
        case WEAPON_P250:
            return 300;
        case WEAPON_ELITE, WEAPON_TEC9, WEAPON_FIVESEVEN, WEAPON_CZ75A:
            return 500;
        case WEAPON_REVOLVER, WEAPON_DEAGLE:
            return 700;

        case WEAPON_MAC10:
            return 1050;
        case WEAPON_MP9:
            return 1250;
        case WEAPON_UMP45:
            return 1200;
        case WEAPON_BIZON:
            return 1400;
        case WEAPON_MP5SD:
            return 1500;
        case WEAPON_MP7:
            return 1700;
        case WEAPON_P90:
            return 2350;

        case WEAPON_NOVA, WEAPON_SAWEDOFF:
            return 1200;
        case WEAPON_MAG7:
            return 1800;
        case WEAPON_XM1014:
            return 2000;
        case WEAPON_M249:
            return 5200;
        case WEAPON_NEGEV:
            return 2000;

        case WEAPON_GALILAR:
            return 2000;
        case WEAPON_FAMAS:
            return 2250;
        case WEAPON_SSG08:
            return 1700;
        case WEAPON_AK47:
            return 2700;
        case WEAPON_M4A1, WEAPON_M4A1_SILENCER:
            return 3100;
        case WEAPON_SG556:
            return 3000;
        case WEAPON_AUG:
            return 3300;
        case WEAPON_AWP:
            return 4750;
        case WEAPON_G3SG1, WEAPON_SCAR20:
            return 5000;
    }

    /*
    char weaponClass[WEAPON_STRING_LENGTH];
    GetWeaponClassName( weapon, weaponClass, sizeof(weaponClass) );

    CSWeaponID weaponId = CS_AliasToWeaponID( weaponClass );
    if ( !CS_IsValidWeaponID( weaponId ) ) return 0;

    return CS_GetWeaponPrice( client, weaponId, true );
    */

    return 0;
}
