// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_freshbooks_suppression.dart';

class FreshBooksResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class FreshBooksCallResult<T> {
  /// Creates a call result.
  const FreshBooksCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final FreshBooksResult? result;
}

Future<T> tracedFreshBooks<T>({
  required String operation,
  required Future<FreshBooksCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (freshBooksInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_freshbooks');
  final span = t.startSpan('freshbooks $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'freshbooks')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.accountId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('freshbooks.account.id', res.accountId!)
        ]));
      }
      if (res.businessId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('freshbooks.business.id', res.businessId!)
        ]));
      }
      if (res.clientId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('freshbooks.client.id', res.clientId!)]));
      }
      if (res.invoiceId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('freshbooks.invoice.id', res.invoiceId!)
        ]));
      }
      if (res.projectId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('freshbooks.project.id', res.projectId!)
        ]));
      }
      if (res.amount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('freshbooks.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('freshbooks.currency', res.currency!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('freshbooks.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'freshbooks.error',
          )
        ]));
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
