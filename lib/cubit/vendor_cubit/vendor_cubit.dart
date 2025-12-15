import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/vendor_repository.dart';
import '../vendor_state/vendor_state.dart';

class VendorCubit extends Cubit<VendorState> {
  final VendorRepository _vendorRepository;

  VendorCubit({VendorRepository? vendorRepository})
      : _vendorRepository = vendorRepository ?? VendorRepository(),
        super(VendorInitial());

  // Load vendor data
  Future<void> loadVendorData(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw Exception('Vendor ID cannot be empty');
      }

      emit(VendorLoading());
      final vendorData = await _vendorRepository.getVendorById(vendorId);

      if (vendorData != null) {
        emit(VendorLoaded(vendorData));
      } else {
        emit(const VendorError('Vendor not found'));
      }
    } catch (e) {
      emit(VendorError('Failed to load vendor data: ${e.toString()}'));
    }
  }

  // Update vendor profile
  Future<void> updateVendorProfile(Map<String, dynamic> vendorData) async {
    try {
      emit(VendorLoading());
      // TODO: Implement update logic
      // await vendorRepository.updateVendor(vendorData);
      emit(VendorOperationSuccess('Vendor profile updated successfully'));
    } catch (e) {
      emit(VendorError('Failed to update vendor profile: ${e.toString()}'));
    }
  }

  // Add new vendor
  Future<void> addVendor(Map<String, dynamic> vendorData) async {
    try {
      emit(VendorLoading());
      // TODO: Implement add vendor logic
      // await vendorRepository.addVendor(vendorData);
      emit(VendorOperationSuccess('Vendor added successfully'));
    } catch (e) {
      emit(VendorError('Failed to add vendor: ${e.toString()}'));
    }
  }

  // Delete vendor
  Future<void> deleteVendor(String vendorId) async {
    try {
      emit(VendorLoading());
      // TODO: Implement delete logic
      // await vendorRepository.deleteVendor(vendorId);
      emit(VendorOperationSuccess('Vendor deleted successfully'));
    } catch (e) {
      emit(VendorError('Failed to delete vendor: ${e.toString()}'));
    }
  }

  // Reset to initial state
  void resetState() {
    emit(VendorInitial());
  }
}
