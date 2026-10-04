# Seed brain

`aqe-seed-patterns.json` holds six QE patterns about this checkout app, so Exercise 5 has something real to consolidate even if an earlier exercise failed on your machine.

```bash
aqe learning import -i seed/aqe-seed-patterns.json
aqe learning stats
```

Importing requires an embedder to be configured. See the memory-layer step in the main [README](../README.md).

Each pattern came from a finding on this code, not from a template:

| Pattern | Grounded in |
|---------|-------------|
| Backoff cap asserted after jitter, not before | `calculateBackoffDelay` caps at `maxDelayMs` and then adds up to 50% jitter, so 10000 can return up to 15000 |
| Retry loop carries no idempotency key | `processPaymentWithRetry` replays the same `PaymentRequest`, which has no idempotency field |
| Exhausted-retry path reports a fixed attempt count | the exhausted branch returns `maxRetries + 1` rather than the calls actually made |
| Cart state layer is the largest untested surface | `aqe hg untested` flags `cartReducer`, `CartProvider`, `useCart`; `aqe code complexity` scores that file highest at cyclomatic 9, cognitive 17 |
| Checkout errors are announced but not associated with their field | `CheckoutForm` renders every error with `role="alert"`, but the inputs carry no `aria-describedby` pointing at their error element |
| Request validation checks shape rather than meaning | `validatePaymentRequest` accepts any three-character currency; Luhn proves well formed, not real |

The file contains no absolute paths, so it is portable across machines.
