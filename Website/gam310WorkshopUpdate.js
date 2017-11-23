console.log('Loading function');
var AWS = require('aws-sdk');

exports.handler = (event, context, callback) => {
    //console.log('[EVENT]', event);
    //console.log('[CNTXT]', context);
    
    var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
    var params = {
        TableName: 'gam310Workshop',
        Item: {
            'Seat': {N: event.seat},
            'Lab': {N: event.lab}
        }
    };
    
    ddb.putItem(params, function(err, data) {
        if (err) {
            context.fail('Failed to update DynamoDB table');
            console.log(err);
        } else {
            context.succeed('Successfully updated DynamoDB table');
        }
    });
};