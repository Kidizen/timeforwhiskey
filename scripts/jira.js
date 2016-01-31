module.exports = function(robot) {
    robot.respond(/create ([A-Za-z]+) for ([A-Za-z]+) (.*)/i, function(reply) {

        var type, component;
        var rawType = (reply.match[1] || '').toLowerCase().trim();
        var rawComponent = (reply.match[2] || '').toLowerCase().trim();
        var text = (reply.match[3] || '').toLowerCase().trim();

        if (rawType === 'story') {
            type = 'Story';
        } else if (rawType === 'bug') {
            type = 'Bug';
        }

        if (!type) {
            reply.send("Sorry, I don't know how to create a '" + rawType + "'");
            return;
        }

        if (rawComponent === 'baseservice') {
            component = 'BaseService';
        } else if (rawComponent === 'ios') {
            component = 'iOS';
        } else if (rawComponent === 'android') {
            component = 'Android';
        }

        if (!component) {
            reply.send("Sorry, I don't know the component '" + rawComponent + "'");
            return;
        }

        var username = process.env['JIRA_USERNAME'];
        var password = process.env['JIRA_PASSWORD'];
        var auth = new Buffer(username + ':' + password).toString('base64');

        reply.send('One sec...');

        robot.http('https://itizen.atlassian.net/rest/api/2/issue/')
            .header('Authorization', 'Basic ' + auth)
            .header('Content-Type', 'application/json')
            .post(JSON.stringify({
                'fields': {
                    'project': {'key': 'KID'},
                    'summary': text,
                    'issuetype': {'name': type},
                    'components':[{'name': component}]
                }
            }))(function(err, res, body) {
                res = res || {};
                if (!err && res.statusCode === 201 && body) {
                    body = JSON.parse(body);
                    reply.send('https://itizen.atlassian.net/browse/' + body.key);
                } else {
                    reply.send("I failed. I couldn't create that story.");
                }
            });
    });
}
