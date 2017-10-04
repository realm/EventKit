# EventBlank for iOS

This is the iOS app of the EventBlank project. For an overview of the whole project head to the [main readme](#).

[ image ]

## Installation

### Setting up a Realm Object Server

EventBlank for iOS connects to a Realm Object Server to provide real-time updates to the app users. Before building the iOS project you will need to set up a server to test with. You can run it locally on your mac or in a Linux virtual box and install [Developer Edition from here for free](https://realm.io/products/realm-mobile-platform).

1) Start the server and log into the dashboard ([server docs](https://realm.io/docs/get-started/installation/mac)).

2) Create two users with email addresses:

* `eventblank-admin@host`
* `eventblank@host`

3) Make sure you have [Node.js](https://nodejs.org) installed and open a Terminal within the `server` folder of this project.

Run `npm install` to install the app's dependencies and then execute the following command to setup the user rights on the server:

```
node users-app.js 
  --host [YOUR_HOST] --port [YOUR_PORT] 
  --username [USERNAME] --password [PASSWORD] 
  --command readonly --to [SECOND_USERNAME]
```

The script will give the second user read-only access to the shared file and print in the console something along the lines of:

```
[app] Granting read permission to seconduser@host
[app] permission granted on realm://localhost:9080/c2edd0e813aedf8dc8ad026a243d71d1/eventblank
```

Now the server and the users are all set.

### Setting up the iOS project

In the **iOS** folder of this project copy the file `example-set-keys.sh` to `keys-local.sh` and edit the new file setting the placeholder values with your own. Here's an example with a test account but you have to fill in your own data:

![](../assets/config.png)

From the console make the file executable (line 1) and run it (line 2):

```
chmod +x keys-local.sh
./keys-local.sh
```

This will configure the connection data to your server and install all iOS project dependencies.

### Running EventBlank for iOS

At that point you can open **EventBlank2-iOS.xcworkspace** in Xcode, build and run the app. If you don't have the minimum required data entered into the synchronized file the app will wait for it to be synced down before showing any UI.



## Credits

### License

[MIT licensed.](LICENSE)

### About

<img src="../assets/realm.png" width="184" />

The names and logos for Realm are trademarks of Realm Inc.

We :heart: open source software!

See [our other open source projects](https://realm.github.io), check out [the Realm Academy](https://academy.realm.io), or say hi on twitter ([@realm](https://twitter.com/realm)).
