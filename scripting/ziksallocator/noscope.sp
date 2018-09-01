bool g_WasNoScoped[MAXPLAYERS+1];
bool g_WasJumpShot[MAXPLAYERS+1];
CSWeapon g_KilledWeapon[MAXPLAYERS+1];

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

void NoScope_OnTakeDamage( int victim,
    int &attacker, int &inflictor,
    float &damage, int &damagetype, int &weaponEnt,
    float damageForce[3], float damagePosition[3], int damagecustom )
{
    g_WasNoScoped[victim] = false;
    g_WasJumpShot[victim] = false;
    g_KilledWeapon[victim] = WEAPON_NONE;

    if ( !IsClientValidAndInGame( attacker ) ) return;

    CSWeapon weapon = GetWeaponFromEntity( weaponEnt );

    bool canNoScope = GetWeaponCanNoScope( weapon );
    bool scoped = GetEntProp( attacker, Prop_Send, "m_bIsScoped" ) != 0;
    bool inAir = !(GetEntityFlags( attacker ) & FL_ONGROUND);
    
    g_WasNoScoped[victim] = canNoScope && !scoped;
    g_WasJumpShot[victim] = weapon != WEAPON_NONE && inAir;
    g_KilledWeapon[victim] = weapon;
}

void NoScope_PlayerDeath( Event event )
{
    int victim = GetClientOfUserId( event.GetInt( "userid" ) );
    if ( !IsClientValidAndInGame( victim ) ) return;

    if ( g_WasNoScoped[victim] || g_WasJumpShot[victim] )
    {
        int attacker = GetClientOfUserId( event.GetInt( "attacker" ) );

        DisplayTrickKillMessage( victim, attacker, g_KilledWeapon[victim], g_WasNoScoped[victim], g_WasJumpShot[victim] );

        bool wasEnemy = GetClientTeam( victim ) != GetClientTeam( attacker );
        if ( wasEnemy )
        {
            int points = g_WasNoScoped[victim] && g_WasJumpShot[victim] ? 3 : 1;
#if defined ZIKS_POINTS
            ZiksPoints_Award( attacker, points );
#endif
        }
    }
}

void DisplayTrickKillMessage( int victim, int attacker, CSWeapon weapon, bool noScope, bool jumpShot )
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

    Oof( victim, (noScope && jumpShot ? 2.0 : 1.0) * (1 + (distance < 5.0 ? 0.0 : (distance - 5) / 20.0)) );

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
    } else if (jumpShot) {
        Format( killType, sizeof(killType), "%t", "JumpShot" );
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
