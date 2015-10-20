<a name="1.1.3"></a>
### 1.1.3 (2015-10-20)

* Squelch "true" errors that come back from single.publish events.

<a name="1.1.2"></a>
### 1.1.2 (2015-10-20)

* Add in listening for individual socket events rather than just events on the
channel. This will allow servers to broadcast individually.

<a name="1.1.1"></a>
### 1.1.1 (2015-10-20)

* Fix the resolution of promises. They were blindly resolving rather than
making sure the proper events fired.

<a name="1.1.0"></a>
### 1.1.0 (2015-10-06)

* Made all of the public api promisified for easier use and better control
over the flow of the application
* Fixed numerous bugs with the socket interface (broadcasting events, etc)

<a name="1.0.0"></a>
### 1.0.0  (2015-10-05)

#### Features

* Added initial commit files to the repository which sets up the interface
functionality, error handling, etc etc.
* Added initial documentation (api and usage) to the repository
