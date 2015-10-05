# @author    Ryan Page <ryanpager@gmail.com>
# @see       https://github.com/ryanpager/angularjs-socket-cluster
# @version   1.0.0

###
>> Class Declaration
###
class Socket
  $inject: []
  constructor: ->

  # @type {boolean}
  # @description
  # This variable determines whether or not debugging will be thrown through
  #  the console for every socket event that comes through.
  debuggingEnabled = false

  # @type {socketCluster}
  # @description
  # This variable represents the current instance of the socket and all
  #  functionality within it.
  instance = null

  # @type {object}
  # @description
  # This variable represents the default settings for the socket connection
  #  capability.
  connectionOptions =
    autoReconnect: true
    protocol: 'http'
    hostname: '127.0.0.1'
    port: 8000

  # @name $get
  # @type {function}
  # @description
  # This is a magic method which will allow the service to be returned while
  #  injected with the correct configuration variables.
  # @return {object}
  $get: ['socketCluster', '$rootScope', '$log', '$timeout', (socketCluster, $rootScope, $log, $timeout) ->
    return service =
      # @name toggleDebugging
      # @type {function}
      # @description
      # Toggle the debugging state for the socket connection.
      # @param {boolean} enabled
      toggleDebugging: (enabled = false) ->
        debuggingEnabled = enabled

      # @name connect
      # @type {function}
      # @description
      # This function will connect a socket server given the explicit default
      #  connection options and the overriden connection options supplied.
      # @param {object} opts
      connect: (opts = {}) ->
        # Merge in options with the defaults
        angular.merge connectionOptions, opts

        if debuggingEnabled
          $log.info('Socket :: Attempting connection...')

        # Create the connection
        instance = socketCluster.connect connectionOptions

        # Bind the socket events
        instance.on 'error', (err) ->
          $log.error("Socket :: Error >> #{err}")

        instance.on 'connectAbort', (err) ->
          $log.error("Socket :: Connection aborted >> #{err}")

        instance.on 'connect', ->
          if debuggingEnabled
            $log.info('Socket :: Connection successful!')

        instance.on 'subscribeFail', (err) ->
          $log.error("Socket :: Failed channel subscription >> #{err}")

      # @name subscribe
      # @type {function}
      # @description
      # This function will subscribe to a specific channel on the socket server
      #  so that events can be broadcasted down the scope.
      # @param {string} channel
      subscribe: (channel = null) ->
        # Make sure that we have a channel provided before we subscribe
        #  to any events that are going on.
        unless channel?
          $log.error('Socket :: Error >> no socket channel specified.')
          return

        # Make sure we have a socket connection
        unless instance?
          $log.error('Socket :: Error >> no socket connection established.')
          return

        # Debugging
        if debuggingEnabled
          $log.info("Socket :: Subscribe to channel #{channel}")

        # Subscribe to the channel and bind the event watcher so that we can
        #  rebroadcast any information coming through the channel
        instance.subscribe channel
        instance.watch channel, (eventData) ->
          # Error handling
          if eventData.$error?
            if debuggingEnabled
              $log.error("Socket :: Event error >> #{JSON.stringify(eventData)}")
            return

          # Debugging
          if debuggingEnabled
            $log.info("Socket :: Event received >> #{JSON.stringify(eventData)}")

          $timeout ->
            $rootScope.$apply ->
              if debuggingEnabled
                $log.info("Socket :: Rebroadcast event >> #{eventData.$event}")

              $rootScope.$broadcast """socket:#{eventData.$event}""", eventData

      # @name unsubscribe
      # @type {function}
      # @description
      # This function will unsubscribe to a specific channel on the socket server
      #  so that no more channel events are broadcasted.
      # @param {string} channel
      unsubscribe: (channel = null) ->
        # Make sure that we have a channel provided before we subscribe
        #  to any events that are going on.
        unless channel?
          $log.error('Socket :: Error >> no socket channel specified.')
          return

        # Make sure we have a socket connection
        unless instance?
          $log.error('Socket :: Error >> no socket connection established.')
          return

        # Debugging
        if debuggingEnabled
          $log.info("Socket :: Unsubscribe to channel #{channel}")

        instance.unsubscribe channel
        instance.unwatch channel

      # @name subscriptions
      # @type {function}
      # @description
      # This function will return an array of active channel subscriptions
      #  in array format.
      subscriptions: ->
        # Make sure we have a socket connection
        unless instance?
          $log.error('Socket :: Error >> no socket connection established.')
          return

        return instance.subscriptions()

      # @name isSubscribed
      # @type {function}
      # @description
      # This function will return a boolean indicator as to whether or not this
      #  socket instance is subscribed to the supplied channel name.
      # @param {string} channel
      isSubscribed: (channel) ->
        # Make sure we have a socket connection
        unless instance?
          $log.error('Socket :: Error >> no socket connection established.')
          return

        return instance.isSubscribed(channel)

      # @name public
      # @type {function}
      # @description
      # This function will publish data to a specific channel so that all
      #  subscribers get notified of its information.
      # @param {string} channel
      # @param {object} eventdata
      publish: (channel = null, eventData = {}) ->
        # Make sure that we have a channel provided before we subscribe
        #  to any events that are going on.
        unless channel?
          $log.error('Socket :: Error >> no socket channel specified.')
          return

        # Make sure we have a socket connection
        unless instance
          $log.error('Socket :: Error >> no socket connection established.')
          return

        # Debugging
        if debuggingEnabled
          $log.info("Socket :: Event published to #{channel} >> #{JSON.stringify(eventData)}")

        instance.publish channel, eventData
  ]

###
>> Module Declaration
###
angular
  .module 'sbb.components', []
  .constant 'socketCluster', socketCluster
  .provider 'sbb.components.socket', Socket
