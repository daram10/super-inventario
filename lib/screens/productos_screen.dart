import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});
  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _filtrados = [];
  final _busqueda = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    _busqueda.addListener(_filtrar);
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    final p = await supabase
        .from('productos')
        .select('*, categorias(nombre)')
        .order('nombre');
    final c = await supabase
        .from('categorias')
        .select()
        .order('nombre');
    setState(() {
      _productos = List<Map<String, dynamic>>.from(p);
      _categorias = List<Map<String, dynamic>>.from(c);
      _filtrados = _productos;
      _loading = false;
    });
  }

  void _filtrar() {
    final q = _busqueda.text.toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? _productos
          : _productos.where((p) =>
              p['nombre'].toString().toLowerCase().contains(q) ||
              p['codigo'].toString().toLowerCase().contains(q))
            .toList();
    });
  }

  void _mostrarForm({Map<String, dynamic>? producto}) {
    final codigoCtrl = TextEditingController(
        text: producto?['codigo'] ?? '');
    final nombreCtrl = TextEditingController(
        text: producto?['nombre'] ?? '');
    final precioCtrl = TextEditingController(
        text: producto?['precio']?.toString() ?? '');
    final cantCtrl = TextEditingController(
        text: producto?['cantidad']?.toString() ?? '');
    String? catId = producto?['categoria_id'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(producto == null
              ? 'Agregar producto'
              : 'Editar producto'),
          content: SizedBox(width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _campo(codigoCtrl, 'Código del producto'),
                  _campo(nombreCtrl, 'Nombre del producto'),
                  Row(children: [
                    Expanded(child: _campo(
                        precioCtrl, 'Precio (COP)',
                        isNum: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _campo(
                        cantCtrl, 'Cantidad',
                        isNum: true)),
                  ]),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: catId,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder()),
                    items: _categorias.map((c) =>
                      DropdownMenuItem(
                        value: c['id'] as String,
                        child: Text(c['nombre'])
                      )).toList(),
                    onChanged: (v) =>
                        setS(() => catId = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16213E)),
              onPressed: () async {
                final data = {
                  'codigo': codigoCtrl.text.trim(),
                  'nombre': nombreCtrl.text.trim(),
                  'precio': double.tryParse(
                      precioCtrl.text) ?? 0,
                  'cantidad': int.tryParse(
                      cantCtrl.text) ?? 0,
                  'categoria_id': catId,
                };
                if (producto == null) {
                  await supabase
                      .from('productos')
                      .insert(data);
                } else {
                  await supabase
                      .from('productos')
                      .update(data)
                      .eq('id', producto['id']);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
              },
              child: const Text('Guardar',
                style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminar(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar producto?'),
        content: Text(
            '¿Seguro que desea eliminar "${p['nombre']}"?\n'
            'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              await supabase
                  .from('productos')
                  .delete()
                  .eq('id', p['id']);
              if (context.mounted) Navigator.pop(context);
              _cargar();
            },
            child: const Text('Eliminar',
              style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _campo(TextEditingController c, String label,
      {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: isNum
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // ── Toolbar ────────────────────────────
        Row(children: [
          Expanded(child: TextField(
            controller: _busqueda,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o código...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8),
            ),
          )),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16213E),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12)),
            onPressed: () => _mostrarForm(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Agregar producto',
              style: TextStyle(color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 16),
        // ── Encabezado tabla ───────────────────
        Container(
          color: const Color(0xFFE9ECEF),
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          child: Row(children: const [
            SizedBox(width: 110,
              child: Text('Código', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13))),
            Expanded(child: Text('Nombre', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13))),
            SizedBox(width: 130,
              child: Text('Categoría', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13))),
            SizedBox(width: 90,
              child: Text('Precio', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13))),
            SizedBox(width: 70,
              child: Text('Stock', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13))),
            SizedBox(width: 100,
              child: Text('Acciones', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13))),
          ]),
        ),
        // ── Filas de productos ─────────────────
        Expanded(child: _filtrados.isEmpty
          ? const Center(
              child: Text('No se encontraron productos.',
                style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: _filtrados.length,
              itemBuilder: (_, i) {
                final p = _filtrados[i];
                final bajo = (p['cantidad'] as int) < 10;
                return Container(
                  color: i.isEven
                      ? Colors.white
                      : const Color(0xFFF8F9FA),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(children: [
                    SizedBox(width: 110,
                      child: Text(p['codigo'],
                        style: const TextStyle(
                            fontSize: 12))),
                    Expanded(
                      child: Text(p['nombre'],
                        style: const TextStyle(
                            fontSize: 12))),
                    SizedBox(width: 130,
                      child: Text(
                        p['categorias']?['nombre'] ?? '—',
                        style: const TextStyle(
                            fontSize: 12))),
                    SizedBox(width: 90,
                      child: Text(
                        '\$${p['precio']}',
                        style: const TextStyle(
                            fontSize: 12))),
                    SizedBox(width: 70,
                      child: Text(
                        '${p['cantidad']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: bajo
                              ? Colors.red
                              : Colors.green,
                          fontWeight:
                              FontWeight.bold))),
                    SizedBox(width: 100,
                      child: Row(children: [
                        IconButton(
                          icon: const Icon(
                              Icons.edit, size: 18),
                          color: Colors.blue,
                          onPressed: () =>
                              _mostrarForm(producto: p)),
                        IconButton(
                          icon: const Icon(
                              Icons.delete, size: 18),
                          color: Colors.red,
                          onPressed: () =>
                              _eliminar(p)),
                      ])),
                  ]),
                );
              },
            ),
        ),
        // ── Resultado búsqueda ─────────────────
        if (_busqueda.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_filtrados.length} resultado(s) '
              'para "${_busqueda.text}"',
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12)),
          ),
      ]),
    );
  }
}