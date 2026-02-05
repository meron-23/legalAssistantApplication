import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/case.dart';
import '../models/bench.dart';
import '../services/database_service.dart';

class CaseTrackingScreen extends StatefulWidget {
  const CaseTrackingScreen({super.key});

  @override
  State<CaseTrackingScreen> createState() => _CaseTrackingScreenState();
}

class _CaseTrackingScreenState extends State<CaseTrackingScreen> {
  final _dbService = DatabaseService();
  final _searchController = TextEditingController();

  String? _selectedCourtLevel;
  String? _selectedBench;
  List<Bench> _benches = [];
  List<Case> _searchResults = [];
  bool _isLoading = false;

  final List<String> _courtLevels = [
    'Federal Supreme Court',
    'Federal High Court',
    'First Instance Court',
  ];

  void _onCourtLevelChanged(String? value) async {
    setState(() {
      _selectedCourtLevel = value;
      _selectedBench = null;
      _benches = [];
    });

    if (value != null) {
      final benches = await _dbService.getBenches(value);
      setState(() {
        _benches = benches;
      });
    }
  }

  void _performSearch() async {
    if (_selectedCourtLevel == null || _selectedBench == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Court Level and Bench')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _dbService.searchCases(
        courtLevel: _selectedCourtLevel!,
        bench: _selectedBench!,
        searchTerm: _searchController.text,
      );
      setState(() => _searchResults = results);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          _buildSearchField(),
          const SizedBox(height: 24),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Court Level',
            border: OutlineInputBorder(),
          ),
          value: _selectedCourtLevel,
          items: _courtLevels.map((level) {
            return DropdownMenuItem(value: level, child: Text(level));
          }).toList(),
          onChanged: _onCourtLevelChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Bench',
            border: OutlineInputBorder(),
          ),
          value: _selectedBench,
          disabledHint: const Text('Select Court Level first'),
          items: _benches.map((bench) {
            return DropdownMenuItem(
              value: bench.benchName,
              child: Text(bench.benchName),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedBench = val),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Case #, Plaintiff, or Defendant',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _performSearch,
          icon: const Icon(Icons.search),
          style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('No cases found matching your criteria.'),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final caseItem = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              'Case #${caseItem.caseNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${caseItem.plaintiffName} vs ${caseItem.defendantName}'),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status: ${caseItem.status}'),
                    Text(
                      'Next: ${DateFormat('MMM dd').format(caseItem.nextHearingDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => _showCaseDetails(caseItem),
          ),
        );
      },
    );
  }

  void _showCaseDetails(Case caseItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                'Case Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(height: 32),
              _detailRow('Case Number', caseItem.caseNumber),
              _detailRow(
                'Parties',
                '${caseItem.plaintiffName} vs ${caseItem.defendantName}',
              ),
              _detailRow('Court', caseItem.courtLevel),
              _detailRow('Bench', caseItem.bench),
              _detailRow('Status', caseItem.status),
              _detailRow(
                'Next Hearing',
                DateFormat('yMMMd').format(caseItem.nextHearingDate),
              ),
              if (caseItem.caseDetails != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(caseItem.caseDetails!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
