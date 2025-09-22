import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';
import '../repositories/firebase_auth_repository_impl.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRepository firebaseAuthRepository(FirebaseAuthRepositoryRef ref) {
  return FirebaseAuthRepositoryImpl();
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    firebaseRepository: ref.watch(firebaseAuthRepositoryProvider),
    ref: ref,
  );
}
