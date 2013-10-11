module.exports = function(app) {
  return new Handler(app);
};

var Handler = function(app) {
  this.app = app;
  this.channelService = app.get('channelService');
};

/**
 * New client entry chat server.
 *
 * @param  {Object}   msg     request message
 * @param  {Object}   session current session object
 * @param  {Function} next    next stemp callback
 * @return {Void}
 */
Handler.prototype.entry = function(msg, session, next) {
	console.log(msg);
	var self = this;
  session.bind(1);
	var channel = this.channelService.getChannel('hall', true);
        if( !! channel) {
        	var serverid =self.app.getServerId();
            channel.add(1, serverid);
        }
  next(null, {code: 200, msg: 'game server is ok.'});
};
Handler.prototype.push = function(msg, session, next) {
	
	var channel = this.channelService.getChannel('hall', false);
        if( !! channel) {
           var param = {
               	route: 'onRoomStand',
                position: 1
            };
            channel.pushMessage('onRoomStand',param,function(){
              console.log('adfasdfadsf');
            });
            console.log('fale aaaa');
        }
  	next(null, {code: 200, msg: 'game server is ok.'});
};