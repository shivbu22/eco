import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CommunityLeaderboardScreen extends StatelessWidget {
  const CommunityLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'OZOMIN',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1.0,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.onSurface),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24.0, left: 8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceContainerHighest,
              backgroundImage: const NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCJQaK6Flvv_ubj0yrkhm3YSkGlq33z2vLd-OiH9S7-taLLFAQ_rJer9LDJYsUZvGO6J4SDJfRvw1Uo27R6wYiYHxx1RmMD9scTynHREL-r85eP_LCHBcLlekkSL1SCCQ7yet_D6Z2V0rs7pYBmM-YdvOx9jJOejfhGk0bbWT65a-DSwyBu2I7DQh3RfduUl1HTel9l5SP3DAziYBamDbY2pHOZPjO4vCcNNUt-zv_WXD3Rtt7tJ-jvk5wBoZfr3qgXmB5yFAwPISg'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Hero Rank Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 40)
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'CURRENT STATUS',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rank #42',
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                          ),
                          Text(
                            'Top 8% of Global Contributors',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15)],
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.share, color: AppColors.onPrimary, size: 14),
                            SizedBox(width: 8),
                            Text(
                              'SHARE',
                              style: TextStyle(color: AppColors.onPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Next Milestone: Elite Guard', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      Text('850 / 1000 pts', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.85,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Global', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: const Text('Friends', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: const Text('Local', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Leaderboard List
            Column(
              children: [
                _buildLeaderboardRow(
                  rank: '1',
                  name: 'Marcus Thorne',
                  level: 'Level 28 • Legend',
                  score: '8.4t',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDlm1qcKdAc8WXLf70qCRgA1A_owrQ045c9wIzVKeLZ_s_Go6qTPmVaL1DmaSZFQ5nyVeVu3SuQIWpcGS85lQlUEu7ju8MsA7EkzpyqdAHoPz4Q4TYLOX-vsJFevJOomox2vaRMtulnz9rIK4_SA76-XARuvJTiW1GKnfkptLoorgXFkABNyXaeRCslX_8tDfkmyFTpp5X71vz5MeH3SNhDUhUiy3GY8jPThzhZCNRM5Y0Au8unTW_mTo6Or6joAKRKS4nH85tFBZc',
                  highlightColor: Colors.yellow[400]!,
                  isTop3: true,
                ),
                const SizedBox(height: 12),
                _buildLeaderboardRow(
                  rank: '2',
                  name: 'Sarah Jenkins',
                  level: 'Level 24 • Guardian',
                  score: '7.1t',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvAp7N9JZYLQoRsSdRwndGMIk8K0MJrgTcwD9hHebtqOQ5bRdn1Vl-sBFD3FA-xz82pN2wtx7tSYvSWXuPugHOakVbCwILgANL7hZXFO45LVlgoBTqAYAvTnNFw1yL4-4D5DxApgcNSIVjUUSbBBwX81BPg9tJvCZAaroYo-LuN4OHpUd92MkjKvSZqEfjlj3muCmSqyJo3iyt8TwIDnYABjUraKtDlF1D_zPtBLQH4Qe2mtLkievi4VJUcH0MDJEbaGR50WlTsxc',
                  highlightColor: Colors.blueGrey[300]!,
                  isTop3: true,
                ),
                const SizedBox(height: 12),
                _buildLeaderboardRow(
                  rank: '3',
                  name: 'Kenji Sato',
                  level: 'Level 22 • Guardian',
                  score: '6.8t',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAyx4h6BgcUmwadLIVQ3umoTBdiy9qDaY09ipiRbb_KyGEXoZfM5nkbYa27ocD6J1o9b4OxHIQVBhP5hMNi2VQ20as_Nq1UzK0ioybTjln3x7bLLjH8NeSB6W2HqFPtD-t68YIgpTQdfWsGFV4Gia491yNs_2I5HXz2yizoftXRkRq-c2LDZ4lxHRNye9B_LqWVpOCj6zv8qZfD5JlhlRi8xwzfu2IDw3YO7_84CgVUEimHvgNGL1tbnPmk20J90pOWpdIi3r7xINo',
                  highlightColor: Colors.orange[400]!,
                  isTop3: true,
                ),
                const SizedBox(height: 12),
                _buildLeaderboardRow(
                  rank: '4',
                  name: 'Anita Desai',
                  level: 'Level 19 • Advocate',
                  score: '5.2t',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCWBYJP2QXo8x53CyLYELGI8G9OzD4sq1yHiFVtxquQHVsYPlG6hnpNzvTtQpLiwrwrjPWdU05AK1ngTstC6dGrud74PaTIGaFv3NdN6dYH2igTcLS0xQkKqUwTFf-NffvLcKRTDBZCS7Ab-vsC7vCJ1DhmqjJjjEnX2Dc-DIOmsYV_WjTQA_ChNF1kxcQAE-vhWRpBAsNAdqKUdGRF4i4PMRXJ4jTL1GYhhDSLwnfDELfxK9QKTzOugkiVL8SSVBs6gr-fo2blkbY',
                  highlightColor: Colors.transparent,
                  isTop3: false,
                ),
                const SizedBox(height: 12),
                const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant, size: 20),
                const SizedBox(height: 12),
                
                // Current User Highlight
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 20)],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: const Text(
                          '42',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA6v1R1XvDv0O_LDh5SamaNvAbsWhpVjfVsfIOQqlxgdsgxn_8skVVEgAyILRtKOkxruGKsJrAu38FagyxRCUxdEacllNWxdPfH969TzTZ7D9qdLrHyw0qDgE-QW9pSi-FXzoy_7LggR9sJSU1XepWhp5pKePLR2Z34P8ty27PguRG-1X6wsqyhjEUMyzB19LvGz_2ntWCqWt3sOjBtV0ZwRs5F3egN4soiI0tSU0g3aJis9uNnxJ48CnepD1CrVQDelRIthYb-GMo'),
                            fit: BoxFit.cover,
                          )
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'You (Alex)',
                              style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Level 12 • Pioneer',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('2.4t', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                          Text('CO2 SAVED', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow({required String rank, required String name, required String level, required String score, required String imageUrl, required Color highlightColor, required bool isTop3}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop3 ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isTop3 ? Icon(Icons.workspace_premium, color: highlightColor, size: 28) : Text(
              rank,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isTop3 ? Border.all(color: highlightColor, width: 2) : Border.all(color: Colors.transparent),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  level,
                  style: TextStyle(color: isTop3 && rank == '1' ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(score, style: const TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
              const Text('CO2 SAVED', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
