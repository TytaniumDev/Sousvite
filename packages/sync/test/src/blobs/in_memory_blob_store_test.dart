import 'package:sync/sync.dart';

import '../../contract/blob_store_contract.dart';

final class _MemoryHarness() implements BlobHarness {
  final _store = InMemoryBlobStore();

  @override
  BlobStore store() => _store;
}

void main() {
  runBlobStoreContract('In-memory', _MemoryHarness.new);
}
