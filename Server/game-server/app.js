var pomelo = require('pomelo');

/**
 * Init app for client.
 */
var app = pomelo.createApp();
app.set('name', 'Server');

// app configuration
app.configure('production|development', 'connector', function(){
	app.set('connectorConfig',
		{
			connector : pomelo.connectors.hybridconnector,
			heartbeat : 15,
			// disconnectOnTimeout: true,

			handshake: function(msg, cb){
				console.log('握手');
				console.log(msg);
				cb(null,{
					code:200,
					str : 'aaaa'
				})
			}
		});
});

// start app
app.start();

process.on('uncaughtException', function (err) {
  console.error(' Caught exception: ' + err.stack);
});
