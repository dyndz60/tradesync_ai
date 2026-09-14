import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImportCostCalculator {
  // Constants
  static const double TAX_RATE_SELF_ENTREPRENEUR = 0.05; // 5% for المقاول الذاتي
  static const double USD_TO_DZD_RATE = 134.5; // Approximate (should be dynamic)

  // Calculate total import cost
  static Map<String, double> calculateImportCost({
    required double quantityKg,
    required double unitPriceUSD,
    required double commissionPerKgDZD,
    required double shippingCostDZD,
  }) {
    // Product cost in USD
    final productCostUSD = quantityKg * unitPriceUSD;
    
    // Convert to DZD
    final productCostDZD = productCostUSD * USD_TO_DZD_RATE;
    
    // Commission cost
    final commissionCostDZD = quantityKg * commissionPerKgDZD;
    
    // Subtotal
    final subtotalDZD = productCostDZD + commissionCostDZD + shippingCostDZD;
    
    // Tax (5% for self-entrepreneurs)
    final taxDZD = subtotalDZD * TAX_RATE_SELF_ENTREPRENEUR;
    
    // Total cost
    final totalDZD = subtotalDZD + taxDZD;
    
    return {
      'productCostDZD': productCostDZD,
      'commissionCostDZD': commissionCostDZD,
      'shippingCostDZD': shippingCostDZD,
      'subtotalDZD': subtotalDZD,
      'taxDZD': taxDZD,
      'totalDZD': totalDZD,
    };
  }

  // Calculate unit cost for resale
  static double calculateRetailPrice({
    required double totalCostDZD,
    required double quantityKg,
    required double profitMarginPercent,
  }) {
    final unitCostDZD = totalCostDZD / quantityKg;
    final profitPerUnit = unitCostDZD * (profitMarginPercent / 100);
    return unitCostDZD + profitPerUnit;
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _quantityKgController = TextEditingController();
  final TextEditingController _unitPriceUSDController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _shippingController = TextEditingController();
  final TextEditingController _profitMarginController = TextEditingController(text: '30');

  Map<String, double>? _calculationResult;

  @override
  void dispose() {
    _quantityKgController.dispose();
    _unitPriceUSDController.dispose();
    _commissionController.dispose();
    _shippingController.dispose();
    _profitMarginController.dispose();
    super.dispose();
  }

  void _performCalculation() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    if (_quantityKgController.text.isEmpty ||
        _unitPriceUSDController.text.isEmpty ||
        _commissionController.text.isEmpty ||
        _shippingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'يرجى ملء جميع الحقول' : 'Please fill all fields',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    final result = ImportCostCalculator.calculateImportCost(
      quantityKg: double.parse(_quantityKgController.text),
      unitPriceUSD: double.parse(_unitPriceUSDController.text),
      commissionPerKgDZD: double.parse(_commissionController.text),
      shippingCostDZD: double.parse(_shippingController.text),
    );

    setState(() => _calculationResult = result);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'حاسبة التكاليف' : 'Cost Calculator',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'معلومات الاستيراد' : 'Import Details',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    // Quantity
                    _buildInputField(
                      label: isArabic ? 'الكمية (كيلوغرام)' : 'Quantity (kg)',
                      controller: _quantityKgController,
                      hint: '100',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    
                    // Unit Price USD
                    _buildInputField(
                      label: isArabic ? 'سعر الوحدة (USD)' : 'Unit Price (USD)',
                      controller: _unitPriceUSDController,
                      hint: '25.00',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    
                    // Commission Per KG
                    _buildInputField(
                      label: isArabic ? 'العمولة لكل كيلو (دج)' : 'Commission/KG (DZD)',
                      controller: _commissionController,
                      hint: '50',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    
                    // Shipping Cost
                    _buildInputField(
                      label: isArabic ? 'تكلفة الشحن (دج)' : 'Shipping Cost (DZD)',
                      controller: _shippingController,
                      hint: '5000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    
                    // Profit Margin
                    _buildInputField(
                      label: isArabic ? 'هامش الربح (%)' : 'Profit Margin (%)',
                      controller: _profitMarginController,
                      hint: '30',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    
                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _performCalculation,
                        child: Text(
                          isArabic ? 'احسب التكاليف' : 'Calculate Costs',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Results Section
            if (_calculationResult != null)
              Card(
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'نتائج الحساب' : 'Calculation Results',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildResultRow(
                        label: isArabic ? 'تكلفة المنتج' : 'Product Cost',
                        value: _calculationResult!['productCostDZD']!,
                        theme: theme,
                      ),
                      _buildResultRow(
                        label: isArabic ? 'العمولة' : 'Commission',
                        value: _calculationResult!['commissionCostDZD']!,
                        theme: theme,
                      ),
                      _buildResultRow(
                        label: isArabic ? 'الشحن' : 'Shipping',
                        value: _calculationResult!['shippingCostDZD']!,
                        theme: theme,
                      ),
                      const Divider(),
                      _buildResultRow(
                        label: isArabic ? 'المجموع قبل الضريبة' : 'Subtotal',
                        value: _calculationResult!['subtotalDZD']!,
                        theme: theme,
                        isBold: true,
                      ),
                      _buildResultRow(
                        label: isArabic ? 'الضريبة (5%)' : 'Tax (5%)',
                        value: _calculationResult!['taxDZD']!,
                        theme: theme,
                        isHighlight: true,
                      ),
                      const Divider(thickness: 2),
                      _buildResultRow(
                        label: isArabic ? 'الإجمالي' : 'Total',
                        value: _calculationResult!['totalDZD']!,
                        theme: theme,
                        isBold: true,
                        isHighlight: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Retail Price
                      if (_profitMarginController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'سعر البيع المقترح' : 'Suggested Retail Price',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${ImportCostCalculator.calculateRetailPrice(totalCostDZD: _calculationResult!['totalDZD']!, quantityKg: double.parse(_quantityKgController.text), profitMarginPercent: double.parse(_profitMarginController.text)).toStringAsFixed(2)} دج/kg',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow({
    required String label,
    required double value,
    required ThemeData theme,
    bool isBold = false,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
              color: isHighlight ? theme.colorScheme.primary : Colors.black,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} دج',
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
              color: isHighlight ? theme.colorScheme.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
