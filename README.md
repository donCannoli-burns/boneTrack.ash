# boneTrack.ash — retirement notice

> **Retiring standalone repository (October 30, 2026).** The maintained `boneTrack.ash` tracker and `relay_BoneTrack.ash` dashboard are now provided by [don_custom_functions](https://github.com/donCannoli-burns/don_custom_functions), with shared ASH helpers in [don-ash-lib](https://github.com/donCannoli-burns/don-ash-lib). Use those repositories for new installs and further development.
>
> The standalone project is preserved as legacy documentation while consolidation into [Retired-KOL-Scripts](https://github.com/donCannoli-burns/Retired-KOL-Scripts) is **planned in approximately 30 days (late November 2026)**. The move has **not** happened yet.

**Migration:** back up `data/boneTrack/` and locally modified scripts. Update/install the two maintained repositories, verify `boneTrack.ash` and `relay_BoneTrack.ash`, and only then consider deleting the redundant old Git checkout. Do **not** remove historical player tracking data. Both checkouts install the same script name, so avoid source ownership conflicts. See the [maintained migration details](https://github.com/donCannoli-burns/don_custom_functions#official-bonefarm--bonetrack-absorption-2026-10-29).

The original README follows for historical reference.

---

> 📂: `"boneTrack.ash"`  
> A data parsing script for KOL Mafia.\
> Purpose: Eaiser Management of "The Skeleton of Crimbo Past"

# :dagger: <sub>"<ins> _boneTrack.ash_ </ins>"</sub><br/> 
&#10240; 🔹 Tracks and Displays, *via* CLI.<br/>
&#10240; 🔹 Knucklebone Daily Count and Progression.<br/>
&#10240; 🔹 "*Value Data*" of the Daily-Special and Knucklebone.<br/>
&#10240; 🔹 Records all the Collected Data in `KOL/data/boneTrack`<br/>
## &#10240; &#10240;  <sub>🔹<ins>_Tracks, Records, And Displays The Following_</ins>🔹</sub>
  | ` 🔹        Daily Variables        🔹 ` | ` 🔹     Value     🔹 ` |
  | :---:                |      :---:      |
  | The Skeleton of Crimbo Past | -*Daily-Special* *Item*- |
  | ` 🔹       Daily-Special Item       🔹 ` | ` 🔹     -📈-     🔹 ` |
  | Item | -#️⃣- |
  | If Owned | -*Qty*- |
  | Store| -*Price*<sup>🦴</sup>- |
  | If Purchased From SoCP | -*Qty*- |
  | *Tradeable* | *true* / *false* | 
  | Mall | -*Price*<sup>🥩</sup>- | 
  |  Meat Per Bone | -🥩➗🦴-
  |  Value Per Bone % | -🦴 / 🥩-|
  |` 🔹 Daily Knucklebone Progression 🔹 `|` 🔹     -📓-     🔹 `|
  | 📋 | -*Total* <sup>🦴</sup> *in Inv*-|
  | ✔️ | -*Collected* <sup>🦴</sup>-|
  | ❌ | -*Needed* <sup>🦴</sup>- | 
  | ` 🔹           Life-Time           🔹 `|` 🔹 Daily-Special 🔹 `|
  | Average MpB | -🥩➗🦴-     |
  | Average VpB | -🦴 / 🥩-      | 
  | Daily-Special Purchased | -*Qty*-      |

&#10240;

>[!NOTE]
> 🔹 *"Average" meat per bone and value per bone is generated from
> the Daily-Special items **YOU** have logged with boneTrack.
> It will take a while to reflect a true MPB/VPB number/value.* <br/>
>
> 🔹 *While script does not currently, combine legs after ascending, into a single data set.<br/>
> It does log an additional data sheet, notated buy leg number.*

&#10240;



![Example Image](img/BTimg.png)
      

&#10240;
## :dagger: <ins>Installation / Uninstallation</ins><br/>
 &#10240; 🔹 To install, run the following on the gCLI:
 >     git checkout https://github.com/donCannoli-burns/boneTrack.ash.git
 &#10240; 🔹 To uninstall, run the following on the gCLI:
 >     git delete https://github.com/donCannoli-burns/boneTrack.ash.git
 &#10240; 🔹 To start the script, run the following on the gCLI:
 >      boneTrack

## :bar_chart: <ins>Relay Dashboard</ins><br/>
&#10240; 🔹 Open KoLmafia's Relay Browser.<br/>
&#10240; 🔹 In the top `-run script-` menu, choose **BoneTrack**.<br/>
&#10240; 🔹 The dashboard is read-only and displays the existing `data/boneTrack/<player>/` tracking files.<br/>
&#10240; 🔹 It shows the current daily snapshot, purchase history, MPB history, VPB history, and rolling averages.<br/>
&#10240; 🔹 Use **Refresh data** on the dashboard to reload the files from disk.<br/>

&#10240;
&#10240;

## :bell: <ins>Enable Or Disable Wiki Auto-Launch.</ins><br/>
&#10240; :small_blue_diamond: A one-time prompt apperars to Disable or Enable the Wiki Auto-Launch<br/>
&#10240; &#10240; :small_blue_diamond: To manually change Wiki Auto-Launch settings, run the following on the gCLI:
>       set boneTrackEnableWiki = [false|true]
&#10240;
&#10240; &#10240; :small_blue_diamond: To reset Wiki Auto-Launch prompt , run the following on the gCLI: 
>       set boneTrackEnableWiki =" "
&#10240;
&#10240;

>[!NOTE]
> 🔊  Shout-Out To: _Prusias_, _The Dictator_, and _Thoth19_.<br/>
>> *Their work in [ploop](https://github.com/Prusias-kol/pLooper.git) and* [ptrack](https://github.com/Prusias-kol/pTrack)<br/>
>> *Gave me the inspiration and references to make this script*<br/>
>     
> 🔊  Shout-Out To: [_Damian Domino Davis_](https://github.com/DamianDominoDavis)<br/>
>> *For their time and insite, streamling the code.*<br/>
> *Many thanks!*

&#10240;
&#10240;


> " *This is my first ever script any feedback/constuctive criticism is greatly welcomed.<br/>
> Thank for checking it out, enjoy!"<br/>
> ---- donC*
