<?php
class dashboard{
	function __construct(){
		$this->pg=$_GET['pg'];
		$login = new login();$login->loginchk("UASM");
	}
	function management(){
		if(!empty($_REQUEST["force"]))self::locationreport($_REQUEST["location"]);
		else self::mydashboard();
	}
	function locationreport($locationid){
		global $config,$mainclass;
		$i=0;
		$LOCATIONQRY = $config->fetch_all_array("SELECT sno,title FROM ".DBNAME2."branches WHERE veedor=1 ORDER BY position,title");
		foreach($LOCATIONQRY as $LOCATIONROW){
			$BIDS[$i] =$LOCATIONROW["sno"];
			if($LOCATIONROW["sno"]==$locationid){
				$cposition = $i;
				$locationname = $LOCATIONROW["title"];
			}
			$i++;
		}
		
		$FUELCODEQRY = $config->fetch_all_array("SELECT * FROM ".TABLEPFX."fuelcode WHERE locationid='$locationid' ORDER BY locationid,tankid");
		
		$DELIVERYQRY = json_decode(delivery::getdelivery($locationid));
		$reportary=array('I20200'=>'Delivery Report','I10100'=>'System Status','I11200'=>'Non-Priority Alarm History','I20700'=>'Leak Test History','I20800'=>'Leak Test Result','I30100'=>'Liquid Sensor Status Report','I11100'=>'Priority Alaram History');
		
		$dir = LIVEFILEPATH.'archive/'.$locationid."/";
		
		$logreport=new logreport();
		$ALARAM = $logreport->getalaram($locationid);
		$QRY = json_decode(veedor::getveedordata($locationid));
		foreach($FUELCODEQRY as $FUELQRY){
			$fuelcontent.='fuelcode_'.$FUELQRY['locationid'].'_'.$FUELQRY['tankid'].'="'.$FUELQRY['capacity'].'|'.$FUELQRY['tankcolor'].'|'.$FUELQRY['lessfuel'].'|'.$FUELQRY['maxfuel'].'|'.$FUELQRY['lowfuel'].'|'.$FUELQRY['lesswater'].'|'.$FUELQRY['maxwater'].'|'.$FUELQRY[' '].'";';
			$FUELCAPACITY[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['capacity'];
			$FUELULLAGE[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['ullage'];
			$FUELCOLOR[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['tankcolor'];
			$FUELLESS[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['lessfuel'];
			$FUELOVER[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['maxfuel'];
			$FUELLOW[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['lowfuel'];
			$WATERLESS[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['lesswater'];
			$WATEROVER[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['maxwater'];
			$WATERLOW[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['lowwater'];
		}
		include(dirname(__FILE__)."/template/report.tpl");
	}
	function mydashboard(){
		global $config,$mainclass;
		$lcondition="";
		if(!empty($_SESSION['admin_locationids']) && $_SESSION['admin_locationids']!=-1)$lcondition = "AND sno IN (".$_SESSION['admin_locationids'].")";
		$LOCATIONQRY = $config->fetch_all_array("SELECT sno,title FROM ".DBNAME2."branches WHERE status=1 AND veedor=1 $lcondition ORDER BY position,title");
		
		$FUELCODEQRY = $config->fetch_all_array("SELECT * FROM ".TABLEPFX."fuelcode ORDER BY locationid,tankid");
		$content = 'var fuelcode = [];';
		foreach($FUELCODEQRY as $FUELQRY){
			$fuelcontent.='fuelcode_'.$FUELQRY['locationid'].'_'.$FUELQRY['tankid'].'="'.$FUELQRY['capacity'].'|'.$FUELQRY['tankcolor'].'|'.$FUELQRY['lessfuel'].'|'.$FUELQRY['maxfuel'].'|'.$FUELQRY['lowfuel'].'|'.$FUELQRY['lesswater'].'|'.$FUELQRY['maxwater'].'|'.$FUELQRY[' '].'";';
			$FUELCAPACITY[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['capacity'];
			$FUELULLAGE[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['ullage'];
			$FUELCOLOR[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['tankcolor'];
			$FUELLESS[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['lessfuel'];
			$FUELOVER[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['maxfuel'];
			$FUELLOW[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['lowfuel'];
			$WATERLESS[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['lesswater'];
			$WATEROVER[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['maxwater'];
			$WATERLOW[$FUELQRY['locationid']][$FUELQRY['tankid']] = $FUELQRY['lowwater'];
		}
		$delivery = new delivery();
		$DELIVERYQRY = json_decode($delivery->getdelivery());
		$logreport = new logreport();
		$ALARAM = $logreport->getalaram();
		$veedor = new veedor();
		$VEEDORQRY = json_decode($veedor->getveedordata());
		$ALARAMARRAY = $VEEDORARRAY = [];
		foreach($VEEDORQRY as $VEEDORROW){
			$VEEDORROW->recorded = str_replace('  ',' ',$VEEDORROW->recorded);
			if(strstr($VEEDORROW->recorded,'-'.$cyear.' ')){
				$xpld = explode(' ',$VEEDORROW->recorded);
				$xpld2 = explode('-',$xpld[0]);
				$VEEDORROW->recorded = str_replace('-'.$cyear.' ','-20'.$cyear.' ',$VEEDORROW->recorded);
				$VEEDORROW->recorded = strtoupper(date("M d, Y",strtotime($xpld2[2].'-'.$xpld2[0].'-'.$xpld2[1])).' '.$xpld[1].' '.$xpld[2]);
			}
			
			$VEEDORARRAY[$VEEDORROW->locationid][]=$VEEDORROW->tankid.'^'.$VEEDORROW->product.'^'.$VEEDORROW->gallons.'^'.$VEEDORROW->ullage.'^'.$VEEDORROW->inches.'^'.$VEEDORROW->deg.'^'.$VEEDORROW->water.'^'.$VEEDORROW->recorded;
		}
		foreach($ALARAM as $key=>$ALARAMROW){
			$ALARAMARRAY[$key][]=$ALARAMROW['alaramtext'].'^'.$ALARAMROW['reportid'];
		}
		
		include(dirname(__FILE__)."/template/dashboard.tpl");
	}
}?>