const Twitter = require('twitter');
const getBearerToken = require('get-twitter-bearer-token');

const consumer_key = process.env.CONSUMER;
const consumer_secret = process.env.SECRET;

exports.handler = function (event, context)
{
    getBearerToken(consumer_key, consumer_secret, (err, res) =>
    {
        if (err)
        {
            // handle error
        } else
        {
            var client = new Twitter({
                consumer_key: consumer_key,
                consumer_secret: consumer_secret,
                bearer_token: res.body.access_token
            });
            client.get('statuses/user_timeline', { 'screen_name': process.env.SCREEN_NAME, 'exclude_replies': true, 'count': 100 }, function (error, tweets, clientResponse)
            {
                if (error) throw error;
                const tweet = tweets[Math.floor(Math.random() * tweets.length)];
                const tweetJSON = JSON.stringify(tweet);
                context.succeed({
                    statusCode: 200,
                    body: tweetJSON
                });
            });
        }
    });
};