# ArkWeb Page Interception and Custom Response: Controlling the Loading Process

#### Introduction

In web application development, precise control over the page loading process is often required—such as intercepting specific requests and returning customized responses. The ArkWeb framework empowers developers to achieve this by intercepting page and resource loading requests, enabling custom responses. This article delves into how to implement these capabilities using ArkWeb, supported by code examples.

------

#### Intercepting Page Loading Requests

##### Using `onLoadIntercept` to Intercept Page Loading Requests

ArkWeb’s `onLoadIntercept` interface allows developers to intercept page requests before they load, enabling URL inspection, request modification, or custom content injection.

```
export default {
  onCreate() {
    this.controller.onLoadIntercept((request) => {
      const url = request.url;
      if (url.includes('special-page')) {
        // Intercept special pages and return custom content
        return this.handleSpecialPage(url);
      }
      // Allow other requests to proceed
      return false;
    });
  },
  handleSpecialPage(url) {
    // Return different custom pages based on URL
    if (url.endsWith('/about')) return this.createAboutPage();
    if (url.endsWith('/contact')) return this.createContactPage();
    // Default: Return a 404 page
    return this.createNotFoundPage();
  },
  createAboutPage() { /* ... */ },
  createContactPage() { /* ... */ },
  createNotFoundPage() { /* ... */ }
};
```

##### Using `onInterceptRequest` to Intercept Resource Loading Requests

For resource requests (e.g., images, CSS, JavaScript), use the `onInterceptRequest` interface:

```
export default {
  onCreate() {
    this.controller.onInterceptRequest((request) => {
      const url = request.url;
      if (url.includes('custom-script')) 
        return this.createCustomScriptResponse();
      if (url.includes('custom-style')) 
        return this.createCustomStyleResponse();
      return false; // Bypass other resources
    });
  },
  createCustomScriptResponse() { /* ... */ },
  createCustomStyleResponse() { /* ... */ }
};
```

------

#### Returning Custom Responses

##### Returning Custom Page Content

To intercept a page request and return custom HTML:

```
createCustomPageResponse(htmlContent) {
  const response = new WebResourceResponse(
    'text/html',
    'UTF-8',
    200,
    'OK',
    { 'Content-Type': 'text/html' },
    htmlContent
  );
  return response;
}
```

##### Returning Custom File Resources

For resource requests (e.g., images, scripts), return processed files:

```
createCustomFileResponse(mimeType, fileContent) {
  const response = new WebResourceResponse(
    mimeType,
    'UTF-8',
    200,
    'OK',
    { 'Content-Type': mimeType },
    fileContent
  );
  return response;
}
```

------

#### Complete Example Code

This example demonstrates intercepting page requests and resource requests:

```
export default {
  onCreate() {
    // Intercept page requests
    this.controller.onLoadIntercept((request) => {
      const url = request.url;
      if (url.includes('special-page')) 
        return this.handleSpecialPage(url);
      return false;
    });
    
    // Intercept resource requests
    this.controller.onInterceptRequest((request) => {
      const url = request.url;
      if (url.includes('custom-script')) 
        return this.createCustomScriptResponse();
      if (url.includes('custom-style')) 
        return this.createCustomStyleResponse();
      return false;
    });
  },
  handleSpecialPage(url) { /* ... */ },
  createCustomScriptResponse() {
    const scriptContent = 'console.log("Hello from custom script!");';
    return this.createCustomFileResponse('application/javascript', scriptContent);
  },
  createCustomStyleResponse() {
    const styleContent = 'body { background-color: #f0f0ff; }';
    return this.createCustomFileResponse('text/css', styleContent);
  },
  createCustomFileResponse(mimeType, fileContent) {
    const response = new WebResourceResponse(
      mimeType,
      'UTF-8',
      200,
      'OK',
      { 'Content-Type': mimeType },
      fileContent
    );
    return response;
  }
};
```

------

#### Conclusion

ArkWeb’s interception capabilities enable developers to customize loading processes for enhanced performance, security, and functionality. Use cases include permission control, ad blocking, content replacement, and more. By leveraging these APIs, you can build robust, tailored experiences in the HarmonyOS ecosystem.