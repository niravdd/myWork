<?php
return array(
    
    'distribution' => array(
        // If you want to disable the distribution, set disable to true
        'disable' => true,

        'fields' => array(
            'result' => array(
                'Won' => 52,
                'Lost' => 43,
                'DNF' => 5,
            ),
        ),
    ),

    'fields' => array(

        'datestamp' => array(
            'type' => 'date',
            'format' => 'Y-m-d H:i:sP',
        ),

        'playerid' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '1000000000',
                'min' => '1000009999',
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

        'squadelementmap' => array(
            'type' => 'weightedList',
            'weightedList' => array(
                'Earth' => 20,
                'Water' => 30,
                'Fire' => 10,
                'Air' => 25,
                'Space' => 15,
            ),
        ),

        'gamenumber' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '1',
                'min' => '6',
            ),
        ),

        'squadpower' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '4',
                'min' => '14',
            ),
        ),

        'squadagility' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '6',
                'min' => '16',
            ),
        ),

        'squadhealth' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '8',
                'min' => '12',
            ),
        ),

        'squadluck' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '0',
                'min' => '1',
            ),
        ),

        'squadspecial' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '10',
                'min' => '18',
            ),
        ),

        'squadguard' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '10',
                'min' => '12',
            ),
        ),

        'squaddamage' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '10',
                'min' => '15',
            ),
        ),

        'gameplayseconds' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '120',
                'min' => '240',
            ),
        ),

        'bosspower' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '40',
                'min' => '50',
            ),
        ),

        'bossagility' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '40',
                'min' => '50',
            ),
        ),
       
        'bosshealth' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '40',
                'min' => '50',
            ),
        ),

        'bossluck' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '0',
                'min' => '1',
            ),
        ),

        'bossspecial' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '40',
                'min' => '50',
            ),
        ),

        'bossguard' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '40',
                'min' => '50',
            ),
        ),

        'bossdamage' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '40',
                'min' => '70',
            ),
        ),

        'result' => array(
            'type' => 'rules',
            // Value => condition
            'rules' => array(
                'Won' => '{squadpower} + {squadluck} + {squadguard} + {squadagility} > {bossguard}',
                'Lost' => '{squadpower} + {squadluck} + {squadguard} + {squadagility} < {bossguard} - 3',
                'DNF' => '{squadpower} + {squadluck} + {squadguard} + {squadagility} <= {bossguard}',
            ),        
        ),
    ),
);
