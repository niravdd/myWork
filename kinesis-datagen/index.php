<?php
/**
 * Web page to generate dataset and push it to a Kinesis stream
 */
// Show errors 
if (isset($_REQUEST['showErrors']) && $_REQUEST['showErrors'] == 'true') { 
    ini_set('display_errors', 1);
}

// Starting timer
$start = microtime(true); 

// Increasing execution time and memory
ini_set('max_execution_time', 3600);
ini_set('memory_limit', '256M');

$webConfig = require __DIR__ . '/config/webapp.php';

require __DIR__ . '/vendor/autoload.php';

class cli { public static $log = null; public static function log($m) { self::$log .= '[' . date('Y-m-d H:i:s') . '] ' . $m . PHP_EOL; } }

$ec2role = 'datagenRole';
$credentials = array('key' => null, 'secret' => null);
$json = array();
if (isset($_SERVER['HTTP_HOST']) && $_SERVER['HTTP_HOST'] != 'localhost') { 
    $metadataRole = file_get_contents('http://169.254.169.254/latest/meta-data/iam/security-credentials/');
    // Fetch creds from ec2 metadata instance (if available)
    $creds = file_get_contents('http://169.254.169.254/latest/meta-data/iam/security-credentials/' . $metadataRole);
    $json = json_decode($creds, true);
} else { 
    $credentialsFile = __DIR__ . '/config/credentials.php';
    if (file_exists($credentialsFile)) { 
        $credentials = require $credentialsFile;
    }
}

$defaultKey = isset($json['AccessKeyId']) ? $json['AccessKeyId'] : $credentials['key'];
$defaultSecret = isset($json['SecretAccessKey']) ? $json['SecretAccessKey'] : $credentials['secret'];
$token = isset($json['Token']) ? $json['Token'] : null;

$key = isset($_REQUEST['key']) ? $_REQUEST['key'] : $defaultKey;
$secret = isset($_REQUEST['secret']) ? $_REQUEST['secret'] : $defaultSecret;
$configProfile = isset($_REQUEST['configProfile']) ? $_REQUEST['configProfile'] : 'analytics1';

$configSettings = $webConfig['configProfiles'][$configProfile];
$configFilename = $configSettings['filename'];

$comment = isset($configSettings['comment']) ? $configSettings['comment'] : null;
$defaultStreamName = isset($configSettings['streamName']) ? $configSettings['streamName'] : '';
$defaultTotal = isset($configSettings['total']) ? $configSettings['total'] : 10000;
$defaultBatchSize = isset($configSettings['batchSize']) ? $configSettings['batchSize'] : 500;
$defaultInterval = isset($configSettings['interval']) ? $configSettings['interval'] : 10;
$defaultRegion = isset($configSettings['region']) ? $configSettings['region'] : 'us-west-2';
$defaultLoop = isset($configSettings['loop']) ? $configSettings['loop'] : false;

$config = isset($_REQUEST['config']) ? json_decode($_REQUEST['config'], true) : require __DIR__ . '/config/' . $configFilename;
$region = isset($_REQUEST['region']) ? $_REQUEST['region'] : $defaultRegion;
$streamName = isset($_REQUEST['streamName']) ? $_REQUEST['streamName'] : $defaultStreamName;

$total = isset($_REQUEST['total']) ? $_REQUEST['total'] : $defaultTotal;
$batchSize = isset($_REQUEST['batchSize']) ? $_REQUEST['batchSize'] : $defaultBatchSize;
$interval = isset($_REQUEST['interval']) ? $_REQUEST['interval'] : $defaultInterval;
$loop = isset($_REQUEST['loop']) ? $_REQUEST['loop'] : $defaultLoop;

$implementation = isset($configSettings['implementation']) ? $configSettings['implementation'] : 'kinesis';

try {
    
    $kinesis = Aws\Kinesis\KinesisClient::factory(array(
        'credentials' => array(
            'key'    => $key,
            'secret' => $secret,
            'token' => $token,
        ),
        'region' => $region,
        'version' => 'latest',
    ));

    $kinesisFirehose = Aws\Firehose\FirehoseClient::factory(array(
        'credentials' => array(
            'key'    => $key,
            'secret' => $secret,
            'token' => $token,
        ),
        'region' => $region,
        'version' => 'latest',
    ));

    $result = null;
    if (isset($_REQUEST['submitFrm'])) { 
        $gen = new AwsBootcamp\Generator\DataSet($kinesis, $kinesisFirehose, $streamName);
        $dataSet = $gen->execute($config, $total, $batchSize, $implementation);

        $result = PHP_EOL . 'Stats' . PHP_EOL;
        $result .= '---------' . PHP_EOL;
        $result .= 'Total generated : ' . sizeof($dataSet);
        $time = (microtime(true) - $start);
        $result .= PHP_EOL . 'Time : ' . $time . ' seconds' . PHP_EOL;
        $result .= 'Speed : ' . (sizeof($dataSet) / $time) . ' records/sec' . PHP_EOL . PHP_EOL;
    }
}
catch (\Exception $e) { 
    $result = 'Exception caught:' . PHP_EOL . $e->getMessage();
}
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>DataGenerator</title>
    <!-- Bootstrap core CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css" integrity="sha384-PsH8R72JQ3SOdhVi3uxftmaW6Vc51MKb0q5P2rRUpPvrszuE4W1povHYgTpBfshb" crossorigin="anonymous">
    <link href="http://getbootstrap.com/docs/4.0/examples/cover/cover.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.3/umd/popper.min.js" integrity="sha384-vFJXuSJphROIrBnz7yo7oB41mKfc8JzQZiCq4NCceLEaO4IHwicKwpJf9c9IpFgh" crossorigin="anonymous"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/js/bootstrap.min.js" integrity="sha384-alpBpkh1PFOepccYVYDB4do5UnbKysX5WZXm3XxPqe5iKTfUKjNkCk9SaVuEZflJ" crossorigin="anonymous"></script>
    <style>
        #container textarea { margin:10px auto; width:90%; background-color:white; font-family:"Courier New"; font-size:0.8em; text-align:left; }
        #container .small { width:100px; margin-right:20px; }
        #container .tiny { width:50px; margin-right:20px; }
        #container .marginRight { margin-right:40px; }
        #container .thick { height:35px; }
    </style>
  </head>
  <body id="container">
    <div class="site-wrapper">
      <div class="site-wrapper-inner">
        <img src="https://reinvent.awsevents.com/_media/images/branding/aws-reinvent-logo.png" alt="AWS re:Invent 2017 logo" /><h1>GAM310 GameBot!</h1><br /><br />
         <div class="form-group">
            <form name="frmConfig" id="frmConfig" action="?" method="get">
                <select class="small thick" name="configProfile">
                <?php
                foreach ($webConfig['configProfiles'] as $v => $data) {
                    echo '<option value="' . $v . '"';
                    if ($v == $configProfile) { 
                        echo ' selected="selected"';
                    }
                    echo '>' . $v . '</option>';
                }
                ?> 
                </select>
                <button type="submit" class="btn btn-primary">Load configuration profile</button><br />
                <label for="exampleFormControlTextarea1">DataGenerator <?php echo isset($comment) ? ' - ' . $comment . ' (to ' . $implementation . ')' : null; ?></label>
            </form>
         </div>
         <form name="frm" id="frm" action="?" method="post">
         <div class="form-group">
            <textarea class="form-control form-control-sm" rows="27" name="config"><?php echo json_encode($config, JSON_PRETTY_PRINT); ?></textarea>
         </div>
         <div class="form-group">
            <input type="hidden" name="configProfile" value="<?php echo $configProfile; ?>" />
            <input type="hidden" name="implementation" value="<?php echo $implementation; ?>" />
            <input type="hidden" name="configFilename" value="<?php echo $configFilename; ?>" />
            <small>Region</small>  
            <input class="small" type="text" name="region" value="<?php echo $region; ?>" placeholder="aws region"/>
            <small>StreamName</small> 
            <input class="small" type="text" name="streamName" value="<?php echo $streamName; ?>" placeholder="aws streamName"/>
            <small>Total</small>  
            <input class="tiny" type="text" name="total" value="<?php echo $total; ?>" placeholder="total"/>
            <small>BatchSize</small>  
            <input class="tiny marginRight" type="text" name="batchSize" value="<?php echo $batchSize; ?>" placeholder="batchSize"/>  
            <small>Interval (in ms)</small>  
            <input class="tiny" type="text" name="interval" value="<?php echo $interval; ?>" placeholder="interval (in sec)"/>
            <small>Sending in loop</small>  
            <input class="tiny" type="checkbox" id="loop" name="loop" placeholder="loop" value="1" <?php if ($loop) { echo 'checked="checked"'; } ?> />
            <button type="submit" class="btn btn-primary" id="submitFrm" name="submitFrm">Generate</button>
          </div>
       </form>
       <?php if($result) { ?>
        <h4>Result</h4> 
        <textarea class="form-control form-control-sm" rows="10" id="result"><?php echo cli::$log . PHP_EOL . $result; ?></textarea>
        <?php } ?>
      </div>
    </div>
  </body>
</html>
<script>
var interval = null;
$(document).ready(function() {
<?php if ($loop && isset($_REQUEST['submitFrm'])) { ?>
	interval = setInterval(function() { refreshPage(); }, <?php echo $interval; ?>);
    $('#loop').change(function() {
        if(!this.checked) {
			clearInterval(interval);
		}
    });
<?php } ?> 
	function refreshPage() { 
		$('#submitFrm').click();
	}
});
</script>
