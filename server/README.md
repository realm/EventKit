# Setting up EventBlank on the server

> This is the iOS app of the EventBlank project. For an overview of the whole project head to the [main readme](../README.md).

## Setting up a Realm Object Server

All EventBlank client apps (iPhone, Android, web, etc.) connect to a Realm Object Server instance, that you run on your server, in order to provide real-time updates to the app users.

![](../assets/server.png)

You can run the server locally on your mac during development or in a Linux virtual box and install the server [Developer Edition from here for free](https://realm.io/products/realm-mobile-platform). (You can also run the free version in production for your event.)

**Requirements**: Terminal and Node.js.

**Steps to set up the server**:

**1)** Start the server and log into the dashboard ([detailed instructions here in the server docs](https://realm.io/docs/get-started/installation/mac)).

**2)** Create two users with email addresses:

* `eventblank-admin@host`
* `eventblank@host`

**3)** Make sure you have [Node.js](https://nodejs.org) installed and open a Terminal within the `server` folder of this project.

Run `npm install` to install the app's dependencies.

Create some test data in the event file via the command below. Set `delete` to `yes` in case there is existing EventBlank data you want to purge. The `amount` parameter sets how much data the script should create:

```none
node test-data.js 
  --host [YOUR_HOST] --port [YOUR_PORT] 
  --username eventblank-admin@host --password [PASSWORD] 
  --delete [yes|no]
  --amount [minimal|plenty]
```

**4)** Then execute the following command to setup the user rights on the server:

```none
node users-app.js 
  --host [YOUR_HOST] --port [YOUR_PORT] 
  --username eventblank-admin@host --password [PASSWORD] 
  --command readonly --to eventblank@host
```

Now the server and the users are all set. 

As the next step you can setup and run one of the client apps. More info in the [main readme](../README.md).

## Credits

### License

[MIT licensed.](LICENSE)

### About

<img src="../assets/realm.png" width="184" />

The names and logos for Realm are trademarks of Realm Inc.

We :heart: open source software!

See [our other open source projects](https://realm.github.io), check out [the Realm Academy](https://academy.realm.io), or say hi on twitter ([@realm](https://twitter.com/realm)).
