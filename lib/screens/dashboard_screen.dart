import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:super_inventario/screens/productos_screen.dart';
import 'package:super_inventario/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalProductos = 0;
  int _stockBajo = 0;
  int _totalCategorias = 0;
  int _selectedIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final supabase = Supabase.instance.client;
    final productos = await supabase.from('productos').select();
    final categorias = await supabase.from('categorias').select();
    setState(() {
      _totalProductos = productos.length;
      _stockBajo = productos
          .where((p) => (p['cantidad'] as int) < 10)
          .length;
      _totalCategorias = categorias.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Container(
          width: 220,
          color: const Color(0xFF16213E),
          child: Column(children: [
            Container(
              height: 60,
              color: const Color(0xFF0F1726),
              alignment: Alignment.center,
              child: const Text('SuperInventario',
                style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            _menuItem('🏠  Dashboard', 0),
            _menuItem('📦  Productos', 1),
            _menuItem('🏷️  Categorías', 2),
            const Spacer(),
            _logoutBtn(),
          ]),
        ),
        Expanded(child: Column(children: [
          Container(
            height: 50,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            child: Text(
              _selectedIndex == 0
                ? 'Dashboard — Resumen del inventario'
                : _selectedIndex == 1
                  ? 'Gestión de Productos'
                  : 'Categorías',
              style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          Expanded(child: _selectedIndex == 0
            ? _dashboardContent()
            : _selectedIndex == 1
              ? ProductosScreen()
              : _placeholderCategorias()),
        ])),
      ]),
    );
  }

  Widget _menuItem(String label, int index) {
    final active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        height: 44,
        color: active ? const Color(0xFF32507A) : Colors.transparent,
        padding: const EdgeInsets.only(left: 16),
        alignment: Alignment.centerLeft,
        child: Row(children: [
          if (active) Container(width: 4, height: 44,
            color: const Color(0xFF3ECF8E)),
          if (active) const SizedBox(width: 8),
          Text(label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 13,
              fontWeight: active
                ? FontWeight.bold : FontWeight.normal)),
        ]),
      ),
    );
  }

  Widget _logoutBtn() {
    return GestureDetector(
      onTap: () async {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => LoginScreen()));
        }
      },
      child: Container(
        height: 48,
        color: const Color(0xFF0F1726),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: const Text('🚪  Cerrar sesión',
          style: TextStyle(color: Colors.redAccent, fontSize: 12)),
      ),
    );
  }

  Widget _dashboardContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen del inventario',
            style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            _statCard('Total Productos',
              '$_totalProductos', 'unidades registradas',
              const Color(0xFF0D6EFD)),
            const SizedBox(width: 16),
            _statCard('Stock Bajo',
              '$_stockBajo', 'productos críticos',
              const Color(0xFFDC3545)),
            const SizedBox(width: 16),
            _statCard('Categorías',
              '$_totalCategorias', 'tipos de productos',
              const Color(0xFF198754)),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value,
      String sub, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value, style: const TextStyle(
          color: Colors.white, fontSize: 32,
          fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(
          color: Colors.white, fontSize: 13)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(
          color: Colors.white70, fontSize: 11)),
      ]),
    ));
  }

  Widget _placeholderCategorias() {
    return const Center(
      child: Text('Módulo Categorías — próximamente',
        style: TextStyle(color: Colors.grey)));
  }
}