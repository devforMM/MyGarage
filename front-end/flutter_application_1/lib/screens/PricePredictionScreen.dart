import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "../providers/TokenProvider.dart";
import "../services/user_services.dart";
import '../routes.dart';
import '../theme/app_theme.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  // ================= DONNÉES JSON DE RÉFÉRENCE =================
  List<Map<String, dynamic>> allCarConfigs = [];
  List<Map<String, dynamic>> filteredConfigs = [];

  // ================= CONTROLLERS =================
  final yearController = TextEditingController();
  final kmController = TextEditingController();
  final colorController = TextEditingController(); 

  // ================= VALEURS SÉLECTIONNÉES =================
  String? make;
  String? model;
  String? trim;
  String? fuel;
  String? transmission;
  String? bodyType;
  String? driveTrain;
  String? engineSize;
  String? enginePower;
  String? doors;
  String? seats;

  // ================= LISTES DYNAMIQUES FILTRÉES =================
  List<String> availableMakes = [];
  List<String> availableModels = [];
  List<String> availableTrims = [];
  List<String> availableFuels = [];
  List<String> availableTransmissions = [];
  List<String> availableBodyTypes = [];
  List<String> availableDriveTrains = [];
  List<String> availableEngineSizes = [];
  List<String> availableEnginePowers = [];
  List<String> availableDoors = [];
  List<String> availableSeats = [];

  bool loading = false;
  String? predictionResult;
  double? predictedPrice;
  Map<String, dynamic>? carDetails;

  @override
  void initState() {
    super.initState();
    _loadCarConfigs();
  }

  Future<void> _loadCarConfigs() async {
    try {
      final String response = await rootBundle.loadString('assets/cars_config.json');
      final List<dynamic> data = json.decode(response);
      
      setState(() {
        allCarConfigs = List<Map<String, dynamic>>.from(data);
        filteredConfigs = List.from(allCarConfigs);
        _updateAvailableOptions();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error loading configurations: $e")),
      );
    }
  }

  void _updateAvailableOptions() {
    setState(() {
      filteredConfigs = allCarConfigs.where((car) {
        if (make != null && car['make'].toString() != make) return false;
        if (model != null && car['model'].toString() != model) return false;
        if (trim != null && car['trim'].toString() != trim) return false;
        if (fuel != null && car['fuel'].toString() != fuel) return false;
        if (transmission != null && car['transmission'].toString() != transmission) return false;
        if (bodyType != null && car['body_type'].toString() != bodyType) return false;
        if (driveTrain != null && car['drive_train'].toString() != driveTrain) return false;
        if (engineSize != null && car['engine_size'].toString() != engineSize) return false;
        if (enginePower != null && car['engine_power'].toString() != enginePower) return false;
        if (doors != null && car['doors'].toString() != doors) return false;
        if (seats != null && car['seats'].toString() != seats) return false;
        return true;
      }).toList();

      availableMakes = _getUniqueValues('make', allCarConfigs); 
      availableModels = _getUniqueValues('model', make != null ? allCarConfigs.where((c) => c['make'].toString() == make).toList() : allCarConfigs);
      availableTrims = _getUniqueValues('trim', filteredConfigs);
      availableFuels = _getUniqueValues('fuel', filteredConfigs);
      availableTransmissions = _getUniqueValues('transmission', filteredConfigs);
      availableBodyTypes = _getUniqueValues('body_type', filteredConfigs);
      availableDriveTrains = _getUniqueValues('drive_train', filteredConfigs);
      availableEngineSizes = _getUniqueValues('engine_size', filteredConfigs);
      availableEnginePowers = _getUniqueValues('engine_power', filteredConfigs);
      availableDoors = _getUniqueValues('doors', filteredConfigs);
      availableSeats = _getUniqueValues('seats', filteredConfigs);

      if (make != null && !availableMakes.contains(make)) make = null;
      if (model != null && !availableModels.contains(model)) model = null;
      if (trim != null && !availableTrims.contains(trim)) trim = null;
      if (fuel != null && !availableFuels.contains(fuel)) fuel = null;
      if (transmission != null && !availableTransmissions.contains(transmission)) transmission = null;
      if (bodyType != null && !availableBodyTypes.contains(bodyType)) bodyType = null;
      if (driveTrain != null && !availableDriveTrains.contains(driveTrain)) driveTrain = null;
      if (engineSize != null && !availableEngineSizes.contains(engineSize)) engineSize = null;
      if (enginePower != null && !availableEnginePowers.contains(enginePower)) enginePower = null;
      if (doors != null && !availableDoors.contains(doors)) doors = null;
      if (seats != null && !availableSeats.contains(seats)) seats = null;
    });
  }

  List<String> _getUniqueValues(String key, List<Map<String, dynamic>> list) {
    var values = list.where((e) => e[key] != null).map((e) => e[key].toString()).toSet().toList();
    values.sort((a, b) {
      double? numA = double.tryParse(a);
      double? numB = double.tryParse(b);
      if (numA != null && numB != null) return numA.compareTo(numB);
      return a.compareTo(b);
    });
    return values;
  }

  bool _validateForm() {
    if (make == null || model == null || trim == null || fuel == null || 
        transmission == null || bodyType == null || driveTrain == null || 
        engineSize == null || enginePower == null || colorController.text.trim().isEmpty || 
        doors == null || seats == null || yearController.text.trim().isEmpty || kmController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields"), backgroundColor: Colors.redAccent),
      );
      return false;
    }
    return true;
  }

  Future<void> predict() async {
    if (!_validateForm()) return;

    setState(() {
      loading = true;
      predictionResult = null;
    });

    try {
      final token = context.read<TokenProvider>().token;

      final price = await predictPrice(
        year: int.parse(yearController.text),
        kilometres: double.parse(kmController.text),
        make: make!,
        model: model!,
        trim: trim!,
        fuel: fuel!,
        transmission: transmission!,
        bodyType: bodyType!,
        doors: double.tryParse(doors ?? '')?.toInt() ?? 0,
        seats: double.tryParse(seats ?? '')?.toInt() ?? 0,
        engineSize: double.parse(engineSize!),
        enginePower: double.parse(enginePower!),
        driveTrain: driveTrain!,
        color: colorController.text.trim(), 
        token: token!,
      );

      setState(() {
        loading = false;
        predictedPrice = price;
        carDetails = {
          "make": make,
          "model": model,
          "trim": trim,
          "year": int.parse(yearController.text),
          "fuel": fuel,
          "transmission": transmission,
          "bodyType": bodyType,
          "kilometres": double.parse(kmController.text),
          "enginePower": double.parse(enginePower!),
          "color": colorController.text.trim(), 
        };
        predictionResult = "Success";
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${e.toString().replaceFirst('Exception: ', '')}"), backgroundColor: Colors.redAccent),
      );
    }
  }

  // ================= ELEMENTS DE CONCEPTION GRAPHIQUE (UI) =================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget buildField({required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5)),
        ),
      ),
    );
  }

  Widget buildDropdown({required String label, required String? value, required List<String> items, required Function(String?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        dropdownColor: const Color(0xFF132534),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDetailGridTile({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.secondary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label, 
                  style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080F18), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF080F18),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("AI Valuation", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard_route, (route) => false),
          ),
        ],
      ),
      body: SafeArea(
        child: allCarConfigs.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.secondary))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Smart Price Predictor", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text("Evaluate car market prices instantly with machine learning.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 25),

                    // FORMULAIRE PRINCIPAL
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1B2B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: Column(
                        children: [
                          _buildSectionTitle("Vehicle Identity", Icons.directions_car_filled_rounded),
                          buildDropdown(label: "Make", value: make, items: availableMakes, onChanged: (v) => setState(() { make = v; _updateAvailableOptions(); })),
                          buildDropdown(label: "Model", value: model, items: availableModels, onChanged: (v) => setState(() { model = v; _updateAvailableOptions(); })),
                          buildDropdown(label: "Trim/Version", value: trim, items: availableTrims, onChanged: (v) => setState(() { trim = v; _updateAvailableOptions(); })),
                          
                          const SizedBox(height: 10),
                          _buildSectionTitle("Technical Specs", Icons.tune_rounded),
                          buildDropdown(label: "Fuel Type", value: fuel, items: availableFuels, onChanged: (v) => setState(() { fuel = v; _updateAvailableOptions(); })),
                          buildDropdown(label: "Transmission", value: transmission, items: availableTransmissions, onChanged: (v) => setState(() { transmission = v; _updateAvailableOptions(); })),
                          buildDropdown(label: "Body Type", value: bodyType, items: availableBodyTypes, onChanged: (v) => setState(() { bodyType = v; _updateAvailableOptions(); })),
                          buildDropdown(label: "Drivetrain", value: driveTrain, items: availableDriveTrains, onChanged: (v) => setState(() { driveTrain = v; _updateAvailableOptions(); })),
                          Row(
                            children: [
                              Expanded(child: buildDropdown(label: "Engine Size", value: engineSize, items: availableEngineSizes, onChanged: (v) => setState(() { engineSize = v; _updateAvailableOptions(); }))),
                              const SizedBox(width: 14),
                              Expanded(child: buildDropdown(label: "Power (hp)", value: enginePower, items: availableEnginePowers, onChanged: (v) => setState(() { enginePower = v; _updateAvailableOptions(); }))),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: buildDropdown(label: "Doors", value: doors, items: availableDoors, onChanged: (v) => setState(() { doors = v; _updateAvailableOptions(); }))),
                              const SizedBox(width: 14),
                              Expanded(child: buildDropdown(label: "Seats", value: seats, items: availableSeats, onChanged: (v) => setState(() { seats = v; _updateAvailableOptions(); }))),
                            ],
                          ),

                          const SizedBox(height: 10),
                          _buildSectionTitle("Condition & State", Icons.analytics_rounded),
                          buildField(label: "Exterior Color", controller: colorController),
                          Row(
                            children: [
                              Expanded(child: buildField(label: "Year Model", controller: yearController, keyboardType: TextInputType.number)),
                              const SizedBox(width: 14),
                              Expanded(child: buildField(label: "Mileage (km)", controller: kmController, keyboardType: TextInputType.number)),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: loading ? null : predict,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 56,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: loading ? [Colors.grey.shade800, Colors.grey.shade700] : [AppTheme.secondary, const Color(0xFF00ADB5)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  if (!loading) BoxShadow(color: AppTheme.secondary.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 5))
                                ]
                              ),
                              child: Center(
                                child: loading 
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt_rounded, color: Color(0xFF080F18), size: 22),
                                        SizedBox(width: 6),
                                        Text("Calculate Value", style: TextStyle(color: Color(0xFF080F18), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.3)),
                                      ],
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= DESIGN CARTE RÉSULTAT HAUT DE GAMME =================
// ================= DESIGN CARTE RÉSULTAT HAUT DE GAMME =================
if (predictionResult != null && carDetails != null) ...[
  const SizedBox(height: 24),
  Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFF0F1B2B),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.secondary.withOpacity(0.2), width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle),
                child: const Icon(Icons.stars_rounded, color: AppTheme.secondary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${carDetails!['make']} ${carDetails!['model']}".toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(carDetails!['trim'], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.02), Colors.white.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.03))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("MARKET VALUE ESTIMATION", style: TextStyle(color: AppTheme.secondary.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 10),
              Text("${predictedPrice!.toStringAsFixed(0)} €", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ],
          ),
        ),

        // REMPLACEMENT DU GRIDVIEW PAR DES ROWS INDÉPENDANTES (ZÉRO OVERFLOW POSSIBLE)
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildDetailGridTile(icon: Icons.calendar_today_rounded, label: "Year Model", value: "${carDetails!['year'] }")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDetailGridTile(icon: Icons.speed_rounded, label: "Mileage", value: "${(carDetails!['kilometres'] as double).toStringAsFixed(0)} km")),
                ],
              ),
              const SizedBox(height: 12), // Espace entre les deux lignes
              Row(
                children: [
                  Expanded(child: _buildDetailGridTile(icon: Icons.local_gas_station_rounded, label: "Fuel", value: carDetails!['fuel'])),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDetailGridTile(icon: Icons.electric_car_rounded, label: "Power", value: "${carDetails!['enginePower'].toStringAsFixed(0)} hp")),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 20),
],
                  ],
                ),
              ),
      ),
    );
  }
}