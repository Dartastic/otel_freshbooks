// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_freshbooks/otel_freshbooks.dart';

/// Traces Freshbooks calls with OpenTelemetry.
///
/// `otel_freshbooks` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Freshbooks call in
/// [tracedFreshBooks]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'freshbooks-example');

  // Traces a Freshbooks call.
  final freshBooksId = await tracedFreshBooks<String>(
    operation: 'create',
    invoke: () async {
      // Make the Freshbooks call here, then report what it returned.
      const id = 'freshbooks_8f3a2c';
      return const FreshBooksCallResult(
          value: id,
          result: FreshBooksResult(
              accountId: 'account_8f3a2c',
              businessId: 'business_8f3a2c',
              clientId: 'client_8f3a2c',
              invoiceId: 'invoice_8f3a2c',
              projectId: 'project_8f3a2c',
              amount: 0.5,
              currency: 'usd',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedFreshBooks create returned $freshBooksId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutFreshBooksInstrumentationAsync.
  await runWithoutFreshBooksInstrumentationAsync(
    () => tracedFreshBooks<String>(
      operation: 'create',
      invoke: () async {
        const id = 'freshbooks_8f3a2c';
        return const FreshBooksCallResult(
            value: id,
            result: FreshBooksResult(
                accountId: 'account_8f3a2c',
                businessId: 'business_8f3a2c',
                clientId: 'client_8f3a2c',
                invoiceId: 'invoice_8f3a2c',
                projectId: 'project_8f3a2c',
                amount: 0.5,
                currency: 'usd',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
