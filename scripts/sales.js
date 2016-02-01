module.exports = function(robot) {

    function getTimeForWhiskeyAuth() {
        var username = process.env['TIMEFORWHISKEY_USERNAME'];
        var password = process.env['TIMEFORWHISKEY_PASSWORD'];
        return new Buffer(username + ':' + password).toString('base64');
    }

    function timeForWhiskey(reply) {
        robot.http('http://timeforwhiskey.kidizen.com/sales')
            .header('Authorization', 'Basic ' + getTimeForWhiskeyAuth())
            .header('Accept', 'application/json')
            .get()(function(err, res, body) {
                res = res || {};
                if (!err && body) {
                    body = JSON.parse(body);
                    if (body.success) {
                        reply.send('Yes! :whiskey');
                    } else {
                        reply.send('Not yet. ($' + body.total  + ')');
                    }
                }
           });
    }

    robot.respond(/is it whiskey time.*/i, function(reply) {
        timeForWhiskey(reply);
    });
    robot.respond(/is it time for whiskey.*/i, function(reply) {
        timeForWhiskey(reply);
    });

    robot.respond(/sales/i, function(reply) {

        robot.http('http://timeforwhiskey.kidizen.com/sales')
            .header('Authorization', 'Basic ' + getTimeForWhiskeyAuth())
            .header('Accept', 'application/json')
            .get()(function(err, res, body) {
                res = res || {};
                if (!err && body) {
                    body = JSON.parse(body);
                    reply.send('$' + body.total + ' (:ios: $' + body.ios + ', :android: $' + body.android + ')');
                }
            });
    });
}
