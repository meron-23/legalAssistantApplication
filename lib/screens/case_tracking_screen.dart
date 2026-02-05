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
  final dbService = DatabaseService();
  String? _selectedLevel;
  String? _selectedBench;
  final _searchController = TextEditingController();
  List<Case> _results = [];
  bool _isLoadingBenches = false;
  bool _isSearching = false;
  List<Bench> _benches = [];

  final List<String> _courtLevels = [
    'Federal Supreme Court',
    'Federal High Court',
    'First Instance Court',
  ];

  void _onLevelChanged(String? level) async {
    setState(() {
      _selectedLevel = level;
      _selectedBench = null;
      _benches = [];
      _isLoadingBenches = true;
    });

    if (level != null) {
      final benches = await dbService.getBenches(level);
      setState(() {
        _benches = benches;
        _isLoadingBenches = false;
      });
    }
  }

  void _performSearch() async {
    if (_selectedLevel == null || _selectedBench == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select court level and bench')),
      );
      return;
    }

    setState(() => _isSearching = true);
    final results = await dbService.searchCases(
      courtLevel: _selectedLevel!,
      bench: _selectedBench!,
      searchTerm: _searchController.text,
    );
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchHeader(),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
              ? _buildEmptyState()
              : _buildResultsList(),
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedLevel,
            decoration: const InputDecoration(
              labelText: 'Court Level',
              prefixIcon: Icon(Icons.account_balance),
            ),
            items: _courtLevels.map((level) {
              return DropdownMenuItem(value: level, child: Text(level));
            }).toList(),
            onChanged: _onLevelChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedBench,
            decoration: InputDecoration(
              labelText: 'Select Bench',
              prefixIcon: const Icon(Icons.gavel),
              enabled: !_isLoadingBenches && _selectedLevel != null,
              suffixIcon: _isLoadingBenches
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            items: _benches.map((b) {
              return DropdownMenuItem(
                value: b.benchName,
                child: Text(b.benchName),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedBench = val),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Case ID / Parties (Optional)',
              prefixIcon: Icon(Icons.search),
              hintText: 'e.g. FSC/1023/24 or Abebe',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Search Records',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.blueGrey[100]),
          const SizedBox(height: 16),
          Text(
            'No matching cases found',
            style: TextStyle(color: Colors.blueGrey[300], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(color: Colors.blueGrey[200], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final c = _results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueGrey[50]!),
          ),
          child: InkWell(
            onTap: () => _showCaseDetails(c),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          c.caseNumber,
                          style: const TextStyle(
                            color: Color(0xFF0D47A1),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _buildStatusBadge(c.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${c.plaintiffName} vs ${c.defendantName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.blueGrey[400],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hearing: ${DateFormat('MMM dd, yyyy').format(c.nextHearingDate)}',
                        style: TextStyle(
                          color: Colors.blueGrey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.blueGrey[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.blueGrey[300],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.blue;
    if (status.toLowerCase().contains('review') ||
        status.toLowerCase().contains('pending')) {
      color = Colors.orange;
    } else if (status.toLowerCase().contains('ongoing')) {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showCaseDetails(Case c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Case Record Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailItem(Icons.numbers, 'Case Number', c.caseNumber),
              _buildDetailItem(Icons.person, 'Plaintiff', c.plaintiffName),
              _buildDetailItem(
                Icons.person_outline,
                'Defendant',
                c.defendantName,
              ),
              _buildDetailItem(Icons.account_balance, 'Court', c.courtLevel),
              _buildDetailItem(Icons.gavel, 'Bench', c.bench),
              _buildDetailItem(Icons.info_outline, 'Status', c.status),
              _buildDetailItem(
                Icons.event,
                'Next Hearing',
                DateFormat('EEEE, MMM dd, yyyy').format(c.nextHearingDate),
              ),
              if (c.caseDetails != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(c.caseDetails!, style: const TextStyle(height: 1.5)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.blueGrey[300], fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
