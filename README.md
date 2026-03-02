# boneTrack.ash
## A Script for KOL Mafia. 
##  Used to Better Manage Knucklebones from "Skeleton of Crimbo Past".
- Tracks, Records, and Displays, via CLI, the "Value Data" of the *Daily-Special* and *Knucklebone*.
- Logs All the Collected Data in KOL/data/boneTrack.
## Tracks, Records, and Displays:
- The [ *Daily-Special* ] from the Skeleton of Crimbo Past.<br/>
- Daily *Knucklebone* Progression:
>- [ *Total* ] *KBone* **in Invty &** [ *Collected* ] *KBone* **&** [ *Needed* ] *KBone*.
## boneTrack Also Records:
- *Daily-Special* [ *Item Number* ]
- *Knucklebone* Store [ *Price* ]
- If *Daily-Special* [ is / isNot ] Tradeable.
- *Daily-Special* [ *Mall Price* ]
- If You Already Own *Daily-Special* and [ *Qty* ] 
- *Daily-Special* [ *"Meat Per Bone" & "Value Per Bone"* ]. 
- *Daily-Special* [ *Item Number* ]
- If You Purchased [ *Qty* ] of *Daily-Special* from "Skeleton of Crimbo Past".<br/>
- Running "Average" of all *Daily-Special* [ *"Meat Per Bone" & "Value Per Bone"* ].
>- **NOTE:**
>>- "Average" meat per bone and value per bone is generated from
>>- the *Daily-Special* items **YOU** have logged with boneTrack.
>>- It will take a while to reflect a true *MPB/VPB* *number/value*.



![Example Image](img/BTimg.png)
      



## To Install the Script, Use the Following Command in the KoLMafia CLI:<br/>
>      git checkout donCannoli-burns/boneTrack.ash
### To Run the Script Just Type "boneTrack" into Mafia's CLI.<br/>

## You Will Receive a One-Time Prompt, to Enable or Disable the Wiki Auto-Launch.<br/>
### To [disable|enable] Wiki Auto-Launch Use:
>       set boneTrackEnableWiki = [false|true]
### To Reset Wiki Auto-Launch Prompt Use: 
>       set boneTrackEnableWiki =" "
- **NOTE:**
>>- While script does not currently, combine legs after ascending, into a single data set.<br/>
>>- It does log an additional data sheet, notated buy leg number.

*Shout-out to: Prusias,The Dictator, and Thoth19.<br/>
Their work in ploop and ptrack gave me the inspiration and the references to make this script.
Additional shout-out to Damian Domino Davis for their time/insite, helping me streamline the code.
Many thanks!*

This is my first ever script any feedback/constuctive criticism is greatly welcomed.<br/>
Thank for checking it out, enjoy!<br/>
---- *donC*
