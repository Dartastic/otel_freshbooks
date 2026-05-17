# otel_freshbooks

Dartastic OpenTelemetry bridge for FreshBooks (SMB invoicing + accounting).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_freshbooks/otel_freshbooks.dart';

await tracedFreshBooks<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return FreshBooksCallResult(value: r, result: FreshBooksResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutFreshBooksInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
