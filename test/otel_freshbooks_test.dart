// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_freshbooks/otel_freshbooks.dart';
import 'package:test/test.dart';

void main() {
  group('otel_freshbooks', () {
    test('suppression toggles in zone', () async {
      expect(freshBooksInstrumentationSuppressed(), isFalse);
      await runWithoutFreshBooksInstrumentationAsync(() async {
        expect(freshBooksInstrumentationSuppressed(), isTrue);
      });
      expect(freshBooksInstrumentationSuppressed(), isFalse);
    });

    test('FreshBooksResult fields default null', () {
      const r = FreshBooksResult();
      expect(r.statusCode, isNull);
    });
  });
}
