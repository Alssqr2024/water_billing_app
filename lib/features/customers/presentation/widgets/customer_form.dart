import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_billing_app/core/widgets/custom_textfield.dart';
import 'package:water_billing_app/features/customers/domain/entities/customer_entity.dart';

class CustomerForm extends ConsumerStatefulWidget {
  final Function(CustomerEntity) onSubmit;
  final String submitButtonText;
  final CustomerEntity? initialData;

  const CustomerForm({
    super.key,
    required this.onSubmit,
    this.submitButtonText = 'إضافة مشترك',
    this.initialData,
  });

  @override
  ConsumerState<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!.name;
      _phoneController.text = widget.initialData!.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال اسم المشترك';
    }
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون على الأقل حرفين';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }
    if (value.trim().length < 8) {
      return 'رقم الهاتف يجب أن يكون على الأقل 8 أرقام';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        CustomerEntity(
          id: widget.initialData?.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );
      if (widget.initialData == null) {
        _nameController.clear();
        _phoneController.clear();
        FocusScope.of(context).requestFocus(_nameFocusNode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextfield(
            controller: _nameController,
            textLabel: 'اسم المشترك',
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline,
            validator: _nameValidator,
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.next,
            autofocus: widget.initialData == null,
          ),
          const SizedBox(height: 16),
          CustomTextfield(
            controller: _phoneController,
            textLabel: 'رقم الهاتف',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android,
            validator: _phoneValidator,
            focusNode: _phoneFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitForm(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(
                widget.initialData == null ? Icons.person_add : Icons.save,
                size: 24,
              ),
              label: Text(
                widget.submitButtonText,
                style: const TextStyle(fontSize: 16),
              ),
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}