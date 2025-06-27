### Huawei Account One-Click Login

------

Server-side implementation of Huawei one-click login requires using the authorization code from the frontend to obtain user information from Huawei servers for login processing.

#### 1. Obtain Access Token

Send a **POST** request to:
`https://oauth-login.cloud.huawei.com/oauth2/v3/token`
Parameters:

- `client_id`: App ID from Huawei console
- `client_secret`: App secret key
- `code`: Authorization code from client
- `grant_type`: Fixed as `authorization_code`

Set request header: `Content-Type: application/x-www-form-urlencoded`

**PHP Example**
Install GuzzleHTTP:

```
composer require guzzlehttp/guzzle
```

Send request:

```
use GuzzleHttp\Client;

$code = 'Client authorization code';
$clientId = 'Your app ID';
$secret = 'Your app secret';

$options = [
    'http_errors' => false,
    'timeout' => 5,
    'headers' => ['Content-Type' => 'application/x-www-form-urlencoded'],
    'form_params' => [
        'client_id' => $clientId,
        'client_secret' => $secret,
        'code' => $code,
        'grant_type' => 'authorization_code'
    ]
];

try {
    $guzzle = new Client();
    $response = $guzzle->post('https://oauth-login.cloud.huawei.com/oauth2/v3/token', $options);
    $result = json_decode($response->getBody()->getContents(), true);
    // Cache access_token (valid 1 hour)
} catch (Exception $e) {
   // Handle exceptions
}
```

**Success Response**

```
{
    "access_token": "<Access Token>",
    "refresh_token": "<Refresh Token>",
    "expires_in": 3600,
    "id_token": "<ID Token>",
    "scope": "openid profile email",
    "token_type": "Bearer"
}
```

**Error Response**

```
{
    "sub_error": 12304,
    "error_description": "invalid client_secret",
    "error": 1101
}
```

#### 2. Get User Information

Send **POST** request to:
`https://account.cloud.huawei.com/rest.php?nsp_svc=GOpen.User.getInfo`
Parameter: `access_token` from previous step

**PHP Example**

```
$options = [
    'http_errors' => false,
    'timeout' => 5,
    'headers' => ['Content-Type' => 'application/x-www-form-urlencoded'],
    'form_params' => ['access_token' => $token]
];

try {
    $guzzle = new Client();
    $response = $guzzle->post('https://account.cloud.huawei.com/rest.php?nsp_svc=GOpen.User.getInfo', $options);
    $result = json_decode($response->getBody()->getContents(), true);
    $mobile = $result['mobileNumber']; // Use for login/registration
} catch (Exception $e) {
    // Handle exceptions
}
```

**Success Response**

```
{
    "displayName": "182******74",
    "displayNameFlag": 1,
    "mobileNumber": "18211111174",
    "openID": "MDFAMTAxMDA1MTg1QGFlMzM0OWIyOGY0*****",
    "unionID": "MDF9pBd6xxxxA8iaG4ZNPTw*****",
    "headPictureURL": "https://upfile-*****.jpg"
}
```

**Error Response**

```
{
    "error": "session timeout"
}
```

------

### HarmonyOS Push

------

Send push notifications using tokens reported by clients.

#### 1. Generate Authentication Token (JWT)

Create JWT with:

- **Header**: Base64-encoded JSON
- **Payload**: Base64-encoded JSON
- **Signature**: SHA256withRSA/PSS signature

**Service Account Key File** (Download from Huawei Developer Console)

```
{
    "project_id": "*****",
    "key_id": "*****",
    "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
    "sub_account": "*****",
    ...
}
```

**PHP Implementation**

```
$header = base64UrlEncode(json_encode([
    'kid' => '<key_id>',
    'typ' => 'JWT',
    'alg' => 'PS256'
]));

$payload = base64UrlEncode(json_encode([
    'aud' => 'https://oauth-login.cloud.huawei.com/oauth2/v3/token',
    'iss' => '<sub_account>',
    'exp' => time() + 3600,
    'iat' => time()
]));

$privateKeyResource = openssl_pkey_get_private($privateKey);
$unsignedToken = $header . '.' . $payload;
openssl_sign($unsignedToken, $signature, $privateKeyResource, 'sha256WithRSAEncryption');
$jwt = $unsignedToken . '.' . base64UrlEncode($signature);

function base64UrlEncode($data) {
    return str_replace('=', '', strtr(base64_encode($data), '+/', '-_'));
}
```

#### 2. Send Push Notification

Send **POST** request to:
`https://push-api.cloud.huawei.com/v3/[projectId]/messages:send`

**PHP Example**

```
$jwt = '<generated_jwt>';
$projectId = "<your_project_id>";
$token = "<device_token>";

$body = [
    'payload' => [
        'notification' => [
            'category' => 'MARKETING',
            'title' => 'Message Title',
            'body' => 'Message Content',
            'clickAction' => ['actionType' => 3] // Open app
        ]
    ],
    'target' => ['token' => [$token]]
];

$options = [
    'headers' => [
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer ' . $jwt,
        'push-type' => 0 // Notification message
    ],
    'json' => $body
];

try {
    $client = new Client();
    $resp = $client->post("https://push-api.cloud.huawei.com/v3/$projectId/messages:send", $options);
    $content = json_decode($resp->getBody()->getContents(), true);
    if ($content['code'] != '80000000') {
        // Handle failure
    }
} catch (Exception $e) {
    // Handle exceptions
}
```

**Reference**

- [Push API Documentation](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/push-scenariozed-api-request-param-V5)
- [Push Examples](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/push-scenariozed-api-request-example-V5)
