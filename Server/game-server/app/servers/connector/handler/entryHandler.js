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
 var index = 0;
Handler.prototype.entry = function(msg, session, next) {
	console.log(msg);
	var self = this;
  session.bind(++index);
	var channel = this.channelService.getChannel('hall', true);
  if( !! channel) {
      var serverid =self.app.getServerId();
      channel.add(index, serverid);
  }


  session.on('closed', onUserLeave.bind(null, self.app, session));        
  next(null, {code: 200, 
    msg: ['game server is ok.','aadfafasdf'],
    fl:[1.2,23,12.3],
    dou:3.4,
    obj:[{a:'a',b:2},{a:'b',b:4}]});
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
  	next(null);
};


Handler.prototype.proto = function(msg, session, next) {


  console.log(msg);


  next(null, {code: 200, msg: 'game server is ok.'});
}



var onUserLeave = function (app, session) {
  console.log('user %j level',session.uid );
}
