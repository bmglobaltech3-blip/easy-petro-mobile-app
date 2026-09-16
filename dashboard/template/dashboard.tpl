<?$mainclass->headercontent();
$totalLocations = count($LOCATIONQRY);
$totalGallons = 0;
$totalTanks = 0;
$totalAlerts = 0;
$productTotals = [];
$locationSummaries = [];

foreach($LOCATIONQRY as $LOCATION){
	$locationId = $LOCATION['sno'];
	$records = !empty($VEEDORARRAY[$locationId]) ? $VEEDORARRAY[$locationId] : [];
	$locationGallons = 0;
	$locationTanks = 0;
	$locationAlerts = !empty($ALARAMARRAY[$locationId]) ? count($ALARAMARRAY[$locationId]) : 0;
	$updatedAt = 'No live update';
	$tanks = [];

	foreach($records as $VEEDORDATA){
		$vxpld = explode('^', $VEEDORDATA);
		$tankid = $vxpld[0];
		$product = $vxpld[1];
		$gallons = (float)$vxpld[2];
		$ullageLive = $vxpld[3];
		$inches = $vxpld[4];
		$deg = $vxpld[5];
		$water = $vxpld[6];
		$recorded = $vxpld[7];
		$color = !empty($FUELCOLOR[$locationId][$tankid]) ? $FUELCOLOR[$locationId][$tankid] : '#079447';
		$capacity = !empty($FUELCAPACITY[$locationId][$tankid]) ? (float)$FUELCAPACITY[$locationId][$tankid] : 0;
		$ullageTarget = isset($FUELULLAGE[$locationId][$tankid]) ? (float)$FUELULLAGE[$locationId][$tankid] : 90;
		$capacityTarget = $capacity ? ($capacity * $ullageTarget / 100) : 0;
		$actualUllage = $capacityTarget ? round($capacityTarget - $gallons) : 0;
		$percent = $capacity ? round(($gallons * 100) / $capacity, 2) : 0;
		$LOWFUEL = isset($FUELLOW[$locationId][$tankid]) ? (float)$FUELLOW[$locationId][$tankid] : 0;
		$LESSFUEL = isset($FUELLESS[$locationId][$tankid]) ? (float)$FUELLESS[$locationId][$tankid] : 0;
		$OVERFUEL = isset($FUELOVER[$locationId][$tankid]) ? (float)$FUELOVER[$locationId][$tankid] : 0;
		$stateClass = 'is-normal';
		if($LOWFUEL && $gallons < $LOWFUEL)$stateClass = 'is-low';
		elseif($LESSFUEL && $gallons < $LESSFUEL)$stateClass = 'is-less';
		elseif($OVERFUEL && $gallons > $OVERFUEL)$stateClass = 'is-over';

		if($updatedAt === 'No live update' && strlen(trim($recorded)))$updatedAt = $recorded;
		$locationGallons += $gallons;
		$locationTanks++;
		$totalGallons += $gallons;
		$totalTanks++;
		if(empty($productTotals[$product]))$productTotals[$product] = ['gallons' => 0, 'color' => $color];
		$productTotals[$product]['gallons'] += $gallons;
		if(empty($productTotals[$product]['color']) && !empty($color))$productTotals[$product]['color'] = $color;

		$tanks[] = [
			'tankid' => $tankid,
			'product' => $product,
			'gallons' => $gallons,
			'ullage_live' => $ullageLive,
			'ullage_target' => $ullageTarget,
			'actual_ullage' => $actualUllage,
			'water' => $water,
			'inches' => $inches,
			'deg' => $deg,
			'capacity' => $capacity,
			'percent' => $percent,
			'color' => $color,
			'state_class' => $stateClass
		];
	}

	$totalAlerts += $locationAlerts;
	$locationSummaries[] = [
		'id' => $locationId,
		'title' => $LOCATION['title'],
		'gallons' => $locationGallons,
		'tank_count' => $locationTanks,
		'alerts' => $locationAlerts,
		'updated_at' => $updatedAt,
		'tanks' => $tanks
	];
}
?>
<style>
.ep-mobile-shell{max-width:430px;margin:0 auto 32px;background:#f5f7fa;color:#20252d;font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Arial,sans-serif;border-radius:24px;box-shadow:0 0 40px rgba(0,0,0,.10);overflow:hidden}
.ep-mobile-shell *{box-sizing:border-box}
.ep-mobile-shell a{text-decoration:none}
.ep-mobile-shell .noprint{display:block}
.ep-mobile-shell .ep-page{padding:18px 14px 100px;background:#f5f7fa}
.ep-mobile-shell .ep-topbar{background:linear-gradient(140deg,#20275f 0%,#363f86 100%);border-radius:22px;padding:18px;color:#fff;box-shadow:0 8px 24px rgba(31,39,95,.10);margin-bottom:14px}
.ep-mobile-shell .ep-topbar-top{display:flex;justify-content:space-between;gap:10px;align-items:flex-start}
.ep-mobile-shell .ep-brand{font-size:11px;font-weight:800;letter-spacing:1px;opacity:.72;text-transform:uppercase}
.ep-mobile-shell .ep-title{font-size:24px;line-height:1.15;margin:8px 0 4px;font-weight:800;letter-spacing:-.5px}
.ep-mobile-shell .ep-subtitle{margin:0;font-size:11px;opacity:.84}
.ep-mobile-shell .ep-chip{display:inline-flex;align-items:center;gap:6px;background:rgba(255,255,255,.14);padding:8px 10px;border-radius:11px;font-size:11px;font-weight:800;white-space:nowrap}
.ep-mobile-shell .ep-toolbar{display:flex;flex-wrap:wrap;gap:8px;margin:0 0 14px}
.ep-mobile-shell .ep-link-btn{border:1px solid #d8dee7;background:#fff;border-radius:11px;padding:9px 12px;color:#344054;font-size:11px;font-weight:800}
.ep-mobile-shell .ep-kpis{display:grid;grid-template-columns:repeat(2,1fr);gap:10px;margin-bottom:16px}
.ep-mobile-shell .ep-kpi{background:#fff;border:1px solid #dfe5ec;border-radius:18px;padding:14px;box-shadow:0 5px 18px rgba(25,35,65,.045)}
.ep-mobile-shell .ep-kpi span{display:block;font-size:10px;font-weight:800;color:#697386;letter-spacing:.7px;text-transform:uppercase}
.ep-mobile-shell .ep-kpi strong{display:block;font-size:21px;font-weight:800;margin-top:8px;letter-spacing:-.3px}
.ep-mobile-shell .ep-section-head{display:flex;justify-content:space-between;align-items:center;gap:10px;margin:18px 2px 10px}
.ep-mobile-shell .ep-section-head h2{margin:0;font-size:15px;font-weight:800}
.ep-mobile-shell .ep-section-note{font-size:10px;color:#697386;font-weight:700}
.ep-mobile-shell .locations-accordion{background:#fff;border:1px solid #dfe5ec;border-radius:18px;overflow:hidden;box-shadow:0 5px 18px rgba(25,35,65,.045)}
.ep-mobile-shell .ep-location-card{border-bottom:1px solid #edf0f4}
.ep-mobile-shell .ep-location-card:last-child{border-bottom:0}
.ep-mobile-shell .ep-location-card summary{list-style:none;cursor:pointer;padding:13px;display:flex;justify-content:space-between;gap:8px;align-items:center}
.ep-mobile-shell .ep-location-card summary::-webkit-details-marker{display:none}
.ep-mobile-shell .summary-left{display:flex;align-items:center;gap:8px;min-width:0}
.ep-mobile-shell .summary-left b{font-size:11px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.ep-mobile-shell .summary-gallons{font-size:10px;color:#697386;font-weight:700;white-space:nowrap}
.ep-mobile-shell .summary-right{font-size:11px;font-weight:900;white-space:nowrap;color:#20275f}
.ep-mobile-shell .status-dot{width:8px;height:8px;border-radius:50%;background:#079447;flex:0 0 8px}
.ep-mobile-shell .status-dot.alert{background:#b42318}
.ep-mobile-shell .chevron{display:inline-block;margin-left:5px;color:#98a2b3;font-size:14px;transition:transform .15s}
.ep-mobile-shell details[open] .chevron{transform:rotate(180deg)}
.ep-mobile-shell .ep-location-body{padding:0 13px 13px}
.ep-mobile-shell .ep-detail-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:8px;margin-bottom:10px}
.ep-mobile-shell .ep-detail-grid div{background:#f7f9fb;border-radius:10px;padding:10px}
.ep-mobile-shell .ep-detail-grid span{display:block;font-size:8px;color:#697386;text-transform:uppercase;font-weight:700;letter-spacing:.4px}
.ep-mobile-shell .ep-detail-grid b{display:block;font-size:11px;margin-top:5px;color:#101828;word-break:break-word}
.ep-mobile-shell .ep-inline-actions{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:10px}
.ep-mobile-shell .ep-action-link{display:inline-flex;align-items:center;justify-content:center;height:34px;padding:0 12px;border-radius:10px;background:#eff4fa;color:#20275f;font-size:11px;font-weight:800}
.ep-mobile-shell .ep-action-link.primary{background:#079447;color:#fff}
.ep-mobile-shell .ep-inventory-list{display:flex;flex-direction:column;gap:10px}
.ep-mobile-shell .ep-tank-row{background:#fff;border:1px solid #e7eaf0;border-radius:16px;padding:12px;box-shadow:0 4px 16px rgba(16,24,40,.035)}
.ep-mobile-shell .ep-tank-row.is-low{border-color:#f4c7c3;background:#fff7f6}
.ep-mobile-shell .ep-tank-row.is-less{border-color:#fde7b1;background:#fffaf0}
.ep-mobile-shell .ep-tank-row.is-over{border-color:#d0d5dd;background:#fcfcfd}
.ep-mobile-shell .ep-tank-top{display:flex;justify-content:space-between;gap:10px;align-items:flex-start}
.ep-mobile-shell .ep-tank-top strong{display:block;font-size:12px}
.ep-mobile-shell .ep-tank-meta{font-size:10px;color:#697386;margin-top:3px}
.ep-mobile-shell .ep-percent{font-size:12px;font-weight:900;white-space:nowrap}
.ep-mobile-shell .ep-progress{height:9px;border-radius:999px;background:#edf0f4;overflow:hidden;margin:10px 0}
.ep-mobile-shell .ep-progress span{display:block;height:100%;border-radius:999px}
.ep-mobile-shell .ep-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}
.ep-mobile-shell .ep-stat{background:#f7f9fb;border-radius:10px;padding:8px}
.ep-mobile-shell .ep-stat label{display:block;font-size:8px;text-transform:uppercase;color:#8a94a5;letter-spacing:.35px}
.ep-mobile-shell .ep-stat b{display:block;font-size:11px;margin-top:3px}
.ep-mobile-shell .ep-empty{background:#fff;border:1px dashed #ccd5df;border-radius:16px;padding:24px 18px;text-align:center;color:#697386;font-size:11px}
.ep-mobile-shell .ep-product-card{background:#fff;border:1px solid #dfe5ec;border-radius:18px;overflow:hidden;box-shadow:0 5px 18px rgba(25,35,65,.045)}
.ep-mobile-shell .ep-product-row{display:flex;justify-content:space-between;align-items:center;padding:12px 13px;border-bottom:1px solid #edf0f4;font-size:11px}
.ep-mobile-shell .ep-product-row:last-child{border-bottom:0}
.ep-mobile-shell .ep-product-row strong{font-size:12px}
.ep-mobile-shell .ep-product-name{display:flex;align-items:center;gap:8px}
.ep-mobile-shell .ep-product-dot{width:8px;height:8px;border-radius:50%;display:inline-block}
.ep-mobile-shell .ep-footer-actions{display:flex;gap:8px;margin-top:16px}
.ep-mobile-shell .ep-footer-actions a{flex:1;display:flex;justify-content:center;align-items:center;height:44px;border-radius:12px;font-size:12px;font-weight:800}
.ep-mobile-shell .ep-print-btn{background:#2b176f;color:#fff}
.ep-mobile-shell .ep-export-btn{background:#fff;color:#20275f;border:1px solid #d8dee7}
.ep-mobile-shell .ep-raw-alerts{margin-top:10px;padding:12px;border-radius:14px;background:#fff7ed;border:1px solid #fed7aa;font-size:11px;color:#7c2d12}
.ep-mobile-shell .ep-raw-alerts > *:first-child{margin-top:0}
.ep-mobile-shell .ep-raw-alerts > *:last-child{margin-bottom:0}
@media(max-width:360px){
	.ep-mobile-shell .ep-kpis,.ep-mobile-shell .ep-detail-grid,.ep-mobile-shell .ep-stats{grid-template-columns:1fr}
}
@media print{
	.ep-mobile-shell{box-shadow:none;border-radius:0;max-width:none}
	.ep-mobile-shell .noprint{display:none!important}
	.ep-mobile-shell .ep-page{padding:0;background:#fff}
}
</style>
<div class="ep-mobile-shell">
	<div class="ep-page" id="sortable">
		<div class="ep-topbar">
			<div class="ep-topbar-top">
				<div>
					<div class="ep-brand">Easy Petro</div>
					<h1 class="ep-title">Business Overview</h1>
					<p class="ep-subtitle">Live tank inventory across <?=$totalLocations;?> active locations</p>
				</div>
				<div class="ep-chip">Today</div>
			</div>
		</div>

		<?if(!strlen($_REQUEST['export'])){?>
		<div class="ep-toolbar noprint">
			<a href="javascript:void(0)" class="expandall ep-link-btn">Expand all</a>
			<a href="javascript:void(0)" class="collapsall ep-link-btn">Collapse all</a>
		</div>
		<?}?>

		<div class="ep-kpis">
			<div class="ep-kpi"><span>Locations</span><strong><?=number_format($totalLocations);?></strong></div>
			<div class="ep-kpi"><span>Tanks</span><strong><?=number_format($totalTanks);?></strong></div>
			<div class="ep-kpi"><span>Gallons</span><strong><?=number_format($totalGallons, 2);?></strong></div>
			<div class="ep-kpi"><span>Alerts</span><strong><?=number_format($totalAlerts);?></strong></div>
		</div>

		<div class="ep-section-head">
			<h2>Location Performance</h2>
			<div class="ep-section-note"><?=$totalLocations;?> locations</div>
		</div>

		<div class="locations-accordion">
		<?foreach($locationSummaries as $index=>$location){?>
			<details class="ep-location-card"<?if($index===0){?> open<?}?>>
				<summary class="expandcolaps" id="<?=$location['id'];?>">
					<span class="summary-left"><span class="status-dot<?if($location['alerts']){?> alert<?}?>"></span><b><?=htmlspecialchars($location['title']);?></b><span class="summary-gallons"><?=number_format($location['gallons'], 2);?> gal</span></span>
					<span class="summary-right"><?=number_format($location['tank_count']);?> tanks <span class="chevron">⌄</span></span>
				</summary>
				<div id="ajxcontent<?=$location['id'];?>" class="reportctn veedortable ep-location-body">
					<div class="ep-detail-grid">
						<div><span>Updated</span><b><span id="dt<?=$location['id'];?>"><?=htmlspecialchars($location['updated_at']);?></span></b></div>
						<div><span>Gallons</span><b><?=number_format($location['gallons'], 2);?></b></div>
						<div><span>Tanks</span><b><?=number_format($location['tank_count']);?></b></div>
						<div><span>Alerts</span><b><?=number_format($location['alerts']);?></b></div>
					</div>
					<?if(!strlen($_REQUEST['export'])){?>
					<div class="ep-inline-actions noprint">
						<a href="?force=y&location=<?=$location['id'];?>" class="ep-action-link primary">Open location</a>
						<?if(!empty($location['tanks'])){?><a href="javascript:void(0)" class="refreshicon ep-action-link" lid="<?=$location['id'];?>">Refresh</a><?}?>
					</div>
					<?}?>

					<?if(!empty($location['tanks'])){?>
					<div class="ep-inventory-list">
						<?foreach($location['tanks'] as $tank){?>
						<div class="ep-tank-row <?=$tank['state_class'];?>">
							<div class="ep-tank-top">
								<div>
									<strong>T<?=$tank['tankid'];?> · <?=htmlspecialchars($tank['product']);?></strong>
									<div class="ep-tank-meta">Capacity <?=number_format($tank['capacity'], 2);?> · Live ullage <?=htmlspecialchars($tank['ullage_live']);?></div>
								</div>
								<div class="ep-percent" style="color:<?=$tank['color'];?>"><?=number_format($tank['percent'], 2);?>%</div>
							</div>
							<div class="ep-progress"><span style="width:<?=min(100, max(0, $tank['percent']));?>%;background:<?=$tank['color'];?>"></span></div>
							<div class="ep-stats">
								<div class="ep-stat"><label>Gallons</label><b><?=number_format($tank['gallons'], 2);?></b></div>
								<div class="ep-stat"><label><?=number_format($tank['ullage_target'], 0);?>% Ullage</label><b><?=number_format($tank['actual_ullage'], 2);?></b></div>
								<div class="ep-stat"><label>Water</label><b><?=htmlspecialchars($tank['water']);?></b></div>
								<div class="ep-stat"><label>Inches</label><b><?=htmlspecialchars($tank['inches']);?></b></div>
								<div class="ep-stat"><label>Deg F</label><b><?=htmlspecialchars($tank['deg']);?></b></div>
								<div class="ep-stat"><label>Status</label><b><?=ucfirst(str_replace('is-','',$tank['state_class']));?></b></div>
							</div>
						</div>
						<?}?>
					</div>
					<?}else{?>
					<div class="ep-empty">No live tank inventory is available for this location yet.</div>
					<?}?>

					<?if(!empty($ALARAM[$location['id']])){?>
					<div class="ep-raw-alerts"><?foreach($ALARAM[$location['id']] as $ALRM){echo $ALRM;}?></div>
					<?}?>
				</div>
			</details>
		<?}?>
		</div>

		<?if(!empty($productTotals)){?>
		<div class="ep-section-head">
			<h2>Fuel Type Totals</h2>
			<div class="ep-section-note">Current gallons</div>
		</div>
		<div class="ep-product-card">
			<?foreach($productTotals as $productName=>$productData){?>
			<div class="ep-product-row">
				<span class="ep-product-name"><i class="ep-product-dot" style="background:<?=$productData['color'];?>"></i><?=htmlspecialchars($productName);?></span>
				<strong><?=number_format($productData['gallons'], 2);?> gal</strong>
			</div>
			<?}?>
		</div>
		<?}?>

		<?if(!strlen($_REQUEST['export'])){?>
		<div class="ep-footer-actions noprint">
			<a href="javascript:void(0);" onclick="triggerDashboardPrint('sortable');" class="ep-print-btn"><i class="fa fa-print"></i>&nbsp;Print</a>
			<a href="?export=y" class="ep-export-btn"><i class="fa fa-file-excel-o"></i>&nbsp;Export</a>
		</div>
		<?}?>
	</div>
</div>
<script>
(function(){
	var expandAll = document.querySelector('.expandall');
	var collapseAll = document.querySelector('.collapsall');
	if(expandAll){
		expandAll.addEventListener('click', function(){
			document.querySelectorAll('.ep-location-card').forEach(function(card){ card.open = true; });
		});
	}
	if(collapseAll){
		collapseAll.addEventListener('click', function(){
			document.querySelectorAll('.ep-location-card').forEach(function(card){ card.open = false; });
		});
	}
})();
function triggerDashboardPrint(id){
	if(typeof printreport === 'function'){
		printreport(id);
		return;
	}
	window.print();
}
</script>
<?$mainclass->footercontent($footercontent);?>
