import 'package:equatable/equatable.dart';

abstract class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object> get props => [];
}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorLoaded extends VendorState {
  final dynamic vendorData;

  const VendorLoaded(this.vendorData);

  @override
  List<Object> get props => [vendorData];
}

class VendorError extends VendorState {
  final String message;

  const VendorError(this.message);

  @override
  List<Object> get props => [message];
}

class VendorOperationSuccess extends VendorState {
  final String message;

  const VendorOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
