// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_freshbooks_suppression.dart';

class FreshBooksResult {
  const FreshBooksResult({
    this.accountId,
    this.businessId,
    this.clientId,
    this.invoiceId,
    this.projectId,
    this.amount,
    this.currency,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? accountId;
  final String? businessId;
  final String? clientId;
  final String? invoiceId;
  final String? projectId;
  final double? amount;
  final String? currency;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class FreshBooksCallResult<T> {
  const FreshBooksCallResult({required this.value, this.result});
  final T value;
  final FreshBooksResult? result;
}

Future<T> tracedFreshBooks<T>({
  required String operation,
  required Future<FreshBooksCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (freshBooksInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_freshbooks');
  final span = t.startSpan('freshbooks $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'freshbooks');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.accountId != null) {
        span.setStringAttribute('freshbooks.account.id', res.accountId!);
      }
      if (res.businessId != null) {
        span.setStringAttribute('freshbooks.business.id', res.businessId!);
      }
      if (res.clientId != null) {
        span.setStringAttribute('freshbooks.client.id', res.clientId!);
      }
      if (res.invoiceId != null) {
        span.setStringAttribute('freshbooks.invoice.id', res.invoiceId!);
      }
      if (res.projectId != null) {
        span.setStringAttribute('freshbooks.project.id', res.projectId!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('freshbooks.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('freshbooks.currency', res.currency!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('freshbooks.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'freshbooks.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
