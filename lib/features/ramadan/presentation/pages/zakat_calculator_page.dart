import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/zakat_provider.dart';
import '../../../../core/models/zakat_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/haptic_service.dart';

class ZakatCalculatorPage extends StatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  State<ZakatCalculatorPage> createState() => _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

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
    _tabController = TabController(length: 3, vsync: this);
    final provider = context.read<ZakatProvider>();
    final data = provider.data;

    _goldPriceController = TextEditingController(
        text: data.goldPricePerGram > 0 ? data.goldPricePerGram.toString() : '');
    _silverPriceController = TextEditingController(
        text: data.silverPricePerGram > 0 ? data.silverPricePerGram.toString() : '');
    _cashHandController = TextEditingController(
        text: data.cashInHand > 0 ? data.cashInHand.toString() : '');
    _cashBankController = TextEditingController(
        text: data.cashInBank > 0 ? data.cashInBank.toString() : '');
    _goldGramsController = TextEditingController(
        text: data.goldGrams > 0 ? data.goldGrams.toString() : '');
    _silverGramsController = TextEditingController(
        text: data.silverGrams > 0 ? data.silverGrams.toString() : '');
    _investmentsController = TextEditingController(
        text: data.investments > 0 ? data.investments.toString() : '');
    _propertyController = TextEditingController(
        text: data.propertyForTrade > 0 ? data.propertyForTrade.toString() : '');
    _otherSavingsController = TextEditingController(
        text: data.otherSavings > 0 ? data.otherSavings.toString() : '');
    _liabilitiesController = TextEditingController(
        text: data.liablities > 0 ? data.liablities.toString() : '');
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  NumberFormat _getCurrencyFormat(ZakatCurrency currency) {
    return NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: currency == ZakatCurrency.idr ? 0 : 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<ZakatProvider>();
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: _buildHeader(theme, isDark, provider, horizontalPadding),
                ),

                // Result Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 0, horizontalPadding, 16),
                    child: _buildResultCard(provider, theme, isDark),
                  ),
                ),

                // Currency Selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: _buildCurrencySelector(provider, theme, isDark),
                  ),
                ),

                // Tabbed Form Sections
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 16, horizontalPadding, 0),
                    child: _buildTabBar(theme, isDark),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    onChanged: _updateProvider,
                    child: AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: _buildTabContent(theme, isDark, provider),
                        );
                      },
                    ),
                  ),
                ),

                // Settings Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 24, horizontalPadding, 8),
                    child: Text(
                      'Settings',
                      style: AppTypography.heading4(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: _buildSettingsCard(provider, theme, isDark),
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, bool isDark, ZakatProvider provider, double padding) {
    return Container(
      padding: EdgeInsets.fromLTRB(padding, 16, padding, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkBackground]
              : [Colors.white, AppColors.cream],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                onPressed: () => _showInfoDialog(context, isDark),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                onPressed: () => _showResetDialog(context, provider),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zakat Calculator',
                  style: AppTypography.heading1(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calculate your obligatory charity',
                  style: AppTypography.bodyMedium(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
      ZakatProvider provider, ThemeData theme, bool isDark) {
    final isEligible = provider.isEligible;
    final currencyFormat = _getCurrencyFormat(provider.currency);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEligible
              ? [theme.colorScheme.primary, AppColors.mutedTeal]
              : [Colors.grey.shade500, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isEligible ? theme.colorScheme.primary : Colors.grey)
                .withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Arabic Text
          const Text(
            'الزَّكَاة',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontFamily: 'Amiri',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ZAKAT PAYABLE',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 3.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              currencyFormat.format(provider.zakatPayable),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '2.5% of your net zakatable assets',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Net Assets',
                    currencyFormat.format(provider.netAssetsValue),
                    Icons.account_balance_wallet_rounded,
                    Colors.white,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white24,
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Nisab',
                    currencyFormat.format(provider.nisabThreshold),
                    Icons.show_chart_rounded,
                    Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEligible
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isEligible
                      ? 'You are eligible to pay Zakat'
                      : 'Below Nisab threshold',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildCurrencySelector(
      ZakatProvider provider, ThemeData theme, bool isDark) {
    return ElegantCard(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.currency_exchange_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Currency',
                style: AppTypography.heading4(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ZakatCurrency.values.map((currency) {
                final isSelected = provider.currency == currency;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CurrencyChip(
                    currency: currency,
                    isSelected: isSelected,
                    onTap: () {
                      HapticService().selectionClick();
                      provider.setCurrency(currency);
                    },
                    theme: theme,
                    isDark: isDark,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Prices'),
          Tab(text: 'Assets'),
          Tab(text: 'Liabilities'),
        ],
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme, bool isDark, ZakatProvider provider) {
    switch (_tabController.index) {
      case 0:
        return _buildPricesSection(theme, isDark, provider);
      case 1:
        return _buildAssetsSection(theme, isDark, provider);
      case 2:
        return _buildLiabilitiesSection(theme, isDark, provider);
      default:
        return _buildPricesSection(theme, isDark, provider);
    }
  }

  Widget _buildPricesSection(
      ThemeData theme, bool isDark, ZakatProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElegantCard(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Enter current market prices per gram in ${provider.currency.name}',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _goldPriceController,
              label: 'Gold Price per Gram',
              hint: 'e.g., ${provider.currency == ZakatCurrency.bdt ? "8500" : "65"}',
              icon: Icons.monetization_on_rounded,
              iconColor: const Color(0xFFFFD700),
              theme: theme,
              isDark: isDark,
              prefix: provider.currencySymbol,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _silverPriceController,
              label: 'Silver Price per Gram',
              hint: 'e.g., ${provider.currency == ZakatCurrency.bdt ? "100" : "0.80"}',
              icon: Icons.monetization_on_outlined,
              iconColor: const Color(0xFFC0C0C0),
              theme: theme,
              isDark: isDark,
              prefix: provider.currencySymbol,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsSection(
      ThemeData theme, bool isDark, ZakatProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Precious Metals Card
          ElegantCard(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Precious Metals',
                  Icons.diamond_rounded,
                  theme.colorScheme.primary,
                  isDark,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _goldGramsController,
                        label: 'Gold (grams)',
                        hint: '0',
                        icon: Icons.balance_rounded,
                        iconColor: const Color(0xFFFFD700),
                        theme: theme,
                        isDark: isDark,
                        suffix: 'g',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _silverGramsController,
                        label: 'Silver (grams)',
                        hint: '0',
                        icon: Icons.scale_rounded,
                        iconColor: const Color(0xFFC0C0C0),
                        theme: theme,
                        isDark: isDark,
                        suffix: 'g',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Cash & Savings Card
          ElegantCard(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Cash & Savings',
                  Icons.account_balance_wallet_rounded,
                  AppColors.forestGreen,
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cashHandController,
                  label: 'Cash in Hand',
                  hint: '0',
                  icon: Icons.wallet_rounded,
                  theme: theme,
                  isDark: isDark,
                  prefix: provider.currencySymbol,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _cashBankController,
                  label: 'Cash in Bank',
                  hint: '0',
                  icon: Icons.account_balance_rounded,
                  theme: theme,
                  isDark: isDark,
                  prefix: provider.currencySymbol,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _otherSavingsController,
                  label: 'Other Savings',
                  hint: '0',
                  icon: Icons.savings_rounded,
                  theme: theme,
                  isDark: isDark,
                  prefix: provider.currencySymbol,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Investments Card
          ElegantCard(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Investments & Business',
                  Icons.trending_up_rounded,
                  AppColors.mutedTeal,
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _investmentsController,
                  label: 'Stocks & Investments',
                  hint: '0',
                  icon: Icons.show_chart_rounded,
                  theme: theme,
                  isDark: isDark,
                  prefix: provider.currencySymbol,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _propertyController,
                  label: 'Business Goods / Trade Property',
                  hint: '0',
                  icon: Icons.store_rounded,
                  theme: theme,
                  isDark: isDark,
                  prefix: provider.currencySymbol,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiabilitiesSection(
      ThemeData theme, bool isDark, ZakatProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElegantCard(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Debts & Liabilities',
              Icons.money_off_rounded,
              AppColors.softRoseDark,
              isDark,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter debts that are due immediately or within the coming lunar year',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _liabilitiesController,
              label: 'Total Liabilities',
              hint: '0',
              icon: Icons.receipt_long_rounded,
              theme: theme,
              isDark: isDark,
              prefix: provider.currencySymbol,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.heading4(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
      ZakatProvider provider, ThemeData theme, bool isDark) {
    return ElegantCard(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Use Silver Standard for Nisab',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              provider.data.useSilverNisab
                  ? 'Recommended - Lower threshold (${ZakatProvider.NISAB_SILVER_GRAMS}g silver)'
                  : 'Using Gold Standard (${ZakatProvider.NISAB_GOLD_GRAMS}g gold)',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            value: provider.data.useSilverNisab,
            onChanged: (val) {
              HapticService().selectionClick();
              provider.updateData(useSilverNisab: val);
            },
            activeColor: theme.colorScheme.primary,
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (provider.data.useSilverNisab
                        ? const Color(0xFFC0C0C0)
                        : const Color(0xFFFFD700))
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                provider.data.useSilverNisab
                    ? Icons.circle
                    : Icons.circle,
                color: provider.data.useSilverNisab
                    ? const Color(0xFFC0C0C0)
                    : const Color(0xFFFFD700),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
    Color? iconColor,
    String? prefix,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary)
              .withOpacity(0.5),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(
            icon,
            color: iconColor ?? theme.colorScheme.primary.withOpacity(0.7),
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.darkSurface
            : AppColors.warmBeige.withOpacity(0.3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('About Zakat'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem(
                'What is Zakat?',
                'Zakat is an obligatory form of charity in Islam, one of the Five Pillars. It is 2.5% of your eligible wealth.',
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                'What is Nisab?',
                'Nisab is the minimum amount of wealth a Muslim must possess before being obligated to pay Zakat. It is equivalent to 87.48g of gold or 612.36g of silver.',
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                'Silver vs Gold Standard',
                'Using silver standard results in a lower Nisab threshold, meaning more people become eligible to pay Zakat. This is considered more cautious and recommended by many scholars.',
                isDark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, ZakatProvider provider) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset Calculator?'),
        content: const Text('This will clear all your entered values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticService().lightImpact();
              provider.resetData();
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final ZakatCurrency currency;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDark;

  const _CurrencyChip({
    required this.currency,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? AppColors.darkSurface : AppColors.cream),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? AppColors.dividerDark : AppColors.divider),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currency.symbol,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currency.code,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
