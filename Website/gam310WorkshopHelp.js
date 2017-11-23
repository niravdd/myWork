console.log('Loading function');

const https = require('https');
const url = require('url');
const slack_url = 'https://hooks.slack.com/services/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';
const slack_req_opts = url.parse(slack_url);
slack_req_opts.method = 'POST';
slack_req_opts.headers = {
    'Content-Type': 'application/json'
};

exports.handler = (event, context, callback) => {
    //console.log('[EVENT]', event);
    //console.log('[CNTXT]', context);
    
    var req = https.request(slack_req_opts, function(res) {
        if (res.statusCode === 200) {
            context.succeed('Successfully sent request for help');
        } else {
            context.fail('Failed sending request for help; Status code: ' + res.statusCode);
        }
    });
    
    req.on('error', function(e) {
        console.log('Problem with request: ' + e.message);
        context.fail(e.message);
    });
    
    var text_msg = 'Help has been requested from the participant at seat ' + event.seat + '.';

    var params = {
        attachments: [{
            fallback: text_msg,
            pretext: 'Seat ' + event.seat,
            color: "#D00000",
            fields: [{
                "value": text_msg,
                "short": false
            }]
        }]
    };
    req.write(JSON.stringify(params));

    req.end();    
};