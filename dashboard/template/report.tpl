<?$mainclass->headercontent();
if(!function_exists('ep_render_alert_html')){
	function ep_render_alert_html($html){
		$html = str_ireplace(array('<br />', '<br/>', '<br>'), '<br>', $html);
		$html = strip_tags($html, '<a><br><strong><b><em><i><ul><ol><li><p><small>');
		$html = preg_replace_callback('/<a\b[^>]*href=(["\']?)([^"\'>\s]+)\\1[^>]*>/i', function($matches){
			$href = $matches[2];
			if(!(preg_match('/^(https?:|mailto:|#)/i', $href) || preg_match('/^\\/(?!\\/)/', $href)))$href = '#';
			return '<a href="'.htmlspecialchars($href, ENT_QUOTES).'" target="_blank" rel="noopener noreferrer">';
		}, $html);
		$html = preg_replace('/<a\b(?![^>]*href=)[^>]*>/i', '<a href="#">', $html);
		$html = preg_replace('/<(strong|b|em|i|ul|ol|li|p|small)\b[^>]*>/i', '<$1>', $html);
		$html = preg_replace('/<br\b[^>]*>/i', '<br>', $html);
		return $html;
	}
}
$locationid = !empty($_REQUEST['location']) ? $_REQUEST['location'] : '';
$inventoryRows = [];
$inventoryUpdatedAt = 'No live update';
$inventoryGallons = 0;
$locationAlertRows = [];

if(!empty($QRY)){
	foreach($QRY as $ROWS){
		$locationid = $ROWS->locationid;
		$color = !empty($FUELCOLOR[$ROWS->locationid][$ROWS->tankid]) ? $FUELCOLOR[$ROWS->locationid][$ROWS->tankid] : '#079447';
		$capacity = !empty($FUELCAPACITY[$ROWS->locationid][$ROWS->tankid]) ? (float)$FUELCAPACITY[$ROWS->locationid][$ROWS->tankid] : 0;
		$LESSFUEL = isset($FUELLESS[$ROWS->locationid][$ROWS->tankid]) ? (float)$FUELLESS[$ROWS->locationid][$ROWS->tankid] : 0;
		$OVERFUEL = isset($FUELOVER[$ROWS->locationid][$ROWS->tankid]) ? (float)$FUELOVER[$ROWS->locationid][$ROWS->tankid] : 0;
		$LOWFUEL = isset($FUELLOW[$ROWS->locationid][$ROWS->tankid]) ? (float)$FUELLOW[$ROWS->locationid][$ROWS->tankid] : 0;
		$ullageTarget = isset($FUELULLAGE[$ROWS->locationid][$ROWS->tankid]) ? (float)$FUELULLAGE[$ROWS->locationid][$ROWS->tankid] : 90;
		$capacityTarget = $capacity ? ($capacity * $ullageTarget / 100) : 0;
		$percent = $capacity ? round(($ROWS->gallons * 100) / $capacity, 2) : 0;
		$actualUllage = $capacityTarget ? round($capacityTarget - $ROWS->gallons, 2) : 0;
		$stateClass = 'is-normal';
		if($LOWFUEL && $ROWS->gallons < $LOWFUEL)$stateClass = 'is-low';
		elseif($LESSFUEL && $ROWS->gallons < $LESSFUEL)$stateClass = 'is-less';
		elseif($OVERFUEL && $ROWS->gallons > $OVERFUEL)$stateClass = 'is-over';
		if($inventoryUpdatedAt === 'No live update' && strlen(trim($ROWS->recorded)))$inventoryUpdatedAt = $ROWS->recorded;
		$inventoryGallons += (float)$ROWS->gallons;
		$inventoryRows[] = [
			'tankid' => $ROWS->tankid,
			'product' => $ROWS->product,
			'gallons' => $ROWS->gallons,
			'ullage' => $ROWS->ullage,
			'ullage_target' => $ullageTarget,
			'actual_ullage' => $actualUllage,
			'water' => $ROWS->water,
			'inches' => $ROWS->inches,
			'deg' => $ROWS->deg,
			'capacity' => $capacity,
			'percent' => $percent,
			'color' => $color,
			'state_class' => $stateClass
		];
	}
}
$locationHref = rawurlencode((string)$locationid);
$locationAlertRows = !empty($ALARAM[$locationid]) ? $ALARAM[$locationid] : [];
$sanitizedAlertRows = [];
foreach($locationAlertRows as $ALRM){
	$alertHtml = ep_render_alert_html($ALRM);
	if(strlen(trim(strip_tags($alertHtml))))$sanitizedAlertRows[] = $alertHtml;
}
?>
<style>
.ep-report-shell{max-width:430px;margin:0 auto 32px;background:#f5f7fa;color:#20252d;font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Arial,sans-serif;border-radius:24px;box-shadow:0 0 40px rgba(0,0,0,.10);overflow:hidden}
.ep-report-shell *{box-sizing:border-box}
.ep-report-shell a{text-decoration:none}
.ep-report-shell .ep-page{padding:18px 14px 100px;background:#f5f7fa}
.ep-report-shell .ep-hero{background:linear-gradient(140deg,#20275f 0%,#363f86 100%);border-radius:22px;padding:18px;color:#fff;box-shadow:0 8px 24px rgba(31,39,95,.10);margin-bottom:14px}
.ep-report-shell .ep-label{font-size:11px;font-weight:800;letter-spacing:1px;text-transform:uppercase;opacity:.72}
.ep-report-shell .ep-title{font-size:24px;line-height:1.15;margin:8px 0 4px;font-weight:800;letter-spacing:-.5px}
.ep-report-shell .ep-subtitle{margin:0;font-size:11px;opacity:.84}
.ep-report-shell .ep-nav{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:14px}
.ep-report-shell .ep-nav a,.ep-report-shell .ep-nav span,.ep-report-shell .ep-toolbar a{display:flex;align-items:center;justify-content:center;height:38px;border-radius:11px;background:#fff;border:1px solid #d8dee7;color:#344054;font-size:11px;font-weight:800}
.ep-report-shell .ep-toolbar{display:flex;gap:8px;margin-bottom:14px}
.ep-report-shell .ep-toolbar a{flex:1}
.ep-report-shell .ep-summary{display:grid;grid-template-columns:repeat(2,1fr);gap:10px;margin-bottom:16px}
.ep-report-shell .ep-card{background:#fff;border:1px solid #dfe5ec;border-radius:18px;padding:14px;box-shadow:0 5px 18px rgba(25,35,65,.045)}
.ep-report-shell .ep-card span{display:block;font-size:10px;font-weight:800;color:#697386;letter-spacing:.7px;text-transform:uppercase}
.ep-report-shell .ep-card strong{display:block;font-size:21px;font-weight:800;margin-top:8px;letter-spacing:-.3px}
.ep-report-shell .ep-section-head{display:flex;justify-content:space-between;align-items:center;gap:10px;margin:18px 2px 10px}
.ep-report-shell .ep-section-head h2{margin:0;font-size:15px;font-weight:800}
.ep-report-shell .ep-note{font-size:10px;color:#697386;font-weight:700}
.ep-report-shell .ep-stack{display:flex;flex-direction:column;gap:10px}
.ep-report-shell .ep-tank{background:#fff;border:1px solid #e7eaf0;border-radius:16px;padding:12px;box-shadow:0 4px 16px rgba(16,24,40,.035)}
.ep-report-shell .ep-tank.is-low{border-color:#f4c7c3;background:#fff7f6}
.ep-report-shell .ep-tank.is-less{border-color:#fde7b1;background:#fffaf0}
.ep-report-shell .ep-tank.is-over{border-color:#d0d5dd;background:#fcfcfd}
.ep-report-shell .ep-tank-top{display:flex;justify-content:space-between;gap:10px;align-items:flex-start}
.ep-report-shell .ep-tank-top strong{display:block;font-size:12px}
.ep-report-shell .ep-meta{font-size:10px;color:#697386;margin-top:3px}
.ep-report-shell .ep-percent{font-size:12px;font-weight:900;white-space:nowrap}
.ep-report-shell .ep-progress{height:9px;border-radius:999px;background:#edf0f4;overflow:hidden;margin:10px 0}
.ep-report-shell .ep-progress span{display:block;height:100%;border-radius:999px}
.ep-report-shell .ep-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}
.ep-report-shell .ep-grid div{background:#f7f9fb;border-radius:10px;padding:8px}
.ep-report-shell .ep-grid label{display:block;font-size:8px;text-transform:uppercase;color:#8a94a5;letter-spacing:.35px}
.ep-report-shell .ep-grid b{display:block;font-size:11px;margin-top:3px}
.ep-report-shell .ep-list-card{background:#fff;border:1px solid #dfe5ec;border-radius:18px;overflow:hidden;box-shadow:0 5px 18px rgba(25,35,65,.045)}
.ep-report-shell .ep-row{padding:13px;border-bottom:1px solid #edf0f4}
.ep-report-shell .ep-row:last-child{border-bottom:0}
.ep-report-shell .ep-row-top{display:flex;justify-content:space-between;gap:10px;align-items:flex-start}
.ep-report-shell .ep-row-top strong{font-size:12px}
.ep-report-shell .ep-row-top span{font-size:10px;color:#697386}
.ep-report-shell .ep-delivery-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-top:9px}
.ep-report-shell .ep-delivery-grid div{background:#f7f9fb;border-radius:10px;padding:8px}
.ep-report-shell .ep-delivery-grid label{display:block;font-size:8px;text-transform:uppercase;color:#8a94a5;letter-spacing:.35px}
.ep-report-shell .ep-delivery-grid b{display:block;font-size:11px;margin-top:3px}
.ep-report-shell .ep-log{background:#fff;border:1px solid #dfe5ec;border-radius:18px;padding:14px;box-shadow:0 5px 18px rgba(25,35,65,.045)}
.ep-report-shell .ep-log h3{margin:0 0 10px;font-size:13px}
.ep-report-shell .ep-log pre{margin:0;white-space:pre-wrap;word-break:break-word;font-size:11px;line-height:1.5;color:#344054}
.ep-report-shell .ep-alerts{background:#fff7ed;border:1px solid #fed7aa;border-radius:16px;padding:12px;font-size:11px;color:#7c2d12}
.ep-report-shell .ep-alert-line + .ep-alert-line{margin-top:8px;padding-top:8px;border-top:1px solid rgba(124,45,18,.12)}
.ep-report-shell .ep-empty{background:#fff;border:1px dashed #ccd5df;border-radius:16px;padding:24px 18px;text-align:center;color:#697386;font-size:11px}
.ep-report-shell .ep-footer-actions{display:flex;gap:8px;margin-top:16px}
.ep-report-shell .ep-footer-actions a{flex:1;display:flex;justify-content:center;align-items:center;height:44px;border-radius:12px;font-size:12px;font-weight:800}
.ep-report-shell .ep-print-btn{background:#2b176f;color:#fff}
.ep-report-shell .ep-export-btn{background:#fff;color:#20275f;border:1px solid #d8dee7}
@media(max-width:360px){
	.ep-report-shell .ep-summary,.ep-report-shell .ep-grid,.ep-report-shell .ep-delivery-grid{grid-template-columns:1fr}
}
@media print{
	.ep-report-shell{box-shadow:none;border-radius:0;max-width:none}
	.ep-report-shell .noprint{display:none!important}
	.ep-report-shell .ep-page{padding:0;background:#fff}
}
</style>
<div class="ep-report-shell">
	<div class="ep-page" id="printdata">
		<div class="ep-hero">
			<div class="ep-label">Easy Petro</div>
			<h1 class="ep-title"><?=htmlspecialchars($locationname);?></h1>
			<p class="ep-subtitle">Detailed inventory, delivery, and archive logs for this location</p>
		</div>

		<?if(!strlen($_REQUEST['export'])){?>
		<div class="ep-nav noprint">
			<?if($cposition > 0){?><a href="?force=y&location=<?=$BIDS[($cposition-1)]?>"><i class="fa fa-arrow-circle-o-left"></i>&nbsp;Previous</a><?}else{?><span>Previous</span><?}?>
			<?if((count($BIDS)-1) > $cposition){?><a href="?force=y&location=<?=$BIDS[($cposition+1)]?>">Next&nbsp;<i class="fa fa-arrow-circle-o-right"></i></a><?}else{?><span>Next</span><?}?>
		</div>
		<div class="ep-toolbar noprint">
			<a href="javascript:void(0)" onclick="triggerLocationPrint('printdata');"><i class="fa fa-print"></i>&nbsp;Print</a>
			<a href="?force=y&location=<?=$locationHref;?>&export=y"><i class="fa fa-file-excel-o"></i>&nbsp;Export</a>
		</div>
		<?}?>

		<div class="ep-summary">
			<div class="ep-card"><span>Tanks</span><strong><?=number_format(count($inventoryRows));?></strong></div>
			<div class="ep-card"><span>Gallons</span><strong><?=number_format($inventoryGallons, 2);?></strong></div>
			<div class="ep-card"><span>Deliveries</span><strong><?=number_format(!empty($DELIVERYQRY) ? count($DELIVERYQRY) : 0);?></strong></div>
			<div class="ep-card"><span>Alerts</span><strong><?=number_format(count($sanitizedAlertRows));?></strong></div>
		</div>
		<div class="ep-card" style="margin-bottom:16px;"><span>Updated</span><strong id="dt<?=$locationid;?>" style="font-size:14px;line-height:1.35"><?=htmlspecialchars($inventoryUpdatedAt);?></strong></div>

		<div class="ep-section-head">
			<h2>Inventory</h2>
			<div class="ep-note">Live tank status</div>
		</div>

		<?if(!empty($inventoryRows)){?>
		<div id="ajxcontent<?=$locationid;?>" class="veedortable ep-stack">
			<?if(!strlen($_REQUEST['export'])){?><a href="javascript:void(0)" class="refreshicon ep-card noprint" lid="<?=$locationid;?>" style="display:flex;justify-content:center;align-items:center;height:42px;padding:0;font-size:11px;font-weight:800;color:#20275f;">Refresh inventory</a><?}?>
			<?foreach($inventoryRows as $tank){?>
			<div class="ep-tank <?=$tank['state_class'];?>">
				<div class="ep-tank-top">
					<div>
						<strong>T<?=$tank['tankid'];?> · <?=htmlspecialchars($tank['product']);?></strong>
						<div class="ep-meta">Capacity <?=number_format($tank['capacity'], 2);?> · <?=htmlspecialchars($inventoryUpdatedAt);?></div>
					</div>
					<div class="ep-percent" style="color:<?=$tank['color'];?>"><?=number_format($tank['percent'], 2);?>%</div>
				</div>
				<div class="ep-progress"><span style="width:<?=min(100, max(0, $tank['percent']));?>%;background:<?=$tank['color'];?>"></span></div>
				<div class="ep-grid">
					<div><label>Gallons</label><b><?=number_format($tank['gallons'], 2);?></b></div>
					<div><label>Live Ullage</label><b><?=htmlspecialchars($tank['ullage']);?></b></div>
					<div><label><?=number_format($tank['ullage_target'], 0);?>% Ullage</label><b><?=number_format($tank['actual_ullage'], 2);?></b></div>
					<div><label>Water</label><b><?=htmlspecialchars($tank['water']);?></b></div>
					<div><label>Inches</label><b><?=htmlspecialchars($tank['inches']);?></b></div>
					<div><label>Deg F</label><b><?=htmlspecialchars($tank['deg']);?></b></div>
				</div>
			</div>
			<?}?>
		</div>
		<?}else{?>
		<div class="ep-empty">No live inventory data is available for this location yet.</div>
		<?}?>

		<?if(!empty($sanitizedAlertRows)){?>
		<div class="ep-section-head">
			<h2>Alerts</h2>
			<div class="ep-note"><?=number_format(count($sanitizedAlertRows));?> active</div>
		</div>
		<div class="ep-alerts"><?foreach($sanitizedAlertRows as $alertHtml){?><div class="ep-alert-line"><?=$alertHtml;?></div><?}?></div>
		<?}?>

		<?if(!empty($DELIVERYQRY)){?>
		<div class="ep-section-head">
			<h2>Delivery</h2>
			<div class="ep-note"><?=number_format(count($DELIVERYQRY));?> records</div>
		</div>
		<div class="ep-list-card">
			<?foreach($DELIVERYQRY as $ROWS){?>
			<div class="ep-row">
				<div class="ep-row-top">
					<div>
						<strong><?=htmlspecialchars($ROWS->products);?></strong>
						<span>Start <?=htmlspecialchars($ROWS->startrecorded);?></span>
					</div>
					<strong><?=number_format((float)$ROWS->amountgallons, 2);?> gal</strong>
				</div>
				<div class="ep-delivery-grid">
					<div><label>End gallons</label><b><?=htmlspecialchars($ROWS->endgallons);?></b></div>
					<div><label>Start gallons</label><b><?=htmlspecialchars($ROWS->startgallons);?></b></div>
					<div><label>Gallons TC</label><b><?=htmlspecialchars($ROWS->amountgallonstc);?></b></div>
					<div><label>End water</label><b><?=htmlspecialchars($ROWS->endwater);?></b></div>
					<div><label>End deg F</label><b><?=htmlspecialchars($ROWS->enddeg);?></b></div>
					<div><label>End height</label><b><?=htmlspecialchars($ROWS->endheight);?></b></div>
				</div>
			</div>
			<?}?>
		</div>
		<?}?>

		<?
		$logsFound = false;
		foreach($reportary as $key=>$val){
			$file = $dir.$key.'.txt';
			if(file_exists($file)){
				$filecontent = file_get_contents($file);
				if(!empty($filecontent)){
					$filecontent = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/', '', $filecontent);
					if(!$logsFound){?>
					<div class="ep-section-head">
						<h2>Archive Logs</h2>
						<div class="ep-note">Imported reports</div>
					</div>
					<div class="ep-stack">
					<?
						$logsFound = true;
					}
					?>
					<div class="ep-log">
						<h3><?=htmlspecialchars($val);?></h3>
						<pre><?=htmlspecialchars($filecontent);?></pre>
					</div>
				<?}
			}
		}
		if($logsFound){?></div><?}?>

		<?if(!strlen($_REQUEST['export'])){?>
		<div class="ep-footer-actions noprint">
			<a href="javascript:void(0);" onclick="triggerLocationPrint('printdata');" class="ep-print-btn"><i class="fa fa-print"></i>&nbsp;Print</a>
			<a href="?force=y&location=<?=$locationHref;?>&export=y" class="ep-export-btn"><i class="fa fa-file-excel-o"></i>&nbsp;Export</a>
		</div>
		<?}?>
	</div>
</div>
<script>
function triggerLocationPrint(id){
	if(typeof printreport === 'function'){
		printreport(id);
		return;
	}
	window.print();
}
</script>
<?$mainclass->footercontent($footercontent);?>
