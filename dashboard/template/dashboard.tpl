<?$mainclass->headercontent();?>
<?if(!strlen($_REQUEST["export"])){?>
<div class="clear"></div>
<div style="text-align:right"><a href="javascript:void(0)" class="expandall">- Expand All</a> &nbsp;&nbsp; | &nbsp;&nbsp;
<a href="javascript:void(0)" class="collapsall">+ Collaps All</a></div>
<?}?>
<div id="sortable">
<?foreach($LOCATIONQRY as $LOCATION){?>
	<div id="ajxcontent<?=$LOCATION['sno'];?>" class="dashlc">
		<h2 class="expandcolaps" id="<?=$LOCATION['sno'];?>"><?=$LOCATION['title'];?><?if(!empty($ALARAMARRAY[$LOCATION['sno']])){?>
		<span class="alaramcount"><?=count($ALARAMARRAY[$LOCATION['sno']]);?></span><?}?></h2>
		<div id="ajxcontent<?=$LOCATION['sno'];?>" class="reportctn veedortable">
		<?if(!empty($VEEDORARRAY[$LOCATION['sno']])){?>
			<?if(!strlen($_REQUEST["export"])){?><a href="?force=y&location=<?=$LOCATION['sno'];?>" class="viewmore btn noprint">View</a><?}?>
			<table cellpading="5" cellspacing="0" width="100%" border="1">
			<thead><tr>
			<td class="noborder" style="border-top: 1px solid #ccc;border-left: 1px solid #ccc;" width="20%">
			<?
			$vxpld = explode('^',$VEEDORARRAY[$LOCATION['sno']][0]);?>
			<?if(!strlen($_REQUEST["export"])){?><a href="javascript:void(0)" class="refreshicon noprint" lid="<?=$LOCATION['sno'];?>"><img src="<?=IMAGESPATH;?>refresh.jpg" alt="refresh"></a><?}?><span id="dt<?=$LOCATION['sno'];?>"><?=$vxpld[7];?></span></td>
			<td style="width:25%">Tank - Product (Capacity)</td>
			<td>Gallon</td>
			<td>Ullage (Live)</td>
			<td>Ullage (<?echo $ullage="90";?>%)</td>
			<td class="water">Water</td>
			<td class="inches">Inches</td>
			<td class="deg">DEG F</td>
			</tr></thead>
			<tbody>
		<?foreach($VEEDORARRAY[$LOCATION['sno']] as $VEEDORDATA){
			$vxpld = explode('^',$VEEDORDATA);
			$VEEDOR['tankid'] = $vxpld[0];
			$VEEDOR['product'] = $vxpld[1];
			$VEEDOR['gallons'] = $vxpld[2];
			$VEEDOR['ullage'] = $vxpld[3];
			$VEEDOR['inches'] = $vxpld[4];
			$VEEDOR[deg] = $vxpld[5];
			$VEEDOR['water'] = $vxpld[6];
			$VEEDOR['recorded'] = $vxpld[7];
			
			
			
			$color = $FUELCOLOR[$LOCATION['sno']][$VEEDOR['tankid']];
			$capacity = $FUELCAPACITY[$LOCATION['sno']][$VEEDOR['tankid']];
			$ullage = $FUELULLAGE[$LOCATION['sno']][$VEEDOR['tankid']];
			
			$LESSFUEL = $FUELLESS[$LOCATION['sno']][$VEEDOR['tankid']];
			$OVERFUEL = $FUELOVER[$LOCATION['sno']][$VEEDOR['tankid']];
			$LOWFUEL = $FUELLOW[$LOCATION['sno']][$VEEDOR['tankid']];
			$LESSWATER = $WATERLESS[$LOCATION['sno']][$VEEDOR['tankid']];
			$OVERWATER = $WATEROVER[$LOCATION['sno']][$VEEDOR['tankid']];
			$LOWWATER = $WATERLOW[$LOCATION['sno']][$VEEDOR['tankid']];
			
			
			$capacity2 = ($capacity * 90/100);
			
			$actualullage = round(($capacity * $ullage/100) - $VEEDOR['gallons']);
			
			$percent=round(($VEEDOR['gallons'] * 100)/$capacity,2);
			//$actualullage = ($capacity2 - $VEEDOR['gallons']);
			$colorcode[$VEEDOR['product']]=$color;
			if(!empty($color)){?>	
			<tr class="<?=str_replace('#','',$color);?>">
			<td class="graphtd noborder"><span class="tankgraph" style="border-color:<?=$color;?>;"><span class="fill" style="width:<?=$percent;?>%;background-color:<?=$color;?>;"><?=round($percent,2);?>%</span></span></td>
			<td>T<?=$VEEDOR['tankid'];?> - <?=$VEEDOR['product'];?> (<?=$capacity;?>) <span class="mobileview" style="color:<?=$color;?>;"> - <?=round($percent,2);?>%</span></td>
			<td class="<?if($VEEDOR['gallons'] < $LOWFUEL){echo 'low';}elseif($VEEDOR['gallons'] < $LESSFUEL){echo 'less';}elseif($VEEDOR['gallons'] > $OVERFUEL && $OVERFUEL != 0){echo 'over';}?>"><?=$VEEDOR['gallons'];?></td>
			<td><?=$VEEDOR['ullage'];?></td>
			<td><?=$actualullage;?></td>
			<td class="water <?if($VEEDOR['water'] < $LOWWATER){echo 'low';}elseif($VEEDOR['water'] < $LESSWATER){echo 'less';}elseif($VEEDOR['water'] > $OVERWATER && $OVERWATER!=0){echo 'over';}?>"><?=$VEEDOR['water'];?></td>
			<td class="inches"><?=$VEEDOR['inches'];?></td>
			<td class="deg"><?=$VEEDOR[deg];?></td></tr>
		<?	}
		}?>
			
			</tbody></table>		
		<?}?>
		<?foreach($ALARAM[$LOCATION['sno']] as $ALRM){echo $ALRM;}?>	
		</div>
		<div class="clear"></div>
	</div>
<?}?>	
</div>
<?if(!strlen($_REQUEST["export"])){?>
<div class="text-center"><a href="javascript:void(0);" onclick="printreport('sortable');" class="noprint btn"><i class="fa fa-print"></i> Print</a> &nbsp; <a href="?export=y" class="btn"><i class="fa fa-file-excel-o"></i> Export</a></div>
<?}?>
<?$mainclass->footercontent($footercontent);?>