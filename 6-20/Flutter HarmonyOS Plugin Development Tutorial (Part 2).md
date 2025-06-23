# Flutter HarmonyOS Plugin Development Tutorial (Part 2)

------

## I. Implement Custom Alipay Plugin Callbacks and Events

### 1. **Alipay Official Documentation**

[Alipay Payment SDK Documentation](https://opendocs.alipay.com/open/0f71b5?pathHash=bedc38ba)

------

## 2. **Installation & Usage**

### 2.1 **Installation Instructions**

Install via the HarmonyOS package manager:

```
ohpm install @cashier_alipay/cashiersdk
```

**Note**: SDK versions ≥ **15.8.27** require Alipay client **v10.6.50+**.

------

### 2.2 **Usage (Router-Based Navigation)**

Configure `querySchemes` in `module.json5` to handle payment callbacks:

```
{
  "module": {
    ...
    "querySchemes": ["alipays"]
  }
}
```

**Payment Flow**:

- If Alipay is **not installed**, redirect to **H5 payment**.
- If installed, directly open the **Alipay app**.

**Router Navigation Example**:

```
new Pay().pay(orderInfo, true).then((payResult) => {
  const message = `resultStatus: ${payResult.get('resultStatus')} memo: ${payResult.get('memo')} result: ${payResult.get('result')}`;
  console.log("Payment result:", message);
}).catch((error: BusinessError) => {
  console.error("Payment error:", error.message);
});
```

------

### 2.3 **Establish Custom Communication Channels**

**OHOS Side**
 Handle payment callbacks and return results to Flutter:

```
onMethodCall(call: MethodCall, result: MethodResult): void {
  console.log("onMethodCall ==> ", call.method);
  if (call.method === "getPlatformVersion") {
    result.success("HarmonyOS ^ ^");
  } else if (call.method === "aliPayAuth") {
    const orderInfo = call.args as string;
    console.log("Received order info:", orderInfo);
    
    new Pay().pay(orderInfo, true).then((payResult) => {
      const response = {
        resultStatus: payResult.get('resultStatus'),
        memo: payResult.get('memo'),
        result: payResult.get('result')
      };
      console.log("Payment response:", response);
      result.success(response);
    }).catch((error) => {
      console.error("Payment failed:", error);
      result.success({ resultStatus: "-1", errorMsg: error.message });
    }).finally(() => {
      console.log("Payment process completed.");
    });
  }
}
```

------

### 2.4 **Flutter Client-Side Integration**

Handle payment results in Flutter:

```
String orderInfoString = ""; // Sign data from backend

ExamOhosUtils().aliPayAuth(orderInfoString).then((value) {
  if (value["resultStatus"] == "9000") {
    // Payment success
    Toast.show(context, "Payment successful!");
    goToPaymentSuccess();
    eventBus.fire(RefreshUserCardEvent());
  } else {
    // Payment failed
    Toast.show(context, "Payment failed");
    _retryPayment(orderId);
  }
}).catchError((error) {
  print("Error: $error");
});
```

------

## Key Notes

1. **Callback Handling**:
   - Use `result.success()` to return payment status to Flutter.
   - Handle errors in `.catch()` blocks for robustness.
2. **Security**:
   - Never expose sensitive data (e.g., `orderInfo`) in logs or client-side code.
3. **Testing**:
   - Test with both installed and uninstalled Alipay clients to verify fallback behavior.

