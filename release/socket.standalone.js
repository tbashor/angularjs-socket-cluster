/**
 * AngularJS SocketCluster Interface
 * @author Ryan Page <ryanpager@gmail.com>
 * @version v1.0.0
 * @see https://github.com/ryanpager/angularjs-socketCluster#readme
 * @license MIT
 */
(function() { 'use strict'; 
/*
>> Class Declaration
 */
var Socket;

Socket = (function() {
  var connectionOptions, debuggingEnabled, instance;

  Socket.prototype.$inject = [];

  function Socket() {}

  debuggingEnabled = false;

  instance = null;

  connectionOptions = {
    autoReconnect: true,
    protocol: 'http',
    hostname: '127.0.0.1',
    port: 8000
  };

  Socket.prototype.$get = [
    'socketCluster', '$rootScope', '$log', '$timeout', function(socketCluster, $rootScope, $log, $timeout) {
      var service;
      return service = {
        toggleDebugging: function(enabled) {
          if (enabled == null) {
            enabled = false;
          }
          return debuggingEnabled = enabled;
        },
        connect: function(opts) {
          if (opts == null) {
            opts = {};
          }
          angular.merge(connectionOptions, opts);
          if (debuggingEnabled) {
            $log.info('Socket :: Attempting connection...');
          }
          instance = socketCluster.connect(connectionOptions);
          instance.on('error', function(err) {
            return $log.error("Socket :: Error >> " + err);
          });
          instance.on('connectAbort', function(err) {
            return $log.error("Socket :: Connection aborted >> " + err);
          });
          instance.on('connect', function() {
            if (debuggingEnabled) {
              return $log.info('Socket :: Connection successful!');
            }
          });
          return instance.on('subscribeFail', function(err) {
            return $log.error("Socket :: Failed channel subscription >> " + err);
          });
        },
        subscribe: function(channel) {
          if (channel == null) {
            channel = null;
          }
          if (channel == null) {
            $log.error('Socket :: Error >> no socket channel specified.');
            return;
          }
          if (instance == null) {
            $log.error('Socket :: Error >> no socket connection established.');
            return;
          }
          if (debuggingEnabled) {
            $log.info("Socket :: Subscribe to channel " + channel);
          }
          instance.subscribe(channel);
          return instance.watch(channel, function(eventData) {
            if (eventData.$error != null) {
              if (debuggingEnabled) {
                $log.error("Socket :: Event error >> " + (JSON.stringify(eventData)));
              }
              return;
            }
            if (debuggingEnabled) {
              $log.info("Socket :: Event received >> " + (JSON.stringify(eventData)));
            }
            return $timeout(function() {
              return $rootScope.$apply(function() {
                if (debuggingEnabled) {
                  $log.info("Socket :: Rebroadcast event >> " + eventData.$event);
                }
                return $rootScope.$broadcast("socket:" + eventData.$event, eventData);
              });
            });
          });
        },
        unsubscribe: function(channel) {
          if (channel == null) {
            channel = null;
          }
          if (channel == null) {
            $log.error('Socket :: Error >> no socket channel specified.');
            return;
          }
          if (instance == null) {
            $log.error('Socket :: Error >> no socket connection established.');
            return;
          }
          if (debuggingEnabled) {
            $log.info("Socket :: Unsubscribe to channel " + channel);
          }
          instance.unsubscribe(channel);
          return instance.unwatch(channel);
        },
        subscriptions: function() {
          if (instance == null) {
            $log.error('Socket :: Error >> no socket connection established.');
            return;
          }
          return instance.subscriptions();
        },
        isSubscribed: function(channel) {
          if (instance == null) {
            $log.error('Socket :: Error >> no socket connection established.');
            return;
          }
          return instance.isSubscribed(channel);
        },
        publish: function(channel, eventData) {
          if (channel == null) {
            channel = null;
          }
          if (eventData == null) {
            eventData = {};
          }
          if (channel == null) {
            $log.error('Socket :: Error >> no socket channel specified.');
            return;
          }
          if (!instance) {
            $log.error('Socket :: Error >> no socket connection established.');
            return;
          }
          if (debuggingEnabled) {
            $log.info("Socket :: Event published to " + channel + " >> " + (JSON.stringify(eventData)));
          }
          return instance.publish(channel, eventData);
        }
      };
    }
  ];

  return Socket;

})();


/*
>> Module Declaration
 */

angular.module('sbb.components', []).constant('socketCluster', socketCluster).provider('sbb.components.socket', Socket);
 })();