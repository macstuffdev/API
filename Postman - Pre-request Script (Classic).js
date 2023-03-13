let encodedAuth = btoa(pm.collectionVariables.get('username') + ':' + pm.collectionVariables.get('password'));

let CleanURL = (pm.collectionVariables.get('baseUrl'))
CleanURL = CleanURL.split('/JSSResource')[0];
console.log(CleanURL)

const echoPostRequest = {
  url: CleanURL + '/uapi/auth/tokens',
  method: 'POST',
  header: 'Authorization: Basic ' + encodedAuth,
};

var getToken = true;
var accessTokenExpiry = pm.globals.get('accessTokenExpiry');
var currentTime = new Date().toISOString();
console.log("Expires: " + accessTokenExpiry + " Current: " + currentTime);

if (!pm.globals.get('accessTokenExpiry') || 
    !pm.globals.get('currentAccessToken')) {
    console.log('Token or expiry date are missing')
} else if (accessTokenExpiry <= currentTime) {
    console.log('Token is expired')
} else {
    getToken = false;
    console.log('Token and expiry date are all good');
}

if (getToken === true) {
    pm.sendRequest(echoPostRequest, function (err, res) {
    console.log(err ? err : res.json());
        if (err === null) {
            console.log('Saving the token and expiry date')
            var responseJson = res.json();
            pm.globals.set('currentAccessToken', responseJson.token)
    
            var expiryDate = new Date(responseJson.expires);
            pm.globals.set('accessTokenExpiry', expiryDate);
        }
    });
}