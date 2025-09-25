import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const FruitSlotMachineApp());
}

class FruitSlotMachineApp extends StatelessWidget {
  const FruitSlotMachineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Slot Machine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SlotMachineHomePage(),
    );
  }
}

class SlotMachineHomePage extends StatefulWidget {
  const SlotMachineHomePage({super.key});

  @override
  State<SlotMachineHomePage> createState() => _SlotMachineHomePageState();
}

class _SlotMachineHomePageState extends State<SlotMachineHomePage>
    with TickerProviderStateMixin {
  // Fruit icons list
  final List<String> fruits = [
    'assets/icons/cherry.svg',
    'assets/icons/lemon.svg',
    'assets/icons/orange.svg',
    'assets/icons/watermelon.svg',
    'assets/icons/grapes.svg',
    'assets/icons/banana.svg',
    'assets/icons/strawberry.svg',
  ];

  // Game state
  List<String> reel1 = [];
  List<String> reel2 = [];
  List<String> reel3 = [];
  bool isSpinning = false;
  int score = 1000;
  int bet = 10;

  // Track final positions for stopped reels
  double? finalPosition1;
  double? finalPosition2;
  double? finalPosition3;

  // Screen shake effect
  double _shakeOffset = 0.0;

  // Animation controllers
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  // Add state for win flash
  bool _isWinning = false;
  Timer? _winTimer;

  @override
  void initState() {
    super.initState();
    _initializeReels();
    _setupAnimations();
  }

  void _initializeReels() {
    // Initialize reels with random fruits
    reel1 = List.generate(20, (index) => fruits[Random().nextInt(fruits.length)]);
    reel2 = List.generate(20, (index) => fruits[Random().nextInt(fruits.length)]);
    reel3 = List.generate(20, (index) => fruits[Random().nextInt(fruits.length)]);
  }

  void _setupAnimations() {
    // Ultra-realistic slot machine animation system
    // Each reel has unique characteristics for authentic feel

    // Reel 1 - High-speed with momentum
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 80), // Very fast for initial burst
      vsync: this,
    );

    _animation1 = Tween<double>(begin: 0, end: 80.0).animate(
      CurvedAnimation(
        parent: _controller1,
        curve: Curves.easeInOutQuart, // Smooth quartic easing for natural motion
      ),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    // Reel 2 - Medium speed with slight variation
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 95), // Slightly slower
      vsync: this,
    );

    _animation2 = Tween<double>(begin: 0, end: 80.0).animate(
      CurvedAnimation(
        parent: _controller2,
        curve: Curves.easeInOutCubic, // Cubic easing for smooth transitions
      ),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    // Reel 3 - Variable speed for realistic feel
    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 110), // More variation
      vsync: this,
    );

    _animation3 = Tween<double>(begin: 0, end: 80.0).animate(
      CurvedAnimation(
        parent: _controller3,
        curve: Curves.easeInOutQuint, // Quintic easing for premium feel
      ),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  void _spin() {
    if (isSpinning || score < bet) return;

    setState(() {
      isSpinning = true;
      score -= bet;
      // Reset final positions for new spin
      finalPosition1 = null;
      finalPosition2 = null;
      finalPosition3 = null;
    });

    // Generate new random fruits for reels
    reel1 = List.generate(20, (index) => fruits[Random().nextInt(fruits.length)]);
    reel2 = List.generate(20, (index) => fruits[Random().nextInt(fruits.length)]);
    reel3 = List.generate(20, (index) => fruits[Random().nextInt(fruits.length)]);

    // Generate target indices for each reel
    final int targetIndex1 = Random().nextInt(reel1.length);
    final int targetIndex2 = Random().nextInt(reel2.length);
    final int targetIndex3 = Random().nextInt(reel3.length);

    // Generate random spin cycles with more realistic variation
    final int spinCycles1 = 18 + Random().nextInt(10); // 18-27 spin cycles (more realistic)
    final int spinCycles2 = 22 + Random().nextInt(10); // 22-31 spin cycles
    final int spinCycles3 = 26 + Random().nextInt(10); // 26-35 spin cycles (longest spin)

    // Start all reels spinning with ultra-fast initial burst
    Future.delayed(const Duration(milliseconds: 0), () {
      _controller1.repeat(); // Start continuous spinning
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      _controller2.repeat(); // Slightly staggered start
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _controller3.repeat(); // Last to start for cascading effect
    });

    // Calculate realistic deceleration timing (each cycle takes longer as it slows)
    final int stopTime1 = 1500 + (spinCycles1 * 80);  // Faster initial spin
    final int stopTime2 = 1700 + (spinCycles2 * 95);  // Medium timing
    final int stopTime3 = 1900 + (spinCycles3 * 110); // Slowest/last to stop

    // Reel 1 stops first with momentum and screen shake
    Future.delayed(Duration(milliseconds: stopTime1), () {
      _controller1.stop();
      finalPosition1 = (targetIndex1 % reel1.length) * 80.0;
      _shakeScreen(); // Add screen shake effect
      setState(() {}); // Force rebuild to show final position
      // Add slight pause for dramatic effect
      Future.delayed(const Duration(milliseconds: 200), () => _checkWin());
    });

    // Reel 2 stops second with building anticipation and shake
    Future.delayed(Duration(milliseconds: stopTime2), () {
      _controller2.stop();
      finalPosition2 = (targetIndex2 % reel2.length) * 80.0;
      _shakeScreen(); // Screen shake for second reel stop
      setState(() {}); // Force rebuild to show final position
      if (!isSpinning) {
        Future.delayed(const Duration(milliseconds: 300), () => _checkWin());
      }
    });

    // Reel 3 stops last with maximum tension and biggest shake
    Future.delayed(Duration(milliseconds: stopTime3), () {
      _controller3.stop();
      finalPosition3 = (targetIndex3 % reel3.length) * 80.0;
      _shakeScreen(); // Biggest screen shake for final reel
      setState(() {
        isSpinning = false;
      }); // Force rebuild to show final position
      // Longer pause for final reveal
      Future.delayed(const Duration(milliseconds: 400), () => _checkWin());
    });
  }

  void _checkWin() {
    if (isSpinning) return;

    // Get the visible fruits by calculating which fruits are in the center positions
    final double itemHeight = 80.0;

    // Use final positions for stopped reels, animation values for spinning reels
    final double pos1 = finalPosition1 ?? (_controller1.isAnimating ? _animation1.value : 0.0);
    final double pos2 = finalPosition2 ?? (_controller2.isAnimating ? _animation2.value : 0.0);
    final double pos3 = finalPosition3 ?? (_controller3.isAnimating ? _animation3.value : 0.0);

    // Calculate which fruit is in the center position
    final int visibleIndex1 = ((pos1 / itemHeight).round() % reel1.length);
    final int visibleIndex2 = ((pos2 / itemHeight).round() % reel2.length);
    final int visibleIndex3 = ((pos3 / itemHeight).round() % reel3.length);

    final String fruit1 = reel1[visibleIndex1];
    final String fruit2 = reel2[visibleIndex2];
    final String fruit3 = reel3[visibleIndex3];

    // Check for winning combinations
    int winAmount = 0;

    if (fruit1 == fruit2 && fruit2 == fruit3) {
      // Three of a kind
      switch (fruit1) {
        case 'assets/icons/cherry.svg':
          winAmount = bet * 20;
          break;
        case 'assets/icons/lemon.svg':
          winAmount = bet * 15;
          break;
        case 'assets/icons/orange.svg':
          winAmount = bet * 12;
          break;
        case 'assets/icons/watermelon.svg':
          winAmount = bet * 25;
          break;
        case 'assets/icons/grapes.svg':
          winAmount = bet * 18;
          break;
        case 'assets/icons/banana.svg':
          winAmount = bet * 10;
          break;
        case 'assets/icons/strawberry.svg':
          winAmount = bet * 30;
          break;
      }
    } else if (fruit1 == fruit2 || fruit2 == fruit3 || fruit1 == fruit3) {
      // Two of a kind
      winAmount = bet * 2;
    }

    if (winAmount > 0) {
      setState(() {
        score += winAmount;
        _isWinning = true;
      });

      // Start flashing effect
      _startWinFlash();

      // Show win dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🎉 Congratulations! 🎉'),
            content: Text('You won $winAmount coins!'),
            actions: [
              TextButton(
                child: const Text('Awesome!'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ).then((_) {
        if (mounted) {
          setState(() {
            _isWinning = false;
          });
        }
      });

      // Animate score update
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            score += winAmount * 2; // Double for excitement, adjust payout
          });
        }
      });
    }
  }

  bool _isReelSpinning(int reelIndex) {
    // If we have a final position, the reel is stopped
    switch (reelIndex) {
      case 0:
        if (finalPosition1 != null) return false;
        return _controller1.isAnimating;
      case 1:
        if (finalPosition2 != null) return false;
        return _controller2.isAnimating;
      case 2:
        if (finalPosition3 != null) return false;
        return _controller3.isAnimating;
      default:
        return false;
    }
  }

  void _shakeScreen() {
    setState(() {
      _shakeOffset = 5.0;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _shakeOffset = -3.0;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _shakeOffset = 0.0;
        });
      }
    });
  }

  void _changeBet() {
    setState(() {
      if (bet == 5) {
        bet = 10;
      } else if (bet == 10) {
        bet = 25;
      } else if (bet == 25) {
        bet = 50;
      } else {
        bet = 5;
      }
    });
  }

  void _startWinFlash() {
    _winTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          _isWinning = !_isWinning;
        });
      } else {
        timer.cancel();
      }
    });

    // Stop after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isWinning = false;
        });
        _winTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _winTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isWinning ? [
              const Color(0xFFFFD700), // Gold
              const Color(0xFFFF4500), // Orange Red
              const Color(0xFF00FF00), // Lime for win
              const Color(0xFFFFD700),
            ] : isSpinning ? [
              const Color(0xFFFF4500), // Orange Red
              const Color(0xFFFF6347), // Tomato
              const Color(0xFFFFD700), // Gold
              const Color(0xFFFFA500), // Orange
            ] : [
              const Color(0xFFFF6B35),
              const Color(0xFFF7931E),
              const Color(0xFFFFD23F),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background particles
              if (isSpinning)
                ...List.generate(20, (index) {
                  return Positioned(
                    left: Random().nextDouble() * MediaQuery.of(context).size.width,
                    top: Random().nextDouble() * MediaQuery.of(context).size.height,
                    child: AnimatedOpacity(
                      opacity: Random().nextDouble() * 0.6 + 0.2,
                      duration: Duration(milliseconds: 500 + Random().nextInt(1000)),
                      child: Container(
                        width: 4 + Random().nextDouble() * 8,
                        height: 4 + Random().nextDouble() * 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50), // Adjust padding for better placement above the machine
                    child: Image.asset(
                      'assets/images/fortuna_logo.png',
                      width: 200,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  // Enhanced Header with glow effect
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSpinning ? Colors.orange.withOpacity(0.5) : Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      boxShadow: isSpinning ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: isSpinning ? [
                                  BoxShadow(
                                    color: Colors.yellow.withOpacity(0.8),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ] : null,
                              ),
                              child: const Icon(
                                Icons.monetization_on,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: isSpinning ? [
                                  Shadow(
                                    color: Colors.yellow.withOpacity(0.8),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                              child: Text('$score'),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _changeBet,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSpinning ? Colors.orange.withOpacity(0.7) : Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: isSpinning ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                            child: Text(
                              'Bet: $bet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: isSpinning ? [
                                  Shadow(
                                    color: Colors.orange.withOpacity(0.8),
                                    blurRadius: 5,
                                  ),
                                ] : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Slot Machine with premium styling
                  Expanded(
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(_shakeOffset, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 370,
                          height: 470,
                          decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSpinning ? [
                              const Color(0xFF8B4513),
                              const Color(0xFFA0522D),
                              const Color(0xFF654321),
                              const Color(0xFF8B4513),
                            ] : [
                              const Color(0xFF8B4513),
                              const Color(0xFF654321),
                              const Color(0xFF8B4513),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSpinning ? Colors.orange.withOpacity(0.8) : Colors.brown[800]!,
                            width: 10,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 25,
                              offset: const Offset(0, 20),
                            ),
                            if (isSpinning) ...[
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.2),
                                blurRadius: 60,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            if (_isWinning) ...[
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.6),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ],
                        ),
                        child: Column(
                          children: [
                            // Premium Title with glow
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.black.withOpacity(0.9),
                                  ],
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSpinning ? Colors.orange.withOpacity(0.6) : Colors.white.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                '🎰 MLEŠMAT 🎰',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                  shadows: isSpinning ? [
                                    Shadow(
                                      color: Colors.orange.withOpacity(0.8),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ] : [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Reels with enhanced spacing
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildReel(reel1, _animation1, 0),
                                    _buildReel(reel2, _animation2, 1),
                                    _buildReel(reel3, _animation3, 2),
                                  ],
                                ),
                              ),
                            ),

                            // Replace the spin button section (around lines 619-678) with lever
                            Container(
                              padding: const EdgeInsets.all(24),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                transform: isSpinning
                                  ? Matrix4.translationValues(0, 5, 0)
                                  : Matrix4.identity(),
                                child: Container(
                                  decoration: isSpinning ? BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.6),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: Colors.yellow.withOpacity(0.4),
                                        blurRadius: 50,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ) : null,
                                  child: ElevatedButton(
                                    onPressed: isSpinning ? null : _spin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSpinning
                                        ? Colors.grey[700]
                                        : const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 50,
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: isSpinning ? 15 : 20,
                                      shadowColor: isSpinning
                                        ? Colors.orange.withOpacity(0.8)
                                        : Colors.green.withOpacity(0.6),
                                    ),
                                    child: Text(
                                      isSpinning ? '🎰 SPINNING...' : '🎰 SPIN',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3,
                                        shadows: isSpinning ? [
                                          Shadow(
                                            color: Colors.orange.withOpacity(0.8),
                                            blurRadius: 5,
                                          ),
                                        ] : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  ),

                  // Enhanced Footer with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: isSpinning ? Colors.orange.withOpacity(0.5) : Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      isSpinning
                        ? '🎰 Spinning... Good Luck! 🎰'
                        : 'Match 3 fruits to win! 🍒🍋🍊🥝🥥',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        shadows: isSpinning ? [
                          Shadow(
                            color: Colors.orange.withOpacity(0.6),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ] : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReel(List<String> reel, Animation<double> animation, int reelIndex) {
    // Get the current final position for this reel if it exists
    double? finalPosition;
    switch (reelIndex) {
      case 0:
        finalPosition = finalPosition1;
        break;
      case 1:
        finalPosition = finalPosition2;
        break;
      case 2:
        finalPosition = finalPosition3;
        break;
    }

    final bool isSpinning = _isReelSpinning(reelIndex);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        height: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1a1a1a),
              Colors.black,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSpinning ? Colors.orange.withOpacity(0.6) : Colors.white.withOpacity(0.8),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSpinning ? Colors.orange : Colors.white).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Background pattern for depth
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[900]!.withOpacity(0.3),
                      Colors.grey[800]!.withOpacity(0.1),
                      Colors.grey[900]!.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              // Animated rolling fruits with enhanced visuals
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Stack(
                    children: List.generate(30, (index) {
                      final double itemHeight = 80.0;
                      final double currentAnimationValue = finalPosition ?? animation.value;
                      final double position = -currentAnimationValue + (index * itemHeight);

                      final double distanceFromCenter = (position + 40 - 120).abs();
                      final double blurOpacity = (1.0 - (distanceFromCenter / 80)).clamp(0.0, 1.0);

                      // Calculate dynamic effects based on reel state
                      final double speedMultiplier = isSpinning ? (reelIndex == 0 ? 1.2 : reelIndex == 1 ? 1.0 : 0.8) : 1.0;
                      final double rotationX = isSpinning ? sin(animation.value * 0.05 * speedMultiplier) * 0.04 : 0.0;
                      final double rotationY = isSpinning ? cos(animation.value * 0.03 * speedMultiplier) * 0.02 : 0.0;
                      final double wobble = isSpinning ? sin(animation.value * 0.1 * speedMultiplier) * 2.0 : 0.0;

                      return Positioned(
                        left: wobble,
                        right: -wobble,
                        top: position,
                        height: itemHeight,
                        child: Container(
                          alignment: Alignment.center,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.004)
                              ..rotateX(rotationX)
                              ..rotateY(rotationY)
                              ..rotateZ(isSpinning ? sin(animation.value * 0.02 * speedMultiplier) * 0.01 : 0.0),
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: isSpinning ? blurOpacity * 0.9 : 1.0,
                              child: Container(
                                width: 74,
                                height: 74,
                                alignment: Alignment.center,
                                decoration: isSpinning ? BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.9 * blurOpacity),
                                      blurRadius: 35 * blurOpacity,
                                      spreadRadius: 10 * blurOpacity,
                                    ),
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.7 * blurOpacity),
                                      blurRadius: 45 * blurOpacity,
                                      spreadRadius: 18 * blurOpacity,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5 * blurOpacity),
                                      blurRadius: 25 * blurOpacity,
                                      spreadRadius: 4 * blurOpacity,
                                    ),
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3 * blurOpacity),
                                      blurRadius: 55 * blurOpacity,
                                      spreadRadius: 20 * blurOpacity,
                                    ),
                                  ],
                                  gradient: RadialGradient(
                                    center: Alignment.center,
                                    radius: 1.5,
                                    colors: [
                                      Colors.white.withOpacity(0.6 * blurOpacity),
                                      Colors.orange.withOpacity(0.5 * blurOpacity),
                                      Colors.yellow.withOpacity(0.4 * blurOpacity),
                                      Colors.red.withOpacity(0.2 * blurOpacity),
                                      Colors.transparent,
                                    ],
                                  ),
                                ) : null,
                                child: Center(
                                  child: Transform.scale(
                                    scale: isSpinning ? 0.75 + (blurOpacity * 0.25) : 1.0,
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 66,
                                      height: 66,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSpinning ? Colors.black.withOpacity(0.2) : null,
                                        border: isSpinning ? Border.all(
                                          color: Colors.white.withOpacity(0.3 * blurOpacity),
                                          width: 1,
                                        ) : null,
                                      ),
                                      child: SvgPicture.asset(
                                        reel[index % reel.length],
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              // Enhanced reel mask with chrome effect
              Container(
                margin: const EdgeInsets.only(top: 80, bottom: 80),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.95),
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isSpinning ? Colors.orange.withOpacity(0.8) : Colors.white,
                      width: 4,
                    ),
                    bottom: BorderSide(
                      color: isSpinning ? Colors.orange.withOpacity(0.8) : Colors.white,
                      width: 4,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: (isSpinning ? Colors.orange : Colors.white).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              // Winning highlight effect
              if (!isSpinning && finalPosition != null)
                Container(
                  margin: const EdgeInsets.only(top: 80, bottom: 80),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.yellow.withOpacity(0.6),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

              // Payline indicator
              Positioned(
                top: 120, // Center of 240 height
                left: 0,
                right: 0,
                height: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _isWinning ? Colors.yellow : Colors.white.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        _isWinning ? Colors.yellow : Colors.white.withOpacity(0.5),
                      ],
                    ),
                    boxShadow: _isWinning ? [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.8),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
