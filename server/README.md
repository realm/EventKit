# Setting up Realm Event Kit on the server

> This is the iOS app of the EventBlank project. For an overview of the whole project head to the [main readme](../README.md).

## Setting up a Realm Object Server

All Realm Event Kit client apps (iPhone, Android, web, etc.) connect to a Realm Object Server instance, that you run on your server, in order to provide real-time updates to the app users.

![](../assets/server.png)

You can run the server locally on your mac during development or in a Linux virtual box and install the server [Developer Edition from here for free](https://realm.io/docs/get-started/installation/developer-edition/). (You can also run the free version in production for your event.)

**Requirements**: Terminal, Node.js.

**Steps to set up the server**:

**1)** Download the Developer Edition by following the [instructions here](https://realm.io/docs/get-started/installation/developer-edition/#installing-realm-object-server).

Start Realm Object Server by running the basic demo server from your console: `ros start`. This will create some files and folders to store your realms in the current directory.

**2)** Download and install Realm Studio

To administer the server you will need to install the Realm swiss-knife - [Realm Studio](https://realm.io/docs/get-started/installation/developer-edition/#administering-realm-object-server).

Run Studio and use the default admin user (credentials are pre-filled) to connect to your locally running server.

**3)** Create two users with usernames:

* `eventblank-admin@host`
* `eventblank@host`

You should see them appear in the user list like so:

![](../assets/users.png)

**4)** Make sure you have [Node.js](https://nodejs.org) installed and open a Terminal within the `server` folder of this project.

Run `npm install` to install the app's dependencies.

Create some test data in the event file via the command below. Set `delete` to `yes` in case there is existing EventBlank data you want to purge. The `amount` parameter sets how much data the script should create:

```none
node test-data.js 
  --host [YOUR_HOST] --port [YOUR_PORT] 
  --username eventblank-admin@host --password [PASSWORD] 
  --delete [yes|no]
  --amount [minimal|plenty]
```

**5)** Find the user id of your read-only user (eventblank@host) to use with the next command. The user id you find in the users list - it's alphanumeric id in the first column:

![](../assets/user-id.png)

Then execute the following command to setup the user rights on the server:

```none
node users-app.js 
  --host [YOUR_HOST] --port [YOUR_PORT] 
  --username eventblank-admin@host --password [PASSWORD] 
  --command readonly --to [READONLY_USER_ID]
```

Now the server and the users are all set. 

As the next step you can setup and run one of the client apps. More info in the [main readme](../README.md).

## Credits

### License

Distributed under the Apache 2.0 license. See [LICENSE](../LICENSE) for more information.

### About

<img src="../assets/realm.png" width="184" />

The names and logos for Realm are trademarks of Realm Inc.

We :heart: open source software!

See [our other open source projects](https://realm.github.io), check out [the Realm Academy](https://academy.realm.io), or say hi on twitter ([@realm](https://twitter.com/realm)).
