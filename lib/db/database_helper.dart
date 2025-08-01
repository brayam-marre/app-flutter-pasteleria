import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/producto.dart';
import '../models/receta.dart';
import '../models/receta_producto.dart';
import '../models/compra.dart';
import '../models/compra_producto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'productos.db');
    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuario INTEGER,
        nombre TEXT,
        unidad TEXT,
        cantidad REAL,
        valor REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE recetas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuario INTEGER,
        nombre TEXT,
        porciones INTEGER,
        porcentajeGanancia REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE receta_productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idReceta INTEGER,
        nombreProducto TEXT,
        unidad TEXT,
        cantidadUsada REAL,
        costoUnitario REAL,
        FOREIGN KEY (idReceta) REFERENCES recetas(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE compras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuario INTEGER,
        nombre TEXT,
        fecha TEXT,
        total REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE compra_productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCompra INTEGER,
        nombreProducto TEXT,
        unidad TEXT,
        peso REAL,
        valor REAL,
        FOREIGN KEY (idCompra) REFERENCES compras(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        rol TEXT,
        activo INTEGER DEFAULT 1,
        ultimo_login TEXT
      )
    ''');

    await db.insert('usuarios', {
      'username': 'admin',
      'password': 'admin123',
      'rol': 'administrador',
      'activo': 1,
      'ultimo_login': null
    });

    await db.insert('usuarios', {
      'username': 'usuario',
      'password': 'usuario123',
      'rol': 'usuario',

      'activo': 1,
      'ultimo_login': null
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE productos ADD COLUMN valor REAL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE recetas ADD COLUMN porcentajeGanancia REAL DEFAULT 0');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE usuarios(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT,
          rol TEXT
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE usuarios ADD COLUMN activo INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE usuarios ADD COLUMN ultimo_login TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE productos ADD COLUMN idUsuario INTEGER');
      await db.execute('ALTER TABLE recetas ADD COLUMN idUsuario INTEGER');
      await db.execute('ALTER TABLE compras ADD COLUMN idUsuario INTEGER');
    }
  }

  // ------------------- USUARIOS -------------------

  Future<Map<String, dynamic>?> validarUsuario(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'username = ? AND password = ? AND activo = 1',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      final id = result.first['id'];
      final now = DateTime.now().toIso8601String();
      await db.update(
        'usuarios',
        {'ultimo_login': now},
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final db = await database;
    return await db.query('usuarios', orderBy: 'username');
  }

  Future<int> insertarUsuario(String username, String password, String rol) async {
    final db = await database;
    return await db.insert('usuarios', {
      'username': username,
      'password': password,
      'rol': rol,
      'activo': 1,
      'ultimo_login': null,
    });
  }

  Future<int> actualizarContrasena(int id, String nuevaPassword) async {
    final db = await database;
    return await db.update(
      'usuarios',
      {'password': nuevaPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarUsuario(int id) async {
    final db = await database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> actualizarEstado(int id, bool activo) async {
    final db = await database;
    return await db.update(
      'usuarios',
      {'activo': activo ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> buscarUsuarios(String query) async {
    final db = await database;
    return await db.query(
      'usuarios',
      where: 'username LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'username',
    );
  }


  // ------------------- PRODUCTOS -------------------
  Future<int> insertarProducto(Producto producto) async {
    final db = await database;
    return await db.insert('productos', producto.toMap());
  }

  Future<List<Producto>> obtenerProductos(int idUsuario) async {
    final db = await database;
    final result = await db.query(
      'productos',
      where: 'idUsuario = ?',
      whereArgs: [idUsuario],
    );
    return result.map((e) => Producto.fromMap(e)).toList();
  }

  Future<int> actualizarProducto(Producto producto) async {
    final db = await database;
    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<int> eliminarProducto(int id) async {
    final db = await database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

// ------------------- RECETAS -------------------
  Future<int> insertarReceta(Receta receta, int idUsuario) async {
    final db = await database;
    final data = receta.toMap();
    data['idUsuario'] = idUsuario;
    return await db.insert('recetas', data);
  }

  Future<List<Receta>> obtenerRecetas(int idUsuario) async {
    final db = await database;
    final result = await db.query(
      'recetas',
      where: 'idUsuario = ?',
      whereArgs: [idUsuario],
    );
    return result.map((e) => Receta.fromMap(e)).toList();
  }

  Future<int> actualizarReceta(Receta receta) async {
    final db = await database;
    return await db.update(
      'recetas',
      receta.toMap(),
      where: 'id = ?',
      whereArgs: [receta.id],
    );
  }

  Future<int> eliminarReceta(int id) async {
    final db = await database;
    await db.delete('receta_productos', where: 'idReceta = ?', whereArgs: [id]);
    return await db.delete('recetas', where: 'id = ?', whereArgs: [id]);
  }

  Future<Receta?> obtenerRecetaPorId(int id) async {
    final db = await database;
    final result = await db.query('recetas', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Receta.fromMap(result.first) : null;
  }

  Future<void> eliminarProductosDeReceta(int idReceta) async {
    final db = await database;
    await db.delete('receta_productos', where: 'idReceta = ?', whereArgs: [idReceta]);
  }

// ------------------- PRODUCTOS DE RECETA -------------------
  Future<int> insertarProductoDeReceta(RecetaProducto producto) async {
    final db = await database;
    return await db.insert('receta_productos', producto.toMap());
  }

  Future<List<RecetaProducto>> obtenerProductosDeReceta(int idReceta) async {
    final db = await database;
    final result = await db.query(
      'receta_productos',
      where: 'idReceta = ?',
      whereArgs: [idReceta],
    );
    return result.map((e) => RecetaProducto.fromMap(e)).toList();
  }

  Future<int> eliminarProductoDeReceta(int id) async {
    final db = await database;
    return await db.delete('receta_productos', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------- COMPRAS -------------------
  Future<int> insertarCompra(Compra compra) async {
    final db = await database;
    return await db.insert('compras', compra.toMap());
  }

  Future<List<Compra>> obtenerCompras(int idUsuario) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'compras',
      where: 'idUsuario = ?',
      whereArgs: [idUsuario],
    );
    return maps.map((map) => Compra.fromMap(map)).toList();
  }


  Future<int> eliminarCompra(int id) async {
    final db = await database;
    await db.delete('compra_productos', where: 'idCompra = ?', whereArgs: [id]);
    return await db.delete('compras', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------- PRODUCTOS DE COMPRA -------------------
  Future<int> insertarProductoDeCompra(CompraProducto producto) async {
    final db = await database;
    return await db.insert('compra_productos', producto.toMap());
  }

  Future<List<CompraProducto>> obtenerProductosDeCompra(int idCompra) async {
    final db = await database;
    final result = await db.query(
      'compra_productos',
      where: 'idCompra = ?',
      whereArgs: [idCompra],
    );
    return result.map((e) => CompraProducto.fromMap(e)).toList();
  }
}
