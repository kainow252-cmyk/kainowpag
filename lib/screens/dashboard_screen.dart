import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_provider.dart';
import '../models/dashboard_stats.dart';
import 'webhooks_log_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStats? _stats;
  bool _isLoading = true;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    
    final api = context.read<APIProvider>();
    final stats = await api.getDashboardStats();
    
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'Atualizar dados',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bem-vindo ao Kainowpag',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sistema integrado com API DeltaPag',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          icon: Icons.people,
                          title: 'Clientes',
                          value: _stats?.totalCustomers.toString() ?? '0',
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.inventory_2,
                          title: 'Produtos',
                          value: _stats?.totalProducts.toString() ?? '0',
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.receipt_long,
                          title: 'Faturas',
                          value: _stats?.totalInvoices.toString() ?? '0',
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          icon: Icons.payment,
                          title: 'Cobranças',
                          value: _stats?.totalCharges.toString() ?? '0',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Financial Metrics
                    Text(
                      'Métricas Financeiras',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildMetricCard(
                      title: 'COBRANÇAS (ÚLTIMAS 24H)',
                      value: currencyFormat.format(_stats?.todayChargesValue ?? 0),
                      subtitle: 'Total de ${_stats?.todayChargesCount ?? 0} cobranças',
                      icon: Icons.access_time,
                      color: Colors.blue,
                    ),
                    
                    _buildMetricCard(
                      title: 'COBRANÇAS (MÊS)',
                      value: currencyFormat.format(_stats?.monthChargesValue ?? 0),
                      subtitle: 'Total de ${_stats?.monthChargesCount ?? 0} cobranças bem-sucedidas',
                      icon: Icons.calendar_month,
                      color: Colors.green,
                    ),
                    
                    _buildMetricCard(
                      title: 'TICKET MÉDIO',
                      value: currencyFormat.format(_stats?.averageTicket ?? 0),
                      subtitle: 'Valor médio por cobrança',
                      icon: Icons.analytics,
                      color: Colors.purple,
                    ),
                    
                    const SizedBox(height: 24),

                    // Seção de Webhooks (sempre visível)
                    Text(
                      'Notificações',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildQuickAction(
                      icon: Icons.webhook,
                      title: 'Ver Webhooks',
                      subtitle: 'Visualizar notificações recebidas do DeltaPag',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WebhooksLogScreen()),
                        );
                      },
                    ),

                    // Ações Rápidas ocultadas conforme solicitação do usuário
                    // const SizedBox(height: 24),

                    // // Quick Actions
                    // Text(
                    //   'Ações Rápidas',
                    //   style: theme.textTheme.titleLarge?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    
                    // _buildQuickAction(
                    //   icon: Icons.receipt_long,
                    //   title: 'Nova Fatura',
                    //   subtitle: 'Criar uma nova fatura para cobrança',
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
                    //     );
                    //   },
                    // ),
                    
                    // _buildQuickAction(
                    //   icon: Icons.credit_card,
                    //   title: 'Nova Cobrança',
                    //   subtitle: 'Criar cobrança direta via cartão',
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (_) => const CreateChargeScreen()),
                    //     );
                    //   },
                    // ),
                    
                    // _buildQuickAction(
                    //   icon: Icons.person_add,
                    //   title: 'Adicionar Cliente',
                    //   subtitle: 'Cadastrar novo cliente',
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (_) => const CreateCustomerScreen()),
                    //     );
                    //   },
                    // ),
                    
                    // _buildQuickAction(
                    //   icon: Icons.add_shopping_cart,
                    //   title: 'Novo Produto',
                    //   subtitle: 'Cadastrar novo produto',
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (_) => const CreateProductScreen()),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
