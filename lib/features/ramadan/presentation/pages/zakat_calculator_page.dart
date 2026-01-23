import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/zakat_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

class ZakatCalculatorPage extends StatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  State<ZakatCalculatorPage> createState() => _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _currencyFormat = NumberFormat.currency(symbol: '\$'); 
  // Note: We use $ as generic symbol, but app might support others later.

  late TextEditingController _goldPriceController;
  late TextEditingController _silverPriceController;
  late TextEditingController _cashHandController;
  late TextEditingController _cashBankController;
  late TextEditingController _goldGramsController;
  late TextEditingController _silverGramsController;
  late TextEditingController _investmentsController;
  late TextEditingController _propertyController;
  late TextEditingController _otherSavingsController;
  late TextEditingController _liabilitiesController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ZakatProvider>();
    final data = provider.data;

    _goldPriceController = TextEditingController(text: data.goldPricePerGram > 0 ? data.goldPricePerGram.toString() : '');
    _silverPriceController = TextEditingController(text: data.silverPricePerGram > 0 ? data.silverPricePerGram.toString() : '');
    _cashHandController = TextEditingController(text: data.cashInHand > 0 ? data.cashInHand.toString() : '');
    _cashBankController = TextEditingController(text: data.cashInBank > 0 ? data.cashInBank.toString() : '');
    _goldGramsController = TextEditingController(text: data.goldGrams > 0 ? data.goldGrams.toString() : '');
    _silverGramsController = TextEditingController(text: data.silverGrams > 0 ? data.silverGrams.toString() : '');
    _investmentsController = TextEditingController(text: data.investments > 0 ? data.investments.toString() : '');
    _propertyController = TextEditingController(text: data.propertyForTrade > 0 ? data.propertyForTrade.toString() : '');
    _otherSavingsController = TextEditingController(text: data.otherSavings > 0 ? data.otherSavings.toString() : '');
    _liabilitiesController = TextEditingController(text: data.liablities > 0 ? data.liablities.toString() : '');
  }

  @override
  void dispose() {
    _goldPriceController.dispose();
    _silverPriceController.dispose();
    _cashHandController.dispose();
    _cashBankController.dispose();
    _goldGramsController.dispose();
    _silverGramsController.dispose();
    _investmentsController.dispose();
    _propertyController.dispose();
    _otherSavingsController.dispose();
    _liabilitiesController.dispose();
    super.dispose();
  }

  void _updateProvider() {
    if (_formKey.currentState!.validate()) {
      context.read<ZakatProvider>().updateData(
        goldPricePerGram: double.tryParse(_goldPriceController.text) ?? 0.0,
        silverPricePerGram: double.tryParse(_silverPriceController.text) ?? 0.0,
        cashInHand: double.tryParse(_cashHandController.text) ?? 0.0,
        cashInBank: double.tryParse(_cashBankController.text) ?? 0.0,
        goldGrams: double.tryParse(_goldGramsController.text) ?? 0.0,
        silverGrams: double.tryParse(_silverGramsController.text) ?? 0.0,
        investments: double.tryParse(_investmentsController.text) ?? 0.0,
        propertyForTrade: double.tryParse(_propertyController.text) ?? 0.0,
        otherSavings: double.tryParse(_otherSavingsController.text) ?? 0.0,
        liablities: double.tryParse(_liabilitiesController.text) ?? 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<ZakatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Calculator'),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              // Confirm reset
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Reset Calculator?'),
                  content: const Text('This will clear all your entered values.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        provider.resetData();
                        Navigator.pop(c);
                        Navigator.pop(context); // Go back and reopen to refresh controllers ideally or setState
                        // Simpler: Just refresh page or re-init controllers. 
                        // For now we assume user re-enters.
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        onChanged: _updateProvider, // Auto-update on any change
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Result Summary Card
            _buildResultCard(provider, theme, isDark),
            const SizedBox(height: 24),

            // 2. Gold & Silver Prices (Essential)
            Text('Current Market Prices', style: AppTypography.heading4(color: theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black))),
            const SizedBox(height: 8),
            ElegantCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              child: Column(
                children: [
                   Text('Please enter the current price per gram.', style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600], fontSize: 13)),
                   const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _goldPriceController,
                          label: 'Gold Price / g',
                          icon: Icons.monetization_on_outlined,
                          theme: theme,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _silverPriceController,
                          label: 'Silver Price / g',
                          icon: Icons.money_rounded,
                          theme: theme,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Assets
            Text('Your Assets', style: AppTypography.heading4(color: theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black))),
            const SizedBox(height: 8),
            ElegantCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _goldGramsController,
                    label: 'Gold Quantity (grams)',
                    icon: Icons.balance_rounded,
                    theme: theme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _silverGramsController,
                    label: 'Silver Quantity (grams)',
                    icon: Icons.scale_rounded,
                    theme: theme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cashHandController,
                    label: 'Cash in Hand',
                    icon: Icons.account_balance_wallet_outlined,
                    theme: theme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cashBankController,
                    label: 'Cash in Bank',
                    icon: Icons.account_balance_outlined,
                    theme: theme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _investmentsController,
                    label: 'Investments / Shares',
                    icon: Icons.trending_up_rounded,
                    theme: theme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _propertyController,
                    label: 'Business Goods / Property',
                    icon: Icons.store_mall_directory_outlined,
                    theme: theme,
                    isDark: isDark,
                  ),
                   const SizedBox(height: 12),
                  _buildTextField(
                    controller: _otherSavingsController,
                    label: 'Other Savings',
                    icon: Icons.savings_outlined,
                    theme: theme,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 4. Liabilities
            Text('Liabilities', style: AppTypography.heading4(color: theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black))),
            const SizedBox(height: 8),
            ElegantCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              child: _buildTextField(
                controller: _liabilitiesController,
                label: 'Debts / Immediate Liabilities',
                icon: Icons.money_off_csred_rounded,
                theme: theme,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 24),

            // 5. Settings
            ListTile(
              title: const Text('Use Silver Standard for Nisab'),
              subtitle: const Text('Recommended for caution (safer) as it has a lower threshold.'),
              trailing: Switch(
                value: provider.data.useSilverNisab,
                onChanged: (val) {
                  provider.updateData(useSilverNisab: val);
                },
                activeColor: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ZakatProvider provider, ThemeData theme, bool isDark) {
    // Determine gradient based on eligibility
    final isEligible = provider.isEligible;
    final gradientColors = isEligible
        ? [theme.colorScheme.primary, AppColors.mutedTeal]
        : [Colors.grey.shade400, Colors.grey.shade600];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isEligible ? theme.colorScheme.primary : Colors.grey).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'ZAKAT PAYABLE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(provider.zakatPayable),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Assets',
                  _currencyFormat.format(provider.netAssetsValue),
                  Icons.account_balance_wallet,
                  Colors.white,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildSummaryItem(
                  'Nisab Threshold',
                  _currencyFormat.format(provider.nisabThreshold),
                  Icons.show_chart,
                  Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.2),
               borderRadius: BorderRadius.circular(20),
             ),
             child: Text(
               isEligible 
                 ? 'You are eligible to pay Zakat' 
                 : 'You are NOT eligible yet (Below Nisab)',
               style: const TextStyle(
                 color: Colors.white,
                 fontWeight: FontWeight.w600,
               ),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.warmBeige.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
