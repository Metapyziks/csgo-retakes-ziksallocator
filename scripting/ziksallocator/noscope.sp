enum KillFlags
{
    KILLFLAG_NONE = 0,
    KILLFLAG_NOSCOPE = 1,
    KILLFLAG_JUMPSHOT = 2,
    KILLFLAG_HEADSHOT = 4
}

KillFlags g_KillFlags[MAXPLAYERS+1];
CSWeapon g_KilledWeapon[MAXPLAYERS+1];
float g_SinceLastShot[MAXPLAYERS+1];
float g_LastShotTime[MAXPLAYERS+1];

bool GetWeaponCanNoScope( CSWeapon weapon )
{
    switch ( weapon )
    {
        case WEAPON_SSG08: return true;
        case WEAPON_AWP: return true;
        case WEAPON_G3SG1: return true;
        case WEAPON_SCAR20: return true;
    }

    return false;
}

float GetOneTapPeriod()
{
    return 2.0;
}

void NoScope_OnTakeDamage( int victim,
    int &attacker, int &inflictor,
    float &damage, int &damagetype, int &weaponEnt,
    float damageForce[3], float damagePosition[3], int damagecustom )
{
    g_KillFlags[victim] = KILLFLAG_NONE;
    g_KilledWeapon[victim] = WEAPON_NONE;

    if ( !IsClientValidAndInGame( attacker ) ) return;

    CSWeapon weapon = GetWeaponFromEntity( weaponEnt );

    bool canNoScope = GetWeaponCanNoScope( weapon );
    bool scoped = GetEntProp( attacker, Prop_Send, "m_bIsScoped" ) != 0;
    bool inAir = !(GetEntityFlags( attacker ) & FL_ONGROUND);
    
    if ( canNoScope && !scoped )
    {
        g_KillFlags[victim] |= KILLFLAG_NOSCOPE;
    }

    if ( weapon != WEAPON_NONE && inAir )
    {
        g_KillFlags[victim] |= KILLFLAG_JUMPSHOT;
    }

    if ( (damagetype & CS_DMG_HEADSHOT) == CS_DMG_HEADSHOT )
    {
        g_KillFlags[victim] |= KILLFLAG_HEADSHOT;
    }

    g_KilledWeapon[victim] = weapon;
}

void NoScope_ItemEquip( Event event )
{
    int client = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( client ) ) return;

    g_LastShotTime[client] = 0.0;
}

void NoScope_WeaponFire( Event event )
{
    int client = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( client ) ) return;

    char weaponName[64];
    event.GetString( "weapon", weaponName, sizeof(weaponName) );

    CSWeapon weapon = GetWeaponFromClassname( weaponName );
    if ( weapon == WEAPON_NONE ) return;

    float time = GetGameTime();

    g_SinceLastShot[client] = time - g_LastShotTime[client];
    g_LastShotTime[client] = time;
}

void NoScope_PlayerDeath( Event event )
{
    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( victim ) ) return;

    int attacker = GetClientOfUserId( event.GetInt( "attacker" ) );
    if ( !IsClientValidAndInGame( attacker ) ) return;

    float sinceLastShot = g_SinceLastShot[attacker];

    CSWeapon weapon = g_KilledWeapon[victim];

    bool noScope = (g_KillFlags[victim] & KILLFLAG_NOSCOPE) != KILLFLAG_NONE;
    bool jumpShot = (g_KillFlags[victim] & KILLFLAG_JUMPSHOT) != KILLFLAG_NONE;
    bool headShot = (g_KillFlags[victim] & KILLFLAG_HEADSHOT) != KILLFLAG_NONE;
    bool special = NoScope_IsSpecialWeaponKill( weapon );

    Retakes_MessageToAll( "[DEBUG] %f %i %i", sinceLastShot, view_as<int>(g_KillFlags[victim]), view_as<int>(weapon) );

    if ( noScope || jumpShot || headShot && sinceLastShot >= GetOneTapPeriod() || special )
    {
        g_LastShotTime[attacker] = 0.0;

        bool wasEnemy = GetClientTeam( victim ) != GetClientTeam( attacker );
        if ( !wasEnemy ) return;

        DisplayTrickKillMessage( victim, attacker, weapon,
            noScope, jumpShot, headShot );

#if defined ZIKS_POINTS
        int points = g_WasNoScoped[victim] && g_WasJumpShot[victim] ? 3 : 1;
        ZiksPoints_Award( attacker, points );
#endif
    }
}

bool NoScope_IsSpecialWeaponKill( CSWeapon weapon )
{
    switch ( weapon )
    {
        case WEAPON_KNIFE, WEAPON_HEGRENADE, WEAPON_DECOY, WEAPON_SMOKEGRENADE:
            return true;
    }

    return false;
}

void DisplayTrickKillMessage( int victim, int attacker, CSWeapon weapon, bool noScope, bool jumpShot, bool headShot )
{
    float victimPos[3];
    GetClientAbsOrigin( victim, victimPos );

    float posDiff[3];
    GetClientAbsOrigin( attacker, posDiff );

    posDiff[0] -= victimPos[0];
    posDiff[1] -= victimPos[1];
    posDiff[2] -= victimPos[2];

    float distance = SquareRoot(
        posDiff[0] * posDiff[0] +
        posDiff[1] * posDiff[1] +
        posDiff[2] * posDiff[2] ) * 0.01905;

    float oofness = (distance < 5.0 ? 0.0 : (distance - 5) / 40.0) - 0.5;

    bool specialWeapon = NoScope_IsSpecialWeaponKill( weapon );

    if ( specialWeapon ) oofness += 0.5;
    if ( headShot ) oofness += 0.5;
    if ( jumpShot && !specialWeapon ) oofness += 0.5;
    if ( noScope ) oofness += 0.5;

    if ( headShot || jumpShot || noScope || specialWeapon )
    {
        Oof( victim, oofness, 0.5, attacker, distance < 5.0 || specialWeapon );
    }

    char distanceString[32];
    FloatToStringFixedPoint( distance, 1, distanceString, sizeof(distanceString) );

    char attackerName[64];
    char victimName[64];
    
    GetClientName( attacker, attackerName, sizeof(attackerName) );
    GetClientName( victim, victimName, sizeof(victimName) );

    char killType[64];

    if (noScope && jumpShot) {
        Format( killType, sizeof(killType), "%t", "JumpShotNoScoped" );
    } else if (noScope) {
        Format( killType, sizeof(killType), "%t", "NoScoped" );
    } else if (jumpShot && !specialWeapon) {
        Format( killType, sizeof(killType), "%t", "JumpShot" );
    } else if ( headShot ) {
        if ( weapon == WEAPON_DEAGLE ) {
            Format( killType, sizeof(killType), "%t", "OneDeag" );
        } else {
            return;
        }
    } else {
        return;
    }

    char weaponName[64];
    GetWeaponName( weapon, weaponName, sizeof(weaponName) );

    char prefix[4];

    if ( weaponName[0] == 'A' ) prefix = "an";
    else prefix = "a";

    Retakes_MessageToAll( "%t", "SpecialKillMessage",
        attackerName, killType, victimName, prefix, weaponName, distanceString );
}
