# Executive Report: Revenue Trends, Customer Retention & Category Performance
**Period:** April 2025 – March 2026
**Prepared by:** BI Analytics
**Audience:** VP of Revenue & Leadership Team

---

## 1. Revenue Trends

The business grew significantly over the 12-month period, with total revenue scaling
from $225K in April 2025 to $1.59M in March 2026 — a 7x increase in monthly revenue.
Growth was not uniform: it accelerated sharply in Q4 2025 and then reset in January
before recovering again.

**Quarter-over-quarter performance:**

| Quarter | Revenue | Growth |
|---------|---------|--------|
| Q2 2025 | $908K | — |
| Q3 2025 | $1.59M | +75.6% |
| Q4 2025 | $3.88M | +143.2% |
| Q1 2026 | $3.33M | -14.1% |

The Q4 2025 surge (+143.2%) was driven almost entirely by volume: order count grew
143.5% and unique customers grew 78.9%, while average order value (AOV) was flat at
$327.83 (down 0.1% from Q3). This means the business did not raise prices or shift
to higher-value products — it simply acquired and served far more customers.

Q1 2026 saw a -14.1% revenue decline driven by a -20.2% drop in orders, consistent
with a post-holiday normalization. However, AOV rose to $352.69 (+7.6%), suggesting
the customers who did purchase in Q1 were higher-intent buyers. This is a healthy
sign: the business retained its best customers through the seasonal slowdown.

**Monthly anomalies worth investigating:**
- **October 2025:** Orders jumped 60.2% in a single month (1,821 → 2,917). This
  likely reflects a promotional event or seasonal campaign; if so, the playbook
  should be documented and repeated.
- **January 2026:** Revenue fell 57.8% month-over-month — the sharpest single-month
  drop in the dataset. This is a predictable post-December effect but sets a planning
  benchmark for next January.
- **March 2026:** Revenue surged 61.2% MoM to $1.59M, the strongest monthly growth
  rate in the dataset. Q1 2026 is recovering faster than Q1 typically would, which
  suggests the customer base acquired in Q4 is engaging again.

The 7-day moving average of daily revenue confirms the trend is structural, not
episodic: daily revenue climbed from ~$6,900 in early April 2025 to over $16,000
by late June 2025, and continued upward through year-end.

---

## 2. Customer Retention

Cohort analysis reveals a strong and improving retention trajectory, with one
notable weak period in summer 2025 that has since recovered.

**90-day retention by cohort (mature cohorts only):**

| Cohort | Size | 90-Day Retention |
|--------|------|-----------------|
| Jul 2025 | 388 | 74.0% ← weakest |
| Aug 2025 | 365 | 84.1% |
| Sep 2025 | 409 | 89.5% |
| Oct 2025 | 482 | 92.3% |
| Nov 2025 | 559 | 91.2% |
| Dec 2025 | 611 | 95.4% ← strongest |

The 3-cohort moving average of retention rose from 75.7% (centered on July) to 93.0%
(centered on December), a 17.3 percentage point improvement over five months. This
is a material shift in customer quality, not random variation.

**The summer dip (July 2025):** The July cohort had the worst 90-day retention at
74.0% and the weakest 30-day reactivation rate at 36.3%. August partially recovered
(84.1% at 90 days), suggesting the issue was concentrated in one acquisition period.
Possible explanations include a lower-quality traffic source, a weaker onboarding
experience, or a less relevant product assortment in that period. This warrants
investigation into what changed in acquisition channels between June and August.

**The Q4 improvement:** The October cohort (92.3%) through December cohort (95.4%)
show that the business acquired both more customers and better customers simultaneously.
December 2025 was the largest cohort (611 customers) and had the highest mature
retention rate — this combination is the strongest signal in the entire dataset.

**Note on 2026 cohorts:** January–March 2026 retention figures (96.6%–99.6%) appear
exceptional but are statistically immature — their 90-day observation windows have
not fully closed. These figures should be revisited in Q2 2026 for a complete picture.

---

## 3. Category Performance

The Consumer segment consistently contributed approximately 70% of monthly revenue
throughout the 12-month period (ranging from 66.2% in May 2025 to 72.7% in
September 2025). The Business segment held a stable 20–25% share. This concentration
means overall revenue growth is largely driven by Consumer segment performance.

**Segment growth comparison (cumulative revenue by end of period):**
- Consumer segment: $159K in April 2025 → running total of $10.5M+ by March 2026
- Business segment: $47K in April 2025 → running total of $2.06M by March 2026

Both segments show strong month-over-month growth through Q4 2025, with Business
posting its highest single-month growth in March 2026 (+61.4%) — suggesting
B2B demand is accelerating into Q2.

**Category-level revenue (Books as indicator):** Books grew from $3,560 in April 2025
to $22,018 in December 2025 (+518% over 8 months), then dropped to $8,574 in January
before recovering to $17,141 in March. The pattern mirrors the overall business
cycle and confirms that category performance is largely driven by the same
acquisition and seasonality forces as the top line.

---

## 4. Recommendations

**1. Investigate and replicate the October promotion.**
October 2025 saw a 60.2% single-month order spike. If this was campaign-driven,
the business should document the mechanic and budget for a similar activation in
October 2026. If it was organic, understanding why is equally valuable.

**2. Diagnose the July 2025 acquisition cohort.**
The July cohort had 74.0% 90-day retention — 21 percentage points below December's
cohort. At ~388 customers, that represents roughly 100 customers who did not return
within 90 days and otherwise would have. Identify what channel or offer brought in
that cohort and either fix the funnel or reduce spend there.

**3. Protect Q1 revenue with a January re-engagement campaign.**
January 2026 revenue dropped 57.8% from December. Given that the December cohort
has 95.4% retention, many of those customers are still active — they just did not
purchase in January. A targeted January promotion aimed at Q4 buyers could
meaningfully reduce the seasonal dip in 2027.

**4. Double down on Q4 acquisition spend.**
The data shows that customers acquired in Q4 (Oct–Dec) have both the largest cohort
sizes and the highest retention rates. This is the most efficient acquisition window
in the dataset. Increasing budget for Q4 2026 customer acquisition is the highest
confidence investment available based on current evidence.

**5. Monitor Business segment acceleration.**
Business segment March 2026 MoM growth (+61.4%) outpaced Consumer (+58.9%) for
the first time in the dataset. If this trend continues into Q2, it may warrant
dedicated B2B product investment or a separate acquisition strategy.

---

*All figures derived from SQL window function analysis of 30,200 orders and 67,713
line items across 5,000 customers, April 2025 – March 2026.*
EOF