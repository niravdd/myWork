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
                'max' => '1000009999',
                'min' => '1000000000',
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
                'max' => '6',
                'min' => '1',
            ),
        ),

        'squadpower' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '12',
                'min' => '6',
            ),
        ),

        'squadagility' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '11',
                'min' => '6',
            ),
        ),

        'squadhealth' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '14',
                'min' => '5',
            ),
        ),

        'squadluck' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '1',
                'min' => '0',
            ),
        ),

        'squadspecial' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '10',
                'min' => '6',
            ),
        ),

        'squadguard' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '12',
                'min' => '8',
            ),
        ),

        'squaddamage' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '12',
                'min' => '7',
            ),
        ),

        'gameplayseconds' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '240',
                'min' => '100',
            ),
        ),

        'bosspower' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '50',
                'min' => '40',
            ),
        ),

        'bossagility' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '50',
                'min' => '40',
            ),
        ),
       
        'bosshealth' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '50',
                'min' => '40',
            ),
        ),

        'bossluck' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '1',
                'min' => '0',
            ),
        ),

        'bossspecial' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '50',
                'min' => '40',
            ),
        ),

        'bossguard' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '50',
                'min' => '40',
            ),
        ),

        'bossdamage' => array(
            'type' => 'randomNumber',
            'randomNumber' => array(
                'max' => '50',
                'min' => '40',
            ),
        ),

        'result' => array(
            'type' => 'rules',
            // Value => condition
            'rules' => array(
                'DNF' => '{gameplayseconds} < 120',
                'Won' => '((({squadpower} + {squadagility} + {squadhealth} + {squadluck} + {squadspecial} + {squadguard} + {squaddamage}) / 7) * {gameplayseconds}) >= (({bosspower} + {bossagility} + {bosshealth} + {bossluck} + {bossspecial} + {bossdamage} + {bossguard}) / 7)',
                'Lost' => '((({squadpower} + {squadagility} + {squadhealth} + {squadluck} + {squadspecial} + {squadguard} + {squaddamage}) / 7) * {gameplayseconds}) <= (({bosspower} + {bossagility} + {bosshealth} + {bossluck} + {bossspecial} + {bossdamage} + {bossguard}) / 7)'
            ),
        ),
    ),
);