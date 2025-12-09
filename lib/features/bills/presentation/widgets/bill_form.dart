import 'package:flutter/material.dart';
import 'package:water_billing_app/features/bills/domain/entities/bill.dart';
import 'package:water_billing_app/features/customers/domain/entities/customer_entity.dart';
import 'package:water_billing_app/core/widgets/custom_textfield.dart';

class BillForm extends StatefulWidget {
  final Function(BillEntity) onSubmit;
  final String submitButtonText;
  final BillEntity? initialData;
  final CustomerEntity? selectedCustomer;
  final double unitPrice;
  final double? lastReading; // إضافة معلمة لآخر قراءة

  const BillForm({
    super.key,
    required this.onSubmit,
    this.submitButtonText = 'إنشاء فاتورة',
    this.initialData,
    this.selectedCustomer,
    required this.unitPrice,
    this.lastReading,
  });

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final _formKey = GlobalKey<FormState>();
  final _previousReadingController = TextEditingController();
  final _currentReadingController = TextEditingController();
  final _previousFocusNode = FocusNode();
  final _currentFocusNode = FocusNode();

  double _consumption = 0.0;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      // حالة التعديل - استخدام بيانات الفاتورة الحالية
      _previousReadingController.text = widget.initialData!.previousReading.toString();
      _currentReadingController.text = widget.initialData!.currentReading.toString();
      _consumption = widget.initialData!.consumption;
      _totalAmount = widget.initialData!.totalAmount;
    } else {
      // حالة الإنشاء - استخدام آخر قراءة أو صفر
      _previousReadingController.text = widget.lastReading?.toStringAsFixed(2) ?? '0';
      _currentReadingController.text = '';
    }
    
    _currentReadingController.addListener(_calculateValues);
    _calculateValues(); // حساب القيم الأولية
  }

  void _calculateValues() {
    final previous = double.tryParse(_previousReadingController.text) ?? 0;
    final current = double.tryParse(_currentReadingController.text) ?? 0;
    
    if (current >= previous) {
      setState(() {
        _consumption = current - previous;
        _totalAmount = _consumption * widget.unitPrice;
      });
    } else {
      setState(() {
        _consumption = 0;
        _totalAmount = 0;
      });
    }
  }

  @override
  void dispose() {
    _previousReadingController.dispose();
    _currentReadingController.dispose();
    _previousFocusNode.dispose();
    _currentFocusNode.dispose();
    super.dispose();
  }

  String? _readingValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال القراءة';
    }
    final reading = double.tryParse(value);
    if (reading == null || reading < 0) {
      return 'يرجى إدخال رقم صحيح';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && widget.selectedCustomer != null) {
      final previous = double.parse(_previousReadingController.text);
      final current = double.parse(_currentReadingController.text);
      
      if (current < previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('القراءة الحالية يجب أن تكون أكبر أو تساوي السابقة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      widget.onSubmit(
        BillEntity(
          id: widget.initialData?.id,
          customerId: widget.selectedCustomer!.id!,
          customerName: widget.selectedCustomer!.name,
          previousReading: previous,
          currentReading: current,
          consumption: _consumption,
          unitPrice: widget.unitPrice,
          totalAmount: _totalAmount,
          billDate: widget.initialData?.billDate ?? DateTime.now(),
          isPaid: widget.initialData?.isPaid ?? false,
        ),
      );
    } else if (widget.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار مشترك'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (widget.selectedCustomer != null) ...[
              _buildCustomerInfo(),
              const SizedBox(height: 16),
            ],
            
            CustomTextfield(
              controller: _previousReadingController,
              textLabel: 'القراءة السابقة (م³)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.water_drop,
              validator: _readingValidator,
              focusNode: _previousFocusNode,
              textInputAction: TextInputAction.next,
              enabled: widget.initialData == null, // لا يمكن تعديل القراءة السابقة في التعديل
            ),
            const SizedBox(height: 16),
            
            CustomTextfield(
              controller: _currentReadingController,
              textLabel: 'القراءة الحالية (م³)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.water_drop,
              validator: _readingValidator,
              focusNode: _currentFocusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitForm(),
            ),
            const SizedBox(height: 20),
            
            // عرض الحسابات التلقائية
            _buildCalculations(),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  widget.initialData == null ? Icons.receipt_long : Icons.save,
                  size: 24,
                ),
                label: Text(
                  widget.submitButtonText,
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedCustomer!.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.selectedCustomer!.phone,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Text(
            'الحسابات التلقائية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          _buildCalculationRow('كمية الاستهلاك', '${_consumption.toStringAsFixed(2)} م³'),
          _buildCalculationRow('سعر الوحدة', '${widget.unitPrice.toStringAsFixed(2)} ريال/م³'),
          const Divider(),
          _buildCalculationRow(
            'المبلغ الإجمالي',
            '${_totalAmount.toStringAsFixed(2)} ريال',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}