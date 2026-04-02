"""
Platform Comparison Radar Chart
Generates a 6-dimension radar chart comparing Vercel, Cloudflare Pages, and Netlify.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Dimensions and scores (from weighted decision matrix)
categories = ['Next.js\nSupport', 'Cost\nEfficiency', 'Developer\nExperience',
              'Performance', 'Security', 'Low Lock-in\nRisk']
N = len(categories)

# Scores out of 5
vercel =      [5.0, 3.0, 5.0, 4.0, 4.0, 3.0]
cloudflare =  [3.5, 5.0, 3.5, 5.0, 4.5, 3.5]
netlify =     [3.0, 3.0, 4.0, 3.5, 3.5, 4.0]

# Close the polygon
angles = np.linspace(0, 2 * np.pi, N, endpoint=False).tolist()
angles += angles[:1]
vercel += vercel[:1]
cloudflare += cloudflare[:1]
netlify += netlify[:1]

fig, ax = plt.subplots(figsize=(8, 8), subplot_kw=dict(polar=True))

# Style
ax.set_theta_offset(np.pi / 2)
ax.set_theta_direction(-1)
ax.set_rlabel_position(30)
plt.yticks([1, 2, 3, 4, 5], ['1', '2', '3', '4', '5'], color='grey', size=8)
plt.ylim(0, 5.5)

# Plot each platform
ax.plot(angles, vercel, 'o-', linewidth=2.5, label='Vercel', color='#000000')
ax.fill(angles, vercel, alpha=0.1, color='#000000')

ax.plot(angles, cloudflare, 's-', linewidth=2.5, label='Cloudflare Pages', color='#F48120')
ax.fill(angles, cloudflare, alpha=0.1, color='#F48120')

ax.plot(angles, netlify, '^-', linewidth=2.5, label='Netlify', color='#00AD9F')
ax.fill(angles, netlify, alpha=0.1, color='#00AD9F')

# Category labels
ax.set_xticks(angles[:-1])
ax.set_xticklabels(categories, size=11, fontweight='bold')

# Title and legend
plt.title('Deployment Platform Comparison\n(Score 1-5, higher is better)', size=14, fontweight='bold', pad=30)
ax.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1), fontsize=11)

plt.tight_layout()
plt.savefig('/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/research/todo-deploy/platform-comparison.png', dpi=150, bbox_inches='tight')
print('Radar chart saved to platform-comparison.png')
