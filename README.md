#boneTrack.ash
+ A Script for KOL Mafia. 
  Used to Better Manage Knucklebones from Skeleton of Crimbo Past.
  Tracks, Records, and Displays, via CLI, the "Value Data" of the *Daily-Special* and *Knucklebone*.
  Logs All the Collected Data in KOL/data/boneTrack.
+ Tracks, Records, and Displays:
> The *Daily-Special* from the Skeleton of Crimbo Past.<br/>
> Daily *Knucklebone* Progression:
>> Total KBones in Invty, Collected KBones, Needed KBones.

+ boneTrack Also Records:
> *Knucklebone* Price.
> If *Daily-Special* Tradeable.
> Mall Price.
> If You Already Own *Daily-Special*. 
> *Daily-Special* "Meat Per Bone" & "Value Per Bone". 
> *Daily-Special* Item Number.
> If You Purchased *Daily-Special* from SoCP.<br/>
> A Runnning "Average" of all *Daily-Special* "Meat Per Bone" & "Value Per Bone".
>>+ NOTE: "Average" meat per bone and value per bone is generated from the *Daily-Special* items YOU have logged with boneTrack.
>> It will take a while to reflect a true *MPB/VPB* number/value.


![Example Image](img/BTimg.png)
      

- NOTE: While does not currently, combine legs after ascending, to one data set.
- It does log an additional data sheet, notated buy leg#.

+ To install the script, use the following command in the KoLMafia CLI:<br/>
>      git checkout donCannoli-burns/boneTrack.ash
>>To run the script just type boneTrack into Mafia's CLI

+ You will receive a one-time prompt, to enable or disable the Wiki auto-launch.
> To change setting use:
>>       set boneTrackEnableWiki = [false|true]
> To reset use: 
>>       set boneTrackEnableWiki =" "

*Shout-out to: Prusias,The Dictator, and Thoth19.<br/>
Their work in ploop and ptrack gave me the inspiration and the references to make this script.
Additional shout-out to Damian Domino Davis for their time/insite, helping me streamline the code.
Many thanks!*

This is my first ever script any feedback/constuctive criticism is greatly welcomed.<br/>
Thank for checking it out, enjoy!<br/>
---- *donC*
