// main.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Contatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 250, 250, 250),
          primary: const Color.fromARGB(255, 0, 0, 2),
          secondary: const Color.fromARGB(255, 255, 255, 255),
          surface: const Color(0xFFF8F9FA),
          background: const Color(0xFFF8F9FA),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

// Models
class Contato {
  int? id;
  String nome;
  String telefone;
  String email;
  String? foto;
  DateTime dataCriacao;
  double? valorReal;
  double? valorDolar;
  double? valorEuro;

  Contato({
    this.id,
    required this.nome,
    required this.telefone,
    required this.email,
    this.foto,
    required this.dataCriacao,
    this.valorReal,
    this.valorDolar,
    this.valorEuro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'foto': foto,
      'data_criacao': dataCriacao.toIso8601String(),
      'valor_real': valorReal,
      'valor_dolar': valorDolar,
      'valor_euro': valorEuro,
    };
  }

  factory Contato.fromMap(Map<String, dynamic> map) {
    return Contato(
      id: map['id'],
      nome: map['nome'],
      telefone: map['telefone'],
      email: map['email'],
      foto: map['foto'],
      dataCriacao: DateTime.parse(map['data_criacao']),
      valorReal: map['valor_real'],
      valorDolar: map['valor_dolar'],
      valorEuro: map['valor_euro'],
    );
  }
}

class ConversaoMoeda {
  final double valorReal;
  final double valorDolar;
  final double valorEuro;

  ConversaoMoeda({
    required this.valorReal,
    required this.valorDolar,
    required this.valorEuro,
  });
}

// Services
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static List<Contato> _contatos = [];

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<void> initDatabase() async {
    _contatos = [];
  }

  Future<int> insertContato(Contato contato) async {
    try {
      int id = _contatos.length + 1;
      contato.id = id;
      _contatos.add(contato);
      return id;
    } catch (e) {
      throw Exception('Erro ao inserir contato: $e');
    }
  }

  Future<List<Contato>> getContatos() async {
    try {
      return _contatos;
    } catch (e) {
      throw Exception('Erro ao recuperar contatos: $e');
    }
  }

  Future<Contato?> getContato(int id) async {
    try {
      for (var contato in _contatos) {
        if (contato.id == id) {
          return contato;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao recuperar contato: $e');
    }
  }

  Future<int> updateContato(Contato contato) async {
    try {
      for (int i = 0; i < _contatos.length; i++) {
        if (_contatos[i].id == contato.id) {
          _contatos[i] = contato;
          return 1;
        }
      }
      return 0;
    } catch (e) {
      throw Exception('Erro ao atualizar contato: $e');
    }
  }

  Future<int> deleteContato(int id) async {
    try {
      _contatos.removeWhere((contato) => contato.id == id);
      return 1;
    } catch (e) {
      throw Exception('Erro ao excluir contato: $e');
    }
  }
}

class CurrencyService {
  Future<ConversaoMoeda> converterValor(double valorReal) async {
    try {
      double cotacaoDolar = 5.20;
      double cotacaoEuro = 6.10;
      
      double valorDolar = valorReal / cotacaoDolar;
      double valorEuro = valorReal / cotacaoEuro;
      
      return ConversaoMoeda(
        valorReal: valorReal,
        valorDolar: valorDolar,
        valorEuro: valorEuro,
      );
    } catch (e) {
      throw Exception('Erro na conversão: $e');
    }
  }
}

class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> getImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 800,
    );
    
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }

  static Future<File?> getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
  
  static Future<String?> saveImage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'contact_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      return null;
    }
  }
}

class Validators {
  static String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um nome';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    
    return null;
  }

  static String? validateTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um telefone';
    }
    
    final telefoneRegex = RegExp(r'^\(\d{2}\) \d{4,5}-\d{4}$');
    if (!telefoneRegex.hasMatch(value)) {
      return 'Formato: (99) 99999-9999';
    }
    
    return null;
  }

  static String? validateValor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um valor';
    }
    
    try {
      double.parse(value.replaceAll(',', '.'));
      return null;
    } catch (e) {
      return 'Por favor, insira um valor numérico válido';
    }
  }
}

// Widgets
class CurrencyConverterWidget extends StatefulWidget {
  final Function(double, double, double) onConversaoRealizada;

  const CurrencyConverterWidget({
    super.key,
    required this.onConversaoRealizada,
  });

  @override
  State<CurrencyConverterWidget> createState() => _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  final TextEditingController _valorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  ConversaoMoeda? _resultadoConversao;
  final CurrencyService _currencyService = CurrencyService();

  Future<void> _converterValor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        double valorReal = double.parse(_valorController.text.replaceAll(',', '.'));
        final resultado = await _currencyService.converterValor(valorReal);
        
        setState(() {
          _resultadoConversao = resultado;
          _isLoading = false;
        });
        
        widget.onConversaoRealizada(
          valorReal,
          resultado.valorDolar,
          resultado.valorEuro,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro na conversão: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversão de Moeda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _valorController,
            decoration: const InputDecoration(
              labelText: 'Valor em Real (R\$)',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.attach_money, color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: Validators.validateValor,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
              ),
              onPressed: _isLoading ? null : _converterValor,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Converter', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          if (_resultadoConversao != null) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultado:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${_resultadoConversao!.valorReal.toStringAsFixed(2)} = US\$ ${_resultadoConversao!.valorDolar.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'R\$ ${_resultadoConversao!.valorReal.toStringAsFixed(2)} = € ${_resultadoConversao!.valorEuro.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ContatoCard extends StatelessWidget {
  final Contato contato;
  final Function onDelete;
  final Function onRefresh;

  const ContatoCard({
    super.key,
    required this.contato,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContatoFormScreen(
                contato: contato,
                onRefresh: () => onRefresh(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto do contato
                  Hero(
                    tag: 'contact-${contato.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: contato.foto != null
                            ? Image.file(
                                File(contato.foto!),
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, obj, stack) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informações do contato
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contato.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contato.telefone,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          contato.email,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cadastrado em: ${dateFormat.format(contato.dataCriacao)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (contato.valorReal != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Valor em Real: R\$ ${contato.valorReal!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Valor em Dólar: US\$ ${contato.valorDolar!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Valor em Euro: € ${contato.valorEuro!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Botões de ação
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContatoFormScreen(
                                contato: contato,
                                onRefresh: () => onRefresh(),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.redAccent,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Excluir Contato'),
                              content: Text('Tem certeza que deseja excluir ${contato.nome}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    onDelete(contato.id!);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoCapture extends StatelessWidget {
  final String? currentPhotoPath;
  final Function(String) onPhotoSelected;

  const PhotoCapture({
    super.key,
    this.currentPhotoPath,
    required this.onPhotoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: currentPhotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.file(
                          File(currentPhotoPath!),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, obj, stack) => const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
              ),
              GestureDetector(
                onTap: () => _showPhotoOptions(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
              title: Text('Tirar foto', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () async {
                Navigator.pop(context);
                final file = await PhotoService.getImageFromCamera();
                if (file != null) {
                  final path = await PhotoService.saveImage(file);
                  if (path != null) {
                    onPhotoSelected(path);
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
              title: Text('Escolher da galeria', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () async {
                Navigator.pop(context);
                final file = await PhotoService.getImageFromGallery();
                if (file != null) {
                  final path = await PhotoService.saveImage(file);
                  if (path != null) {
                    onPhotoSelected(path);
                  }
                }
              },
            ),
            if (currentPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Remover foto', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  onPhotoSelected('');
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Screens
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Contato> _contatos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _databaseHelper.initDatabase().then((_) {
      _carregarContatos();
    });
  }

  Future<void> _carregarContatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contatos = await _databaseHelper.getContatos();
      setState(() {
        _contatos = contatos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar contatos: ${e.toString()}';
      });
    }
  }

  Future<void> _excluirContato(int id) async {
    try {
      await _databaseHelper.deleteContato(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contato excluído com sucesso'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      _carregarContatos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir contato: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Contatos'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarContatos,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContatoFormScreen(
                onRefresh: _carregarContatos,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _carregarContatos,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_contatos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum contato encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContatoFormScreen(
                      onRefresh: _carregarContatos,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Contato'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarContatos,
      child: ListView.builder(
        itemCount: _contatos.length,
        itemBuilder: (context, index) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ContatoCard(
              key: ValueKey(_contatos[index].id),
              contato: _contatos[index],
              onDelete: _excluirContato,
              onRefresh: _carregarContatos,
            ),
          );
        },
      ),
    );
  }
}

class ContatoFormScreen extends StatefulWidget {
  final Contato? contato;
  final Function onRefresh;

  const ContatoFormScreen({
    super.key,
    this.contato,
    required this.onRefresh,
  });

  @override
  State<ContatoFormScreen> createState() => _ContatoFormScreenState();
}

class _ContatoFormScreenState extends State<ContatoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _photoPath;
  
  double? _valorReal;
  double? _valorDolar; 
  double? _valorEuro;

  @override
  void initState() {
    super.initState();
    if (widget.contato != null) {
      _nomeController.text = widget.contato!.nome;
      _telefoneController.text = widget.contato!.telefone;
      _emailController.text = widget.contato!.email;
      _photoPath = widget.contato!.foto;
      _valorReal = widget.contato!.valorReal;
      _valorDolar = widget.contato!.valorDolar;
      _valorEuro = widget.contato!.valorEuro;
    }
  }

  void _onPhotoSelected(String path) {
    setState(() {
      _photoPath = path.isEmpty ? null : path;
    });
  }

  void _onConversaoRealizada(double real, double dolar, double euro) {
    setState(() {
      _valorReal = real;
      _valorDolar = dolar;
      _valorEuro = euro;
    });
  }

  Future<void> _salvarContato() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final contato = Contato(
          id: widget.contato?.id,
          nome: _nomeController.text,
          telefone: _telefoneController.text,
          email: _emailController.text,
          foto: _photoPath,
          dataCriacao: widget.contato?.dataCriacao ?? DateTime.now(),
          valorReal: _valorReal,
          valorDolar: _valorDolar,
          valorEuro: _valorEuro,
        );

        if (widget.contato == null) {
          await _databaseHelper.insertContato(contato);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Contato adicionado com sucesso'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        } else {
          await _databaseHelper.updateContato(contato);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Contato atualizado com sucesso'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }

        widget.onRefresh();
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao salvar contato: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contato == null ? 'Novo Contato' : 'Editar Contato'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4D8DEE),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Componente de foto
                  PhotoCapture(
                    currentPhotoPath: _photoPath,
                    onPhotoSelected: _onPhotoSelected,
                  ),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      labelStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.person, color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: Validators.validateNome,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      labelStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.phone, color: Colors.white70),
                      hintText: '(99) 99999-9999',
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    validator: Validators.validateTelefone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.email, color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  CurrencyConverterWidget(
                    onConversaoRealizada: _onConversaoRealizada,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _isLoading ? null : _salvarContato,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              widget.contato == null ? 'Adicionar Contato' : 'Atualizar Contato',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (widget.contato != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações do registro:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Data de cadastro: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.contato!.dataCriacao)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}