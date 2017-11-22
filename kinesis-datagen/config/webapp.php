<?php

return array(
    // List of config profiles available 
    'configProfiles' => array(
        'game' => array(
            // Short comment displayed at the top
            'comment' => 'This template will generate some youpi ...',

            // Filename must be spelled the same as the filename in the config/ folder
            'filename' => 'game-base.template.php',

            // Name of an existing Kiensis stream
            'streamName' => 'elasticsearch-stream-01',

            // Total number of entries generated
            'total' => 500,

            // Size of the batch to send to Kinesis
            'batchSize' => 400,

            // Interval for loop in ms
            'interval' => 10000,

            // Region
            'region' => 'us-west-2',
        ),
        'player' => array(
            // Short comment displayed at the top
            'comment' => 'This template will generate some blah blah ...',

            // Filename must be spelled the same as the filename in the config/ folder
            'filename' => 'sample.template.php',

            // Name of an existing Kiensis stream
            'streamName' => 'stream01',

            // Total number of entries generated
            'total' => 1000,

            // Size of the batch to send to Kinesis
            'batchSize' => 800,

            // Interval for loop in ms
            'interval' => 20000,

            // Region
            'region' => 'us-west-2',
        ),
    ),
);
