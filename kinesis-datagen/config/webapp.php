<?php

return array(
    // List of config profiles available 
    'configProfiles' => array(
        'analytics1' => array(
            // Short comment displayed at the top
            'comment' => 'This template will generate 5000 player profiles and push them to Kinesis Streams',

            // Filename must be spelled the same as the filename in the config/ folder
            'filename' => 'analytics1.php',

            // Name of an existing Kiensis stream
            'streamName' => 'workshopAnalyticsStream',

            // Total number of entries generated
            'total' => 5000,

            // Size of the batch to send to Kinesis
            'batchSize' => 400,

            // Interval for loop in ms
            'interval' => 10000,

            // Region
            'region' => 'us-west-2',

            // Implementation to use 
            'implementation' => 'kinesis',
        ),
        'telemetry1-1' => array(
            // Short comment displayed at the top
            'comment' => 'This template will simulate a game being run 5000 times, pushing it to Kinesis Streams',

            // Filename must be spelled the same as the filename in the config/ folder
            'filename' => 'telemetry1-1.php',

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

            // Implementation to use 
            'implementation' => 'kinesis',
        ),
        'telemetry1-2' => array(
            // Short comment displayed at the top
            'comment' => 'This template will simulate a game being run 5000 times, pushing it to Kinesis Streams',

            // Filename must be spelled the same as the filename in the config/ folder
            'filename' => 'telemetry1-2.php',

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

            // Implementation to use 
            'implementation' => 'kinesis',
        ),
        'telemetry2' => array(
            // Short comment displayed at the top
            'comment' => 'This template will simulate a game being run 1000 times, pushing it to Kinesis Firehose',

            // Filename must be spelled the same as the filename in the config/ folder
            'filename' => 'telemetry2.php',

            // Name of an existing Kiensis stream
            'streamName' => 'workshopTelemetryFHDirect',

            // Total number of entries generated
            'total' => 1000,

            // Size of the batch to send to Kinesis
            'batchSize' => 500,

            // Interval for loop in ms
            'interval' => 20000,

            // Region
            'region' => 'us-west-2',

            // Implementation to use 
            'implementation' => 'firehose',
        ),
    ),
);
