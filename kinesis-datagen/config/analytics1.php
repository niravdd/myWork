<?php

return array(
    
    'distribution' => array(
        // If you want to disable the distribution, set disable to true
        'disable' => false,

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
            'type' => 'faker',
            'property' => 'ipv4'
        ),

        'handle' => array(
            'type' => 'faker',
            'property' => 'name'
        ),

        'email' => array(
            'type' => 'faker',
            'property' => 'email'
        ),

        'uuid' => array(
            'type' => 'faker',
            'property' => 'uuid'
        ),

        'playerid' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '1000000000',
                'min' => '1000009999',
            ),
        ),

        'country' => array(
            'type' => 'weightedList',
            'weightedList' => array(
                'US' => 25,
                'Japan' => 20,
                'Singapore' => 8,
                'Australia' => 10,
                'New Zealand' => 2,
                'Canada' => 15,
                'UK' => 5,
                'Malaysia' => 3,
                'Russia' => 2,
                'India' => 3,
                'Philippines' => 4,
                'Taiwan' => 3,
            ),
        ),

        'useragent' => array(
            'type' => 'weightedList',
            'weightedList' => array(
                'Mozilla Firefox' => 20,
                'Chrome' => 26,
                'Brave' => 4,
                'Safari' => 6,
                'Opera' => 6,
                'Internet Explorer' => 3,
                'Unknown' => 35,
            ),
        ),

        'datestamp' => array(
            'type' => 'date',
            'format' => 'Y-m-d H:i:sP',
        ),

        'walletbalance' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '0',
                'min' => '1200',
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
                'Player' => 91,
                'DevTest' => 8,
                'Blacklisted' => 1,
            ),        
        ),
    ),
);
