<?$mainclass->headercontent();?>
<div id="printdata">
	<div class="clear"></div>
	<h1 class="flLt"><?=$locationname;?></h1>
<?if(!strlen($_REQUEST["export"])){?>
	<div class="flRt">
	<?if($cposition > 0){?><div class="flLt noprint"><a href="?force=y&location=<?=$BIDS[($cposition-1)]?>"><i class="fa fa-arrow-circle-o-left"></i> Previous</a></div><?}else{?><div class="flLt">&nbsp;</div><?}?>
	<?
	if((count($BIDS)-1) > $cposition){?><div class="flRt noprint" style="margin-left:30px;"><a href="?force=y&location=<?=$BIDS[($cposition+1)]?>">Next <i class="fa fa-arrow-circle-o-right"></i></a></div><?}?>
	</div>
	<hr class="clear noprint" style="border:0px;border-bottom:1px solid #ccc;" />
<?}?>		
<?if(!empty($QRY)){?>
	<div>
		<h2 class="clear">Inventory</h2>
		<div id="ajxcontent<?=$ROWS->locationid;?>" class="veedortable" style="margin-bottom:0">
		<div class="clear"></div>
		<table cellpading="5" cellspacing="0" width="100%" border="1">
		<thead><tr>
		<td class="noborder" style="border-top: 1px solid #ccc;border-left: 1px solid #ccc;padding-left:10px" width="20%"><?if(!strlen($_REQUEST["export"])){?><a href="javascript:void(0)" class="refreshicon noprint" lid="<?=$ROWS->locationid;?>"><img src="<?=IMAGESPATH;?>refresh.jpg" alt="refresh"></a><?}?><span id="dt<?=$ROWS->locationid;?>"><?=$QRY[0]->recorded;?></span></td>
		<td style="width:25%">Tank - Product (Capacity)</td>
		<td>Gallon</td>
		<td>Ullage (Live)</td>
		<td>Ullage (<?echo $ullage=90;?>%)</td>
		<td>Water</td>
		<td>Inches</td>
		<td>DEG F</td>
		</tr></thead>
		<tbody>
<?$l=0;$capacity=10000;$colorcode=[];$locationid="";
foreach($QRY as $ROWS){
		$color = $FUELCOLOR[$ROWS->locationid][$ROWS->tankid];
		$capacity = $FUELCAPACITY[$ROWS->locationid][$ROWS->tankid];
		//$capacity = round(($ROWS->gallons + $ROWS->ullage)/1000) * 1000; 
		
		$LESSFUEL = $FUELLESS[$ROWS->locationid][$ROWS->tankid];
		$OVERFUEL = $FUELOVER[$ROWS->locationid][$ROWS->tankid];
		$LOWFUEL = $FUELLOW[$ROWS->locationid][$ROWS->tankid];
		$LESSWATER = $WATERLESS[$ROWS->locationid][$ROWS->tankid];
		$OVERWATER = $WATEROVER[$ROWS->locationid][$ROWS->tankid];
		$LOWWATER = $WATERLOW[$ROWS->locationid][$ROWS->tankid];
		
		
		$capacity2 = ($capacity * 90/100);
		$percent=round(($ROWS->gallons * 100)/$capacity,2);
		$actualullage = ($capacity2 - $ROWS->gallons);
		$colorcode[$ROWS->product]=$color;?>
		<tr class="<?=str_replace('#','',$color);?>">
		<td class="graphtd noborder"><span class="tankgraph" style="border-color:<?=$color;?>;"><span class="fill" style="width:<?=$percent;?>%;background-color:<?=$color;?>;"><?=round($percent,2);?>%</span></span></td>
		<td>T<?=$ROWS->tankid;?> - <?=$ROWS->product;?> (<?=$capacity;?>) <span class="mobileview" style="color:<?=$color;?>;"> - <?=round($percent,2);?>%</span></td>
		<td class="<?if($ROWS->gallons < $LOWFUEL){echo 'low';}elseif($ROWS->gallons < $LESSFUEL){echo 'less';}elseif($ROWS->gallons > $OVERFUEL && $OVERFUEL != 0){echo 'over';}?>"><?=$ROWS->gallons;?></td>
		<td><?=$ROWS->ullage;?></td>
		<td><?=$actualullage;?></td>
		<td class="<?if($ROWS->water >= $OVERWATER && $ROWS->water!=0){echo 'low';}elseif($ROWS->water <= $OVERWATER && $ROWS->water >= $LESSWATER && $ROWS->water!=0){echo 'less';}elseif($ROWS->water <= $OVERWATER && $ROWS->water!='0.00'){echo 'over';}?>"><?=$ROWS->water;?></td>
		<td><?=$ROWS->inches;?></td>
		<td><?=$ROWS->deg;?></td></tr>
	<?
}?>
</tbody></table></div><div class="clear"></div><?foreach($ALARAM[$locationid] as $ALRM){echo $ALRM;}?>
</div>
<?}?>

<?if(!empty($DELIVERYQRY)){?>
	<div class="clear">&nbsp;</div>
		<h1>Delivery</h1>
		<div id="ajxcontent<?=$ROWS->locationid;?>" class="deliverytable">
			<div class="clear">&nbsp;</div>
			<div class="clear"></div>
			<table cellpading="5" cellspacing="0" width="100%" border="1">
			<thead><tr>
			<td width="15%">PRODUCTS</td>
			<td width="10%" class="rtxt">INCREASE</td>
			<td width="15%">DATE / TIME</td>
			<td class="rtxt">GALLONS TC</td>
			<td class="rtxt">GALLONS</td>
			<td class="water rtxt">Water</td>
			<td class="deg rtxt">DEG F</td>
			<td class="inches rtxt">HEIGHT</td>
			</tr></thead>
			<tbody>
<?$l=0;$capacity=10000;$colorcode=[];$locationid="";
foreach($DELIVERYQRY as $ROWS){?>
		<tr>
		<td><?=$ROWS->products;?></td>
		<td class="rtxt">END</td>
		<td><?=$ROWS->endrecorded;?></td>
		<td class="rtxt"><?=$ROWS->endgallonstc;?></td>
		<td class="rtxt"><?=$ROWS->endgallons;?></td>
		<td class="water rtxt"><?=$ROWS->endwater;?></td>
		<td class="deg rtxt"><?=$ROWS->enddeg;?></td>
		<td class="inches rtxt"><?=$ROWS->endheight;?></td></tr>
		<tr><td>&nbsp;</td><td class="rtxt">START</td>
		<td><?=$ROWS->startrecorded;?></td>
		<td class="rtxt"><?=$ROWS->startgallonstc;?></td>
		<td class="rtxt"><?=$ROWS->startgallons;?></td>
		<td class="water rtxt"><?=$ROWS->startwater;?></td>
		<td class="deg rtxt"><?=$ROWS->startdeg;?></td>
		<td class="inches rtxt"><?=$ROWS->startheight;?></td></tr>
		<tr class="lgraybg">
		<td>&nbsp;</td>
		<td class="rtxt">AMOUNT</td>
		<td>&nbsp;</td>
		<td class="rtxt"><?=$ROWS->amountgallonstc;?></td>
		<td class="rtxt"><?=$ROWS->amountgallons;?></td>
		<td class="water">&nbsp;</td>
		<td class="deg">&nbsp;</td>
		<td class="inches">&nbsp;</td>
		</tr>
<?	}
}?>
</tbody></table></div><div class="clear"></div>
<?foreach($ALARAM[$locationid] as $ALRM){echo $ALRM;}?>
<div class="clear">&nbsp;</div>
<div class="inventorylog">
<?
foreach($reportary as $key=>$val){
	$file = $dir.$key.'.txt';
	if(file_exists($file)){
		$fp = fopen($file,"r");
		$filecontent = fread($fp,filesize($file));
		fclose($fp);
		if(!empty($filecontent)){?>
			<div class="block" id="logdata">
			<h2><?=$val;?></h2>
			<pre><?=str_replace('','',$filecontent);?></pre></div>
			<div class="clear">&nbsp;</div>
	<?	}
	}
}?>
</div>
<?if(!strlen($_REQUEST["export"])){?>
<div class="clear">&nbsp;</div>
<div class="text-center"><a href="javascript:void(0);" onclick="printreport('printdata');" class="noprint btn"><i class="fa fa-print"></i> Print</a> &nbsp; <a href="?force=y&location=<?=$_REQUEST['location']?>&export=y" class="btn"><i class="fa fa-file-excel-o"></i> Export</a></div>
</div><?}?>
<?$mainclass->footercontent($footercontent);?>