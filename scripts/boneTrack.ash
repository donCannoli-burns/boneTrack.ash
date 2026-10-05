script "boneTrack.ash"
notify "donCannoli"

// color thresholds
int trigger_MallPrice_High    = 15000000;
int trigger_MallPrice_Low     =  3000000;
int trigger_MeatPerBone_High  =    10000;
int trigger_MeatPerBone_Low   =     1000;
int trigger_ValuePerBone_High =       15;
int trigger_ValuePerBone_Low  =        7;

int ownedAmount(item x) {
	return item_amount(x) + closet_amount(x) + storage_amount(x) + display_amount(x) + equipped_amount(x);
}

boolean OwnDailySpecial(item x) {
	return ownedAmount(x) > 0;
}

// ask once if wiki should auto-launch, store as pref
void initWikiSetting() {
	if (get_property(`boneTrackEnableWiki`) != "")
		return;
	string prompt = `Enable auto-launch of KoL Wiki\'s SoCP Daily Special page?\n` +
				`Note: after inital setup, reset this with CLI:\n` +
				`"set boneTrackEnableWiki = [false|true]"`;
	set_property("boneTrackEnableWiki", user_confirm(prompt));
	if (get_property(`boneTrackEnableWiki`) == "true") {
		print(`Setting AutoLaunch [ON]`, `green`);
		print(`"set boneTrackEnableWiki=false" to turn off wiki autolaunch.`, `navy`);
	}
	else {
		print(`Setting AutoLaunch [OFF]`, `orange`);
		print(`"set boneTrackEnableWiki=true" to turn on wiki autolaunch.`, `navy`);
	}
}

// raw and computed values
record BoneStats {
	item    dailySpecial;
	boolean tradable;
	boolean yesBuy_Special;
	int     lifeNum;
	int     buy_special;
	int     item_number;
	int     specialMallPrice;
	int     specialBonePrice;
	int     DSowned;
	int     currentTotalBones;
	int     collectedBones;
	int     collectedRestBones;
	int     totalBonesCollected; // adv bones only
	int     allBonesCollected; // adv + rest
	float   meatPerBone;
	float   DS_Value;
	string  leg_num;
	string  daily_Special;
};

BoneStats gatherStats() {
	BoneStats s;
	item kb = $item[knucklebone];
	s.dailySpecial      = get_property("_crimboPastDailySpecialItem").to_item();
	s.tradable          = is_tradeable(s.dailySpecial);
	s.yesBuy_Special    = get_property("_crimboPastDailySpecial").to_boolean();
	s.lifeNum           = get_property("ascensionsToday").to_int();
	s.buy_special       = s.yesBuy_Special.to_int();
	s.item_number       = get_property("_crimboPastDailySpecialItem").to_int();
	s.specialMallPrice  = mall_price(s.dailySpecial);
	s.specialBonePrice  = get_property("_crimboPastDailySpecialPrice").to_int();
	s.DSowned           = ownedAmount(s.dailySpecial);
	s.currentTotalBones = ownedAmount(kb);
	s.collectedBones     = get_property("_knuckleboneDrops").to_int();
	s.collectedRestBones = get_property("_knuckleboneRests").to_int();
	s.totalBonesCollected = s.collectedBones - s.collectedRestBones;
	s.allBonesCollected   = s.collectedBones;
	s.meatPerBone = (s.specialBonePrice > 0)
		? to_int(s.specialMallPrice / s.specialBonePrice)
		: 0;
	// Preserve the original VPB calculation, but use normal arithmetic
	// and avoid dividing by zero when no usable mall value exists.
	s.DS_Value = (s.meatPerBone > 0)
		? (s.specialMallPrice / (s.meatPerBone + 1.0)) / 100.0
		: 0;
	s.leg_num           = "Leg" + (s.lifeNum + 1);
	s.daily_Special     = s.item_number.to_item();
	return s;
}

void updateMetricLog(string path, string key, float value) {
	string[string] data;
	file_to_map(path, data);
	data[key] = value;
	map_to_file(data, path);
}

// file logging daily-special snapshot and rolling MPB/VPB
void logDailyData(BoneStats s) {
	string base = "/boneTrack/" + my_name();
	string[string] boneData;
	boneData["1. " + s.dailySpecial + " Bone Price:"]  = s.specialBonePrice;
	boneData["2. " + s.dailySpecial + " Mall Price:"]  = s.specialMallPrice;
	boneData["3. Total Inventory Knucklebones:"]       = s.currentTotalBones;
	boneData["4. Meat/Per/Knucklebone:"]               = s.meatPerBone;
	boneData["5. Value/Per/Knucklebone:"]              = s.DS_Value;
	boneData["6. Daily Collected Knucklebone:"]        = s.allBonesCollected;
	boneData["7. #/of Daily-Special Owned:"]           = s.DSowned;
	boneData["8. #/of Daily-Special Buy w/Bones:"]     = s.buy_special;
	map_to_file(boneData, `{base}/DailySpecial Tracking/{s.daily_Special}_{s.item_number}/{today_to_string()}_{s.leg_num}.txt`);

	// purchase log (only when we actually bought with bones today)
	if (s.yesBuy_Special) {
		string buyPath = base + "/BoneValue Tracking/BUY.txt";
		string[string] boneBuyData;
		file_to_map(buyPath, boneBuyData);
		boneBuyData[today_to_string() + "_" + s.item_number + " Purchased: Qty[" + s.buy_special + "] For"] = s.specialBonePrice + " Knucklebones.";
		boneBuyData[today_to_string() + "_" + s.item_number + " Owned: Qty[" + s.DSowned + "] Mall Price:"] = s.specialMallPrice;
		map_to_file(boneBuyData, buyPath);
	}

	// rolling meat-per-bone / value-per-bone logs
	string metricKey = today_to_string() + "_" + s.item_number;
	updateMetricLog(base + "/BoneValue Tracking/MPB.txt", metricKey + " MPB:", s.meatPerBone);
	updateMetricLog(base + "/BoneValue Tracking/VPB.txt", metricKey + " VPB:", s.DS_Value);
}


// compute historical averages
record Averages {
	float vpb;
	float mpb;
};

float averageFromFile(string path, string label) {
	float total = 0;
	int count = 0;
	float[string] data;
	file_to_map(path, data);

	foreach key, value in data {
		total += value;
		count++;
	}

	if (count == 0) {
		print("No " + label + " data found.");
		return 0;
	}

	return total / count;
}

Averages computeAverages() {
	string base = "/boneTrack/" + my_name() + "/BoneValue Tracking/";
	Averages avg;
	avg.vpb = averageFromFile(base + "VPB.txt", "VPB");
	avg.mpb = averageFromFile(base + "MPB.txt", "MPB");
	return avg;
}

// print colorful CLI
void printReport(BoneStats s, float averageVPB, float averageMPB) {
	string bar  = `|= == == == == == == = | > KNUCKLEBONE DAILY BREAKDOWN < |= == == == == == == |`;
	string div  = `-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --`;
	string foot = `|= == == == == == == == == == == == == == == == == == == == == == == == == == == = |`;
	// header
	print(bar, 'navy');
	print(div, 'orange');
	// bone inventory & daily collection
	print(`> Total Knucklebones in Inventory: [{s.currentTotalBones}]`, 'navy');
	print(`> Daily Knucklebone Collection:`, 'navy');
	print(`>   "Adv-Bones"  : [{s.totalBonesCollected}/ 95]`, 'navy');
	print(`>   "Rest-Bones" : [{s.collectedRestBones}/ 5]`,  'navy');
	string collectedMsg = `> [{s.allBonesCollected}/ 100] Knucklebones Collected For The Day.`;
	print(collectedMsg, (s.allBonesCollected == 100) ? 'green' : 'red');
	print(div, 'orange');
	// affordability
	print(`> The Daily Special Is: [{s.daily_Special}].`, 'navy');
	print(`> Knucklebone Price Of: [{s.specialBonePrice}] Knucklebones.`, 'navy');
	boolean canAfford = s.specialBonePrice > 0 && s.currentTotalBones >= s.specialBonePrice;
	string affordMsg = `> You [CAN{canAfford ? "" : "NOT"}] Afford The Daily Special: ${s.daily_Special}!`;
	print(affordMsg, canAfford ? 'green' : 'red');
	print(div, 'orange');
	// value metrics
	if (s.tradable) {
		string mallMsg = `> Mall Price Of: [{s.specialMallPrice}] Meat.`;
		string mpbMsg = `> That\'s A Return Of: [{s.meatPerBone}] Meat/Per/Knucklebone!`;
		string vpbMsg = `> A Value Of [{to_string(s.DS_Value, "%.3f")}%] Per/Knucklebone.` +
						`(SpecialMallPrice / MeatPerBone) / 100`;
		// mall price colour
		if (s.specialMallPrice > trigger_MallPrice_High)
			print(mallMsg, 'green');
		else if (s.specialMallPrice < trigger_MallPrice_Low)
			print(mallMsg, 'red');
		else
			print(mallMsg, 'navy');
		// meat-per-bone colour
		if (s.meatPerBone > trigger_MeatPerBone_High)
			print(mpbMsg, 'green');
		else if (s.meatPerBone < trigger_MeatPerBone_Low)
			print(mpbMsg, 'red');
		else
			print(mpbMsg, 'navy');
		// value-per-bone colour
		if (s.DS_Value > trigger_ValuePerBone_High)
			print(vpbMsg, 'green');
		else if (s.DS_Value < trigger_ValuePerBone_Low)
			print(vpbMsg, 'red');
		else
			print(vpbMsg, 'navy');
	}
	else
		print(`> {s.daily_Special} is Not Tradable.`, 'navy');
	print(div, 'orange');
	// ownership & purchase
	string ownMsg = `> We Own [{s.DSowned}] {s.daily_Special}`;
	print(ownMsg, OwnDailySpecial(s.dailySpecial) ? 'green' : 'red');
	print(`> We {(s.yesBuy_Special) ? "[HAVE]" : "[HAVE NOT]"} Purchased {s.daily_Special} With Knucklebones.`,
		s.yesBuy_Special ? 'green' : 'red');
	print(div, 'orange');
	// historical averages
	print(`> As of: [{today_to_string()}]`, 'navy');
	print(`> Average "Daily Special" Meat / Per / Knucklebone : [{to_string(averageMPB, "%.3f")}]`, 'navy');
	print(`> Average "Daily Special" Value / Per / Knucklebone: [{to_string(averageVPB, "%.3f")}]`, 'navy');
	print(div, 'orange');
	print(foot, 'navy');
}

// optional wiki launcher
void maybeOpenWiki(string daily_Special) {
	if (get_property("boneTrackEnableWiki").to_boolean())
		cli_execute(`lookup ` + daily_Special);
}

void main() {
	initWikiSetting();
	BoneStats s = gatherStats();
	logDailyData(s);
	Averages avg = computeAverages();
	printReport(s, avg.vpb, avg.mpb);
	maybeOpenWiki(s.daily_Special);
}
