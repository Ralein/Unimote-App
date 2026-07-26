import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/macro.dart';
import '../../domain/entities/remote_key.dart';
import '../providers/adapter_provider.dart';
import '../providers/macro_provider.dart';

class MacroBuilderScreen extends ConsumerWidget {
  const MacroBuilderScreen({super.key});

  void _showAddMacroDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create New Macro', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Macro Name',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g. Bedtime TV Off',
                hintStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g. Mute Vol → Wait 1s → Power Off',
                hintStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isNotEmpty) {
                final macro = Macro(
                  id: 'macro-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  description: desc.isNotEmpty ? desc : 'Custom sequence',
                  iconName: 'bolt',
                  steps: const [
                    MacroStep.key(RemoteKey.mute),
                    MacroStep.delay(Duration(seconds: 1)),
                    MacroStep.key(RemoteKey.power),
                  ],
                );
                ref.read(macroProvider.notifier).addMacro(macro);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save Macro'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macroState = ref.watch(macroProvider);
    final adapter = ref.watch(activeAdapterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Macro Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Macro',
            onPressed: () => _showAddMacroDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Automation Sequence Macros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chain multiple remote actions into a single automated tap sequence.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              if (macroState.isExecuting) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Running macro step ${macroState.currentStepIndex + 1}…',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(macroProvider.notifier).stopMacro();
                        },
                        child: const Text('Stop', style: TextStyle(color: AppColors.powerRed)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: macroState.macros.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final macro = macroState.macros[index];
                    final isRunningThis = macroState.executingMacroId == macro.id;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isRunningThis ? AppColors.primaryLight : AppColors.cardBorder,
                          width: isRunningThis ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.surfaceElevated,
                          child: Icon(
                            _getMacroIcon(macro.iconName),
                            color: AppColors.primaryLight,
                          ),
                        ),
                        title: Text(
                          macro.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          macro.description,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: ElevatedButton(
                          onPressed: (macroState.isExecuting || adapter == null)
                              ? null
                              : () {
                                  ref.read(macroProvider.notifier).executeMacro(macro, adapter);
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text(isRunningThis ? 'Running' : 'Run'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMacroIcon(String iconName) {
    switch (iconName) {
      case 'movie':
        return Icons.movie_rounded;
      case 'gamepad':
        return Icons.sports_esports_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }
}
