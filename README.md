# -TES3MP-summonRestrictor
- TES3MP script that aims to limit the amount of possible summons per player (2 options: general or level based)

## Installation

1. Download the ```main.lua``` and put it in */server/scripts/custom/summonRestrictor*
2. Open ```customScripts.lua``` and add this code on separate line: ```require("custom.summonRestrictor.main")```

## Configurables
- *config.summonLimit (Default: 3)* - if config.levelBased is false this setting will be considered for all players
- *config.levelBased (Default: true)* - limits player's summons by level (level ranges can be manually changed)
- *config.levelBasedStartLimit (Default: 3)* - level based counterpart to config.summonLimit
