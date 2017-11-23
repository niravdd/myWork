<?php

return array(
    // List of config profiles available 
    'configProfiles' => array(
        'telemetry' => array(
            // Short comment displayed at the top
            'comment' => 'This template will simulate a game being run numerous times',

            // Filename must be spelled the same as the filename in the config/ folder
            'filename' => 'telemetry.php',

            // Name of an existing Kiensis stream
            'streamName' => 'workshopTelemetryStream',

            // Total number of entries generated
            'total' => 5000,

            // Size of the batch to send to Kinesis
            'batchSize' => 400,

            // Interval for loop in ms
            'interval' => 10000,

            // Region
            'region' => 'us-west-2',
        ),
        'player' => array(
            // Short comment displayed at the top
            'comment' => 'This template will generate some player profile data',

            // Filename must be spelled the same as the filename in the config/ folder
            'filename' => 'sample.template.php',

            // Name of an existing Kiensis stream
            'streamName' => 'workshopAnalyticsStream',

            // Total number of entries generated
            'total' => 1000,

            // Size of the batch to send to Kinesis
            'batchSize' => 500,

            // Interval for loop in ms
            'interval' => 20000,

            // Region
            'region' => 'us-west-2',
        ),
    ),
);
