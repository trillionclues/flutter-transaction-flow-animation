import 'package:flutter/material.dart';

class AnimatedTransactionScreen extends StatefulWidget {
  const AnimatedTransactionScreen({super.key});

  @override
  State<AnimatedTransactionScreen> createState() =>
      _AnimatedTransactionScreenState();
}

class _AnimatedTransactionScreenState extends State<AnimatedTransactionScreen>
    with TickerProviderStateMixin {
  late AnimationController _step1Controller;
  late AnimationController _step2Controller;
  late AnimationController _propagationController;
  late AnimationController _successController;
  late AnimationController _mergeController;
  late AnimationController _failureController;
  late AnimationController _pendingController;

  int currentStep = 0;
  TransactionResult _result = TransactionResult.success;

  @override
  void initState() {
    super.initState();

    _step1Controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _step2Controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _propagationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _mergeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _failureController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pendingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _startAnimation();
  }

  void _startAnimation() async {
    setState(() => currentStep = 0);
    _step1Controller.repeat();

    await Future.delayed(const Duration(milliseconds: 800));
    _step1Controller.stop();
    setState(() => currentStep = 1);
    _propagationController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => currentStep = 2);
    _step2Controller.repeat();

    await Future.delayed(const Duration(milliseconds: 2000));
    _step2Controller.stop();

    if (_result == TransactionResult.failure) {
      setState(() => currentStep = 5);
      _failureController.forward();
    } else if (_result == TransactionResult.pending) {
      setState(() => currentStep = 6);
      _pendingController.repeat();
    } else {
      setState(() => currentStep = 3);

      await Future.delayed(const Duration(milliseconds: 500));
      _mergeController.forward();

      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => currentStep = 4);
      _successController.forward();
    }
  }

  void _resetAnimation({TransactionResult? result}) {
    _step1Controller.reset();
    _step2Controller.reset();
    _propagationController.reset();
    _successController.reset();
    _mergeController.reset();
    _failureController.reset();
    _pendingController.reset();

    if (result != null) {
      _result = result;
    }

    setState(() => currentStep = 0);
    _startAnimation();
  }

  @override
  void dispose() {
    _step1Controller.dispose();
    _step2Controller.dispose();
    _propagationController.dispose();
    _successController.dispose();
    _mergeController.dispose();
    _failureController.dispose();
    _pendingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep == 4) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          'Deposit',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.close, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _mergeController,
              builder: (context, child) {
                if (currentStep >= 3 && _mergeController.value > 0) {
                  return _buildMergingIndicators();
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator(
                        stepNumber: 1,
                        isCompleted: currentStep >= 1,
                        isLoading: currentStep == 0,
                        isFailed: currentStep == 5 &&
                            _result == TransactionResult.failure,
                        controller: _step1Controller,
                      ),
                      AnimatedBuilder(
                        animation: _propagationController,
                        builder: (context, child) {
                          return Container(
                            width: 50,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: CustomPaint(
                              painter: EnhancedDottedLinePainter(
                                propagationProgress:
                                    _propagationController.value,
                                isActive: currentStep >= 1,
                                isCompleted: currentStep >= 3,
                                isFailed: currentStep == 5,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildStepIndicator(
                        stepNumber: 2,
                        isCompleted: currentStep >= 3,
                        isLoading: currentStep == 2,
                        isFailed: currentStep == 5 &&
                            _result == TransactionResult.failure,
                        isPending: currentStep == 6 &&
                            _result == TransactionResult.pending,
                        controller: _step2Controller,
                        pendingController: _pendingController,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    _getMainTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getSubtitle(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction status',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 16,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Metamask',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _resetAnimation(
                              result: TransactionResult.success),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Success'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _resetAnimation(
                              result: TransactionResult.failure),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Failure'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _resetAnimation(
                              result: TransactionResult.pending),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Pending'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _resetAnimation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Restart Current Animation'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMergingIndicators() {
    return AnimatedBuilder(
      animation: _mergeController,
      builder: (context, child) {
        double step1X =
            -46 + (46 * _mergeController.value); // Moves step1 to center
        double step2X =
            46 - (46 * _mergeController.value); // Moves step2 to center
        double opacity = 1.0 - _mergeController.value;

        return SizedBox(
          width: 200,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(step1X, 0),
                child: Opacity(
                  opacity: opacity,
                  child: _buildStepIndicator(
                    stepNumber: 1,
                    isCompleted: true,
                    isLoading: false,
                    controller: _step1Controller,
                  ),
                ),
              ),

              Transform.translate(
                offset: Offset(step2X, 0),
                child: Opacity(
                  opacity: opacity,
                  child: _buildStepIndicator(
                    stepNumber: 2,
                    isCompleted: true,
                    isLoading: false,
                    controller: _step2Controller,
                  ),
                ),
              ),

              Opacity(
                opacity: _mergeController.value,
                child: Transform.scale(
                  scale: _mergeController.value,
                  child: Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          'Deposit',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.close, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        color: const Color(0xFFE8F5E8),
        child: Column(
          children: [
            const SizedBox(height: 30),

            ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _successController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Deposit successful',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your funds were successfully deposited!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction status',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 16,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Metamask',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _resetAnimation(
                              result: TransactionResult.success),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Success'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _resetAnimation(
                              result: TransactionResult.failure),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Failure'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _resetAnimation(
                              result: TransactionResult.pending),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Pending'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _resetAnimation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Restart Current Animation'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepNumber,
    required bool isCompleted,
    required bool isLoading,
    required AnimationController controller,
    bool isFailed = false,
    bool isPending = false,
    AnimationController? pendingController,
  }) {
    Color getCircleColor() {
      if (isFailed) return Colors.red;
      if (isPending) return Colors.orange;
      if (isCompleted) return Colors.green;
      return Colors.grey[200]!;
    }

    Color getBorderColor() {
      if (isFailed) return Colors.red;
      if (isPending) return Colors.orange;
      if (isCompleted) return Colors.green;
      return Colors.grey[300]!;
    }


    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: getCircleColor(),
        border: Border.all(
          color: getBorderColor(),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isLoading && !isFailed && !isPending)
            SizedBox(
              width: 56,
              height: 56,
              child: RotationTransition(
                turns: controller,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),

          if (isPending && pendingController != null)
            SizedBox(
              width: 56,
              height: 56,
              child: AnimatedBuilder(
                animation: pendingController,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        1.0 + (0.1 * (pendingController.value * 2 - 1).abs()),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.orange,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (isCompleted && !isFailed && !isPending)
            const Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            )
          else if (isFailed)
            const Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            )
          else if (isPending)
            const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 24,
            )
          else
            Text(
              stepNumber.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  String _getMainTitle() {
    switch (currentStep) {
      case 0:
        return 'Submitting transaction...';
      case 1:
      case 2:
      case 3:
        return 'Depositing into your account...';
      case 5:
        return 'Transaction failed';
      case 6:
        return 'Transaction pending';
      default:
        return 'Deposit successful';
    }
  }

  String _getSubtitle() {
    switch (currentStep) {
      case 0:
        return 'Filling your transaction on the blockchain.';
      case 1:
      case 2:
      case 3:
        return 'It will take around one minute to finalize.';
      case 5:
        return 'There was an error processing your transaction.';
      case 6:
        return 'Your transaction is still being processed.';
      default:
        return 'Your funds were successfully deposited.';
    }
  }

  String _getStatusText() {
    switch (currentStep) {
      case 0:
      case 1:
      case 2:
        return 'Processing';
      case 3:
        return 'Success';
      case 5:
        return 'Failed';
      case 6:
        return 'Pending';
      default:
        return 'Success';
    }
  }

  Color _getStatusColor() {
    switch (currentStep) {
      case 0:
      case 1:
      case 2:
        return Colors.grey[600]!;
      case 3:
      case 4:
        return Colors.green;
      case 5:
        return Colors.red;
      case 6:
        return Colors.orange;
      default:
        return Colors.grey[600]!;
    }
  }
}

enum TransactionResult {
  success,
  failure,
  pending,
}

// Enhanced dotted line painter with propagation effect using dots
class EnhancedDottedLinePainter extends CustomPainter {
  final double propagationProgress;
  final bool isActive;
  final bool isCompleted;
  final bool isFailed;

  EnhancedDottedLinePainter({
    required this.propagationProgress,
    required this.isActive,
    required this.isCompleted,
    required this.isFailed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dotCount = 8;
    const dotRadius = 2.0;
    var spacing = size.width / (dotCount - 1);

    for (int i = 0; i < dotCount; i++) {
      final x = i * spacing;
      final dotProgress =
          ((propagationProgress * dotCount) - i).clamp(0.0, 1.0);

      // Determine dot color based on progress and state
      Color dotColor;
      double scale = 1.0;

      if (isFailed) {
        dotColor = Colors.red;
      } else if (isCompleted) {
        dotColor = Colors.green;
      } else if (isActive && dotProgress > 0) {
        // Animate from grey to green as the wave passes
        dotColor = Color.lerp(
          Colors.grey[300]!,
          Colors.green,
          dotProgress,
        )!;
        // Add a slight scale effect for the propagation wave
        scale = 1.0 + (dotProgress * 0.5);
      } else {
        dotColor = Colors.grey[300]!;
      }

      final paint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, size.height / 2),
        dotRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
