<?php

return array(
    
    'distribution' => array(
        // If you want to disable the distribution, set disable to true
        'disable' => true,

        'fields' => array(
            'status' => array(
                'active' => 7,
                'premium' => 9,
                'inactive' => 3,
            ),
        ),
    ),

    'fields' => array(
        'playerip' => array(
            'type' => 'randomList',
            'randomList' => array(
                '1.1.1.1',
                '2.2.2.2',
                '3.3.3.3',
                '4.4.4.4',
                '5.5.5.5',
                '6.6.6.6',
                '7.7.7.7',
                '8.8.8.8',
                '9.9.9.9',
            ),
        ),

        'handle' => array(
            'type' => 'randomList',
            'randomList' => array(
                'cloudy',
                'cloudinator',
                'awsome',
                'cloudymccloudison',
                'lambdanator',
                'cognitology',
                'kinsismaster',
                'firehosinnoobs',
                'awsrocks',
            ),
        ),

        'email' => array(
            'type' => 'randomList',
            'randomList' => array(
                'a@b.com',
                'b@c.com',
                'c@d.com',
                'd@e.com',
            ),
        ),

        'uuid' => array(
            'type' => 'randomList',
            'randomList' => array(
                'q3g4gq3',
                'h45w6jn',
                '3ddghhd',
                '4tg3qgg',
                '42ty43q',
                'g5w4hh4',
            ),
        ),

        'playerid' => array(
            'type' => 'randomList',
            'randomList' => array(
                '41234125',
                '23152532',
                '46264577',
                '97505679',
                '17437347',
                '47274246',
            ),
        ),

        'country' => array(
            'type' => 'randomList',
            'randomList' => array(
                'south korea',
                'australia',
                'japan',
                'singapore',
                'russia',
                'new zealand',
                'china',
                'india',
                'usa',
            ),
        ),

        'useragent' => array(
            'type' => 'randomList',
            'randomList' => array(
                'firefox',
                'chrome',
                'ielol',
                'edge',
                'sarafi',
            ),
        ),

        'datestamp' => array(
            'type' => 'date',
            'format' => 'Y-m-d H:i:sP',
        ),

        'walletbalance' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '1',
                'min' => '1000',
            ),
        ),
        
        'playerlevel' => array(
            'type' => 'weightedList',
            'weightedList' => array(
                'Level 1' => 5,
                'Level 2' => 10,
                'Level 3' => 12,
                'Level 4' => 5,
                'Level 5' => 3,
                'Level 6' => 7,
                'Level 7' => 13, 
                'Level 8' => 3, 
                'Level 9' => 15,
            ),
        ),

        'status' => array(
            'type' => 'weightedList',
            'weightedList' => array(
                'active' => 5,
                'premium' => 3,
                'inactive' => 8,
            ),        
        ),
    ),
);
