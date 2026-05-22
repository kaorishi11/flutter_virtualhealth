import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      home: const HomeAdmPage(),
    );
  }
}

class HomeAdmPage extends StatelessWidget {
  const HomeAdmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF0F172A),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Bem-vindo de volta,',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      'Gustavo!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.dashboard_outlined, 'GERAL', true),
              _buildDrawerItem(Icons.people_outline, 'Usuários'),
              _buildDrawerItem(Icons.medical_services_outlined, 'Profissionais'),
              _buildDrawerItem(Icons.forum_outlined, 'Consultas'),
              _buildDrawerItem(Icons.chat_bubble_outline, 'Mensagens'),
              const Divider(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildDrawerItem(Icons.logout, 'Sair', false),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visão Geral',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Acompanhe as métricas e consultas recentes',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Color(0xFF3B82F6)),
                      SizedBox(width: 8),
                      Text('Março 2026', style: TextStyle(color: Color(0xFF3B82F6))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),


            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Usuários ativos',
                    value: '1532',
                    subtitle: '-2,4% este mês',
                    icon: Icons.people_alt,
                    color: Colors.blue,
                    changeNegative: true,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Consultas do dia',
                    value: '67',
                    subtitle: '8 pendentes',
                    icon: Icons.today,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Consultas concluídas',
                    value: '32',
                    subtitle: 'Consultas concluídas (geral)',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CONSULTAS RECENTES',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver tudo'),
                ),
              ],
            ),
            const SizedBox(height: 16),


            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                  dataRowMinHeight: 60,
                  columnSpacing: 40,
                  columns: const [
                    DataColumn(label: Text('NOME', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('DATA', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('TIPO', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('AÇÃO', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                  rows: [
                    _buildDataRow('Vinícius Queiroz', '15/03/2026', 'Pendente', 'Urologista', Colors.orange),
                    _buildDataRow('Pedro Lucas', '01/03/2026', 'Realizado', 'Dentista', Colors.green),
                    _buildDataRow('Miguel Chagas', '03/03/2026', 'Realizado', 'Nutricionista', Colors.green),
                    _buildDataRow('Giovana Paula', '21/03/2026', 'Cancelada', 'Ginecologista', Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),


            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionButton('Consultas', Icons.forum_outlined, Colors.blue),
                _buildActionButton('Consultas pendentes', Icons.pending_actions, Colors.orange),
                _buildActionButton('Consultas canceladas', Icons.cancel_outlined, Colors.red),
              ],
            ),
            const SizedBox(height: 24),


            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MENSAL',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TableCalendar(
                      firstDay: DateTime.utc(2026, 1, 1),
                      lastDay: DateTime.utc(2026, 12, 31),
                      focusedDay: DateTime(2026, 3, 1),
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                      availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
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

  Widget _buildDrawerItem(IconData icon, String title, [bool isBold = false] ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {},
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool changeNegative = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (subtitle.contains('%') || changeNegative)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: changeNegative ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(changeNegative ? Icons.trending_down : Icons.trending_up, size: 16, color: changeNegative ? Colors.red : Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          subtitle.replaceAll('este mês', '').trim(),
                          style: TextStyle(color: changeNegative ? Colors.red : Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String name, String date, String status, String type, Color statusColor) {
    return DataRow(cells: [
      DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(date)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ),
      DataCell(Text(type)),
      DataCell(
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEFF6FF),
            foregroundColor: const Color(0xFF3B82F6),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Ver'),
        ),
      ),
    ]);
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}