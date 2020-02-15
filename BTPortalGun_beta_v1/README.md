# BTPortalGun by OwYeaW

This README was added by Dizzy to list some known issues.

## Description

This Portal gun for Unreal Tournament 99 was created by UT BunnyTrack player OwYeaW in 2019. It was his first major programming (and UScript) project.

* The gun fires two portals which act like paired teleporters. 
* Portals can transport:
  * The player
  * Other actors including monsters
  * Projectiles (excluding traced beams such as Instagib)
  * Decoration objects (e.g. boxes)
* Portals can be attached to movers.
* Portals can be permanently placed (pre-set) in a map within Unreal Editor.
* Portals can be destroyed by the player moving into a zone or passing a trigger/sheet/zone.
* Portals attached to movers can be destroyed if the mover passes through a trigger/sheet/zone.

For examples of all of the above, see OwYeaW's BT maps which I will also include in this repository:
1. CTF-BT-PortalGun_beta5
2. CTF-BT-PortalGunMap1-v2

## Known Issues
1. When picking up or switching to the Portal gun, if you attempt to fire or alt fire too quickly, firing will stop working properly. The workaround is to wait until the pickup animation has stopped playing before firing. This may be an online-only issue.
2. Occasionally when entering a portal the player can be ejected backwards through the same portal.
3. The mod is impressively stable but very occasional crashes may occur.

## Thanks

Thanks to OwYeaW and all those who helped him create this impressive mod.
