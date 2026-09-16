import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';
import 'package:varavu_selavu/features/security/presentation/bloc/security_bloc.dart';
import 'package:varavu_selavu/features/security/presentation/pages/pin_setup_page.dart';
import 'package:varavu_selavu/features/settings/presentation/cubit/settings_cubit.dart';

class SettingsPage extends StatefulWidget {
  final String currentMonthKey;

  const SettingsPage({super.key, required this.currentMonthKey});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    _settingsCubit = sl<SettingsCubit>()..loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _settingsCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.income,
                ),
              );
            } else if (state is SettingsActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.expense,
                ),
              );
            }
          },
          builder: (context, state) {
            final isAppLock = state.isAppLockEnabled;
            final isBio = state.isBiometricsEnabled;
            final hasPin = state.hasPinSet;
            final canBio = state.canUseBiometrics;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Security Section
                _buildSectionHeader('SECURITY'),
                const SizedBox(height: 8),
                _buildCard([
                  SwitchListTile.adaptive(
                    title: const Text('App Lock (PIN)', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      hasPin ? 'PIN protection is configured' : 'Configure a 4-digit PIN',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(130)),
                    ),
                    value: isAppLock && hasPin,
                    onChanged: (val) async {
                      if (val) {
                        if (!hasPin) {
                          // Open PIN setup
                          final setup = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PinSetupPage(
                                onPinSet: (pin) {
                                  context.read<SecurityBloc>().add(SetupPinSubmitted(pin));
                                },
                              ),
                            ),
                          );
                          if (setup == true) {
                            _settingsCubit.loadSettings();
                          }
                        } else {
                          context.read<SecurityBloc>().add(const ToggleAppLockRequested(true));
                          _settingsCubit.toggleAppLock(true);
                        }
                      } else {
                        context.read<SecurityBloc>().add(const ToggleAppLockRequested(false));
                        _settingsCubit.toggleAppLock(false);
                      }
                    },
                  ),
                  if (hasPin) ...[
                    const Divider(),
                    ListTile(
                      title: const Text('Change PIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () async {
                        final setup = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PinSetupPage(
                              onPinSet: (pin) {
                                context.read<SecurityBloc>().add(SetupPinSubmitted(pin));
                              },
                            ),
                          ),
                        );
                        if (setup == true) {
                          _settingsCubit.loadSettings();
                        }
                      },
                    ),
                  ],
                  if (canBio && hasPin) ...[
                    const Divider(),
                    SwitchListTile.adaptive(
                      title: const Text('Biometric Unlock', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Unlock with Fingerprint or Face ID',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(130)),
                      ),
                      value: isBio,
                      onChanged: isAppLock
                          ? (val) {
                              context.read<SecurityBloc>().add(ToggleBiometricsRequested(val));
                              _settingsCubit.toggleBiometrics(val);
                            }
                          : null,
                    ),
                  ],
                ]),

                const SizedBox(height: 24),

                // Data & Reports Section
                _buildSectionHeader('DATA & EXPORTS'),
                const SizedBox(height: 8),
                _buildCard([
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.expense),
                    title: const Text('Export Monthly PDF Statement', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Download readable statement for ${widget.currentMonthKey}',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(130)),
                    ),
                    trailing: const Icon(Icons.share_outlined, size: 20),
                    onTap: () => _settingsCubit.exportPdfReport(widget.currentMonthKey),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.table_chart_outlined, color: AppColors.income),
                    title: const Text('Export Transactions (CSV)', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Export raw data for Excel / Google Sheets',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(130)),
                    ),
                    trailing: const Icon(Icons.share_outlined, size: 20),
                    onTap: () => _settingsCubit.exportCsv(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined, color: AppColors.balance),
                    title: const Text('Backup Data (JSON)', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Create an offline portable backup of your records',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(130)),
                    ),
                    trailing: const Icon(Icons.download_outlined, size: 20),
                    onTap: () => _settingsCubit.createBackup(),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_backup_restore_outlined, color: Colors.orange),
                    title: const Text('Restore Data from Backup', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Validate and restore from a JSON backup file',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(130)),
                    ),
                    trailing: const Icon(Icons.upload_file_outlined, size: 20),
                    onTap: () => _settingsCubit.restoreBackup(),
                  ),
                ]),

                const SizedBox(height: 24),

                // App Info Section
                _buildSectionHeader('ABOUT'),
                const SizedBox(height: 8),
                _buildCard([
                  ListTile(
                    title: const Text('Varavu Selavu', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Personal Expense & Money Tracker • v1.0.0 (Local-First)'),
                    leading: const Icon(Icons.info_outline, size: 22),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(40)),
      ),
      child: Column(children: children),
    );
  }
}
