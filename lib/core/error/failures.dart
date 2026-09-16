import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input provided.']);
}

class SecurityFailure extends Failure {
  const SecurityFailure([super.message = 'Authentication failed.']);
}

class ExportFailure extends Failure {
  const ExportFailure([super.message = 'Export failed.']);
}

class BackupRestoreFailure extends Failure {
  const BackupRestoreFailure([super.message = 'Backup or restore operation failed.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Requested item not found.']);
}

class GeneralFailure extends Failure {
  const GeneralFailure([super.message = 'An unexpected error occurred.']);
}

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class DatabaseException extends AppException {
  DatabaseException([super.message = 'Database error']);
}

class ValidationException extends AppException {
  ValidationException([super.message = 'Validation error']);
}
