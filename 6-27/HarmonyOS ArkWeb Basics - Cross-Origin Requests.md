# HarmonyOS ArkWeb Basics - Cross-Origin Requests

ArkWeb kernel restricts cross-origin access for file and resource protocols by default due to security considerations. This means that if a Web component attempts to load resources from different domains using file or resource protocols, the request will be blocked, preventing resource loading.

For example, suppose your Web component is deployed on Domain A and you want to load local resources from Domain B, such as images or script files. Due to file and resource protocol restrictions, even if your Web component can access Domain B's URL, it cannot load local resources on Domain B.

This cross-origin issue may cause:

- **Limited functionality**: Web components may fail to load necessary resources, resulting in restricted functionality.
- **Degraded user experience**: Users may encounter page loading failures or non-functional features.
- **Security risks**: Improper handling of cross-origin issues may lead to security vulnerabilities like Cross-Site Scripting (XSS).

## Solutions

To address cross-origin issues in ArkWeb framework, consider these solutions:

### 1. Use HTTP/HTTPS protocols instead of file/resource protocols
This is the most direct and effective solution. Modify resource URLs from file/resource protocols to HTTP/HTTPS protocols, ensuring the resource server supports cross-origin access.

Example:  
Change `file://example.com/path/to/image.png` to  
`http://example.com/path/to/image.png` or  
`https://example.com/path/to/image.png`

### 2. Use custom domains
Create a custom domain for your local resources and ensure it resolves to your local resources. This avoids triggering ArkWeb kernel's cross-origin restrictions for file/resource protocols.

Example:  
Point custom domain `example.com` to your local resource path and access via:  
`http://example.com/path/to/image.png`

### 3. Use onInterceptRequest for local resource interception
Use ArkWeb's `onInterceptRequest` interface to intercept local resource requests and provide custom responses, bypassing cross-origin restrictions.

Example:  
Intercept file/resource protocol requests and return custom content responses.

## Core Network Security Concepts

Beyond solving cross-origin issues, understand these fundamental security concepts:

### 1. CORS Policy
Cross-Origin Resource Sharing (CORS) controls resource sharing between different domains. Configure CORS policies to allow/block cross-origin requests from specific domains.

Example:  
Set CORS policy on resource server to allow requests from Domain A while blocking others.

### 2. Same-Origin Policy
A browser security mechanism preventing malicious websites from stealing data from other sites. Requires identical protocol, domain, and port for resource access.

### 3. HTTPS Protocol
Secure version of HTTP using SSL/TLS encryption to protect data transmission security. Essential for sensitive data like personal information and passwords.

## Code Example

This example demonstrates using `onInterceptRequest` to intercept local resource requests:

	```javascript
	import { webview } from '@ohos.web.webview';
	
	@Entry
	@Component
	struct WebComponent {
	  controller: webview.WebviewController = new webview.WebviewController();
	  responseResource: webview.WebResourceResponse = new webview.WebResourceResponse();
	  
	  build() {
	    Column() {
	      Web({ src: $rawfile("index.html"), controller: this.controller })
	        .onInterceptRequest((event) => {
	          if (event && event.request.getRequestUrl().startsWith("file://")) {
	            // Intercept file protocol requests
	            this.responseResource.setResponseData($rawfile("local.png"));
	            this.responseResource.setResponseEncoding('utf-8');
	            this.responseResource.setResponseMimeType('image/png');
	            this.responseResource.setResponseCode(200);
	            this.responseResource.setReasonMessage('OK');
	            return this.responseResource;
	          }
	          return null;
	        });
	    }
	  }
	}
	```

## Summary

The ArkWeb framework provides powerful web application development capabilities but requires attention to network security, especially regarding cross-origin requests. By understanding common cross-origin issues and their solutions, along with fundamental network security knowledge, you can develop more secure and reliable web applications that protect user privacy and data security.