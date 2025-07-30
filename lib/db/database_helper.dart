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
      version: 3, // 🔺 Nueva versión
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        unidad TEXT,
        cantidad REAL,
        valor REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE recetas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE productos ADD COLUMN valor REAL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE recetas ADD COLUMN porcentajeGanancia REAL DEFAULT 0');
    }
  }

  // ------------------- PRODUCTOS -------------------
  Future<int> insertarProducto(Producto producto) async {
    final db = await database;
    return await db.insert('productos', producto.toMap());
  }

  Future<List<Producto>> obtenerProductos() async {
    final db = await database;
    final result = await db.query('productos');
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
  Future<int> insertarReceta(Receta receta) async {
    final db = await database;
    return await db.insert('recetas', receta.toMap());
  }

  Future<List<Receta>> obtenerRecetas() async {
    final db = await database;
    final result = await db.query('recetas');
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
    final maps = await db.query(
      'recetas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Receta.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> eliminarProductosDeReceta(int idReceta) async {
    final db = await database;
    await db.delete(
      'receta_productos',
      where: 'idReceta = ?',
      whereArgs: [idReceta],
    );
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

  Future<List<Compra>> obtenerCompras() async {
    final db = await database;
    final result = await db.query('compras');
    return result.map((e) => Compra.fromMap(e)).toList();
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
