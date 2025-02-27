import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const WaterReminderApp());
}

class WaterReminderApp extends StatelessWidget {
  const WaterReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade400,
          secondary: Colors.lightBlue.shade200,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const WaterTrackerPage(),
    );
  }
}

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({super.key});

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage> with SingleTickerProviderStateMixin {
  // Variables for water tracking
  int totalWaterGoal = 2000; // in ml
  int currentWater = 0;
  late TextEditingController _waterController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _waterController = TextEditingController();
    
    // Setup animations for water level
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waterController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Add water to the tracker
  void _addWater() {
    if (_waterController.text.isNotEmpty) {
      final waterAmount = int.tryParse(_waterController.text) ?? 0;
      if (waterAmount > 0) {
        setState(() {
          currentWater += waterAmount;
          if (currentWater > totalWaterGoal) {
            currentWater = totalWaterGoal;
          }
          
          // Animate water level
          _animation = Tween<double>(
            begin: _animation.value,
            end: currentWater / totalWaterGoal,
          ).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
          );
          _animationController.forward(from: 0);
          
          _waterController.clear();
        });
      }
    }
  }

  // Reset water tracker
  void _resetWater() {
    setState(() {
      currentWater = 0;
      _animation = Tween<double>(
        begin: _animation.value,
        end: 0,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0);
    });
  }

  // Set daily goal
  void _setGoal() {
    showDialog(
      context: context,
      builder: (context) {
        final goalController = TextEditingController(text: totalWaterGoal.toString());
        return AlertDialog(
          title: const Text('Set Daily Goal (ml)'),
          content: TextField(
            controller: goalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Water Goal (ml)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                final goal = int.tryParse(goalController.text) ?? 2000;
                if (goal > 0) {
                  setState(() {
                    totalWaterGoal = goal;
                    // Adjust animation for new goal
                    _animation = Tween<double>(
                      begin: _animation.value,
                      end: currentWater / totalWaterGoal,
                    ).animate(
                      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
                    );
                    _animationController.forward(from: 0);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Water Reminder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _setGoal,
            tooltip: 'Set Daily Goal',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetWater, 
            tooltip: 'Reset Tracker',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Progress card with water bottle visualization
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Daily Water Progress',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      // Water bottle visualization
                      SizedBox(
                        height: 300,
                        width: 160,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Bottle outline
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue.shade700,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                shape: BoxShape.rectangle,
                              ),
                            ),
                            // Water level animation
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, _) {
                                return FractionallySizedBox(
                                  heightFactor: _animation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              }
                            ),
                            // Water droplets overlay
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _animation,
                                builder: (context, _) {
                                  return ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent, 
                                        Colors.blue.withOpacity(0.2),
                                        Colors.blue.withOpacity(0.3),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcATop,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Progress text
                            Center(
                              child: Text(
                                '${(currentWater / totalWaterGoal * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$currentWater / $totalWaterGoal ml',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form for adding water
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add Water',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _waterController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount (ml)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.water_drop),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Quick add buttons
                      Wrap(
                        spacing: 8.0,
                        children: [100, 200, 250, 500].map((amount) {
                          return ElevatedButton(
                            onPressed: () {
                              _waterController.text = amount.toString();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                            ),
                            child: Text('$amount ml'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addWater,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'ADD WATER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tips card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hydration Tips',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const ListTile(
                        leading: Icon(Icons.wb_sunny, color: Colors.orange),
                        title: Text('Drink more when exercising or in hot weather'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.watch_later, color: Colors.blue),
                        title: Text('Set regular reminders throughout the day'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.breakfast_dining, color: Colors.green),
                        title: Text('Drink a glass of water with every meal'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder set for every hour'),
              backgroundColor: Colors.blue,
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.notifications_active, color: Colors.white),
      ),
    );
  }
}
