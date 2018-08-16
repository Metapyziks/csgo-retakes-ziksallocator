/**
 * Total number of weapon allocator loadout types.
 */
#define LOADOUT_COUNT 4

/**
 * Weapon allocator loadout types.
 */
enum RTLoadout
{
    LOADOUT_PISTOL, /**< Pistol round loadout. */
    LOADOUT_FORCE,	/**< Force-buy round loadout. */
    LOADOUT_FULL,	/**< Full-buy round loadout. */
    LOADOUT_SNIPER, /**< AWP round loadout. */
    LOADOUT_RANDOM  /**< Round where everyone has the same random weapon. */
}

/**
 * Total number of AWP round boolean flags.
 */
#define SNIPER_FLAG_COUNT 3

/**
 * Enumeration of boolean flags that a client can
 * set related to AWP rounds.
 */
enum RTSniperFlag
{
    SNIPER_ENABLED,     /**< Opt-in to AWP rounds. */
    SNIPER_SOMETIMES,   /**< Never get AWP rounds twice in a row. */
    SNIPER_NEVERALONE   /**< Never get AWP rounds when alone on a team. */
}

/**
 * Weapon selection menu categories.
 */
enum CSWeaponCategory
{
    WCAT_PISTOL,        /**< Sidearms. */
    WCAT_SMG,           /**< Submachine guns. */
    WCAT_HEAVY,         /**< Shotguns and light machine guns. */
    WCAT_RIFLE,         /**< Assault and sniper rifles. */
    WCAT_UNKNOWN = -1   /**< Unknown. */
}

/**
 * Enumeration of all weapons available in the menu.
 * Weapons in the same category are contiguous.
 */
enum CSWeapon
{
    WEAPON_NONE,        /**< No weapon. */

    WEAPON_GLOCK,       /**< Glock. */
    WEAPON_HKP2000,     /**< P2000 / USP-S. */
    WEAPON_P250,        /**< P250. */
    WEAPON_ELITE,       /**< Dual Barettas. */
    WEAPON_TEC9,        /**< Tec-9. */
    WEAPON_FIVESEVEN,   /**< Five-SeveN. */
    WEAPON_CZ75A,       /**< CZ75-Auto. */
    WEAPON_DEAGLE,      /**< Desert Eagle. */
    WEAPON_REVOLVER,    /**< R8 Revolver. */

    WEAPON_MAC10,       /**< MAC-10 */
    WEAPON_MP9,         /**< MP9 */
    WEAPON_UMP45,       /**< UMP-45 */
    WEAPON_BIZON,       /**< PP-Bizon */
    WEAPON_MP7,         /**< MP7 */
    WEAPON_MP5SD,       /**< MP5-SD */
    WEAPON_P90,         /**< P90 */

    WEAPON_NOVA,        /**< Nova. */
    WEAPON_XM1014,      /**< XM1014. */
    WEAPON_SAWEDOFF,    /**< Sawedoff Shotgun. */
    WEAPON_MAG7,        /**< MAG-7. */
    WEAPON_M249,        /**< M249. */
    WEAPON_NEGEV,       /**< Negev. */

    WEAPON_GALILAR,         /**< Galil AR. */
    WEAPON_FAMAS,           /**< FAMAS. */
    WEAPON_SSG08,           /**< SSG 08. */
    WEAPON_AK47,            /**< AK-47. */
    WEAPON_M4A1,            /**< M4A4. */
    WEAPON_M4A1_SILENCER,   /**< M4A1-S. */
    WEAPON_SG556,           /**< SG 553. */
    WEAPON_AUG,             /**< AUG. */
    WEAPON_AWP,             /**< AWP. */
    WEAPON_G3SG1,           /**< G3SG1. */
    WEAPON_SCAR20           /**< SCAR-20. */
}
