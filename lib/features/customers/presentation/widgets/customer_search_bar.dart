import 'package:flutter/material.dart';
import 'package:water_billing_app/core/widgets/custom_textfield.dart';

class CustomerSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String hintText;

  const CustomerSearchBar({
    super.key,
    required this.onSearchChanged,
    this.hintText = 'ابحث باسم العميل أو رقم الهاتف...',
  });

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomTextfield(
        controller: _searchController,
        textLabel: widget.hintText,
        keyboardType: TextInputType.text,
        prefixIcon: Icons.search,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: _clearSearch,
              )
            : null,
        onChanged: (_) => _onSearchChanged(),
      ),
    );
  }
}