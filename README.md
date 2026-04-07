# SuperInventario 🛒

Aplicación web para la gestión de inventario de un supermercado de pequeña superficie, desarrollada con **Flutter Web** y **Supabase** como proyecto formativo del programa Tecnólogo en Análisis y Desarrollo de Software — SENA.

---

## 📋 Descripción

SuperInventario es un sistema CRUD completo que permite al personal del supermercado registrar, consultar, actualizar y eliminar productos del inventario de forma sencilla desde cualquier navegador web.

---

## ✨ Funcionalidades

- 🔐 Autenticación de usuarios (login / logout)
- 🏠 Dashboard con resumen del inventario en tiempo real
- 📦 Gestión completa de productos (CRUD)
- 🔍 Búsqueda de productos por nombre o código
- 🏷️ Gestión de categorías
- ⚠️ Alerta visual de productos con stock bajo
- 📱 Interfaz responsiva accesible desde cualquier dispositivo

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Versión | Uso |
|-----------|---------|-----|
| Flutter | 3.19+ | Framework de desarrollo web |
| Dart | 3.3+ | Lenguaje de programación |
| Supabase | 2.12+ | Backend, base de datos y autenticación |
| PostgreSQL | 15+ | Base de datos relacional (vía Supabase) |
| GitHub Pages | — | Hosting del sitio web |

---

## 🗂️ Estructura del proyecto

```
super_inventario/
├── lib/
│   ├── main.dart                    # Punto de entrada y configuración
│   └── screens/
│       ├── login_screen.dart        # Pantalla de inicio de sesión
│       ├── dashboard_screen.dart    # Dashboard principal
│       └── productos_screen.dart   # Gestión de productos CRUD
├── web/
│   └── index.html                  # Entrada web
├── pubspec.yaml                    # Dependencias del proyecto
└── README.md
```

---

## 🗄️ Modelo de base de datos

### Tabla: `categorias`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID | Identificador único (PK) |
| nombre | VARCHAR(50) | Nombre de la categoría |
| created_at | TIMESTAMP | Fecha de creación |

### Tabla: `productos`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID | Identificador único (PK) |
| codigo | VARCHAR(20) | Código único del producto |
| nombre | VARCHAR(100) | Nombre del producto |
| precio | DECIMAL(10,2) | Precio unitario |
| cantidad | INTEGER | Stock disponible |
| descripcion | TEXT | Descripción opcional |
| categoria_id | UUID | Referencia a categorías (FK) |
| created_at | TIMESTAMP | Fecha de registro |

---

## 🚀 Instalación y configuración local

### Prerrequisitos

- Flutter SDK 3.19+
- Cuenta en Supabase
- Git
- Google Chrome

### Pasos

**1. Clonar el repositorio**
```bash
git clone https://github.com/daram10/super-inventario.git
cd super-inventario
```

**2. Instalar dependencias**
```bash
flutter pub get
```

**3. Configurar Supabase**

En `lib/main.dart` reemplaza las credenciales:
```dart
await Supabase.initialize(
  url: 'TU_SUPABASE_URL',
  anonKey: 'TU_SUPABASE_ANON_KEY',
);
```

**4. Crear las tablas en Supabase**

Ejecuta el script SQL en el SQL Editor de Supabase:
```sql
CREATE TABLE categorias (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE productos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  codigo VARCHAR(20) UNIQUE NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
  descripcion TEXT,
  categoria_id UUID REFERENCES categorias(id),
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all" ON productos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON categorias FOR ALL USING (true) WITH CHECK (true);
```

**5. Crear usuario de prueba**

En Supabase → Authentication → Users → Add user:
- Email: `admin@supermercado.com`
- Password: `Admin1234`

**6. Ejecutar la aplicación**
```bash
flutter run -d chrome
```

---

## 🌐 Despliegue en producción

**1. Compilar para web**
```bash
flutter build web --release
```

**2. Copiar build a la raíz**
```bash
cp -r build/web/* .
git add .
git commit -m "Deploy"
git push
```

**3. Activar GitHub Pages**

GitHub → Settings → Pages → Branch: main → Save

---

## 👤 Autora

**Danna Ramirez**
Aprendiz — Tecnólogo en Análisis y Desarrollo de Software
SENA — Programa 228118

---

## 📄 Evidencia académica

Este proyecto corresponde a las evidencias:
- GA10-220501097-AA3-EV01 — Software instalado en la plataforma del cliente
- GA10-220501097-AA10-EV01 — Manual técnico del software
- GA10-220501097-AA11-EV01 — Manual de usuario
- GA10-220501097-AA12-EV01 — Plan de capacitación y video tutorial

---

## 📚 Referencias

- Flutter. (2024). *Flutter documentation*. https://flutter.dev/docs
- Supabase. (2024). *Supabase documentation*. https://supabase.com/docs
- Pressman, R. S., y Maxim, B. R. (2021). *Ingeniería del software* (9.a ed.). McGraw-Hill.
- Sommerville, I. (2016). *Ingeniería de software* (10.a ed.). Pearson.
