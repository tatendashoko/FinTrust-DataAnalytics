# FinTrust Digital Bank — Data Analytics Track

**Intern:** Tatenda Shoko
**Program:** AnalystLab Africa Experience Lab
**Project:** FinTrust Financial Intelligence & Digital Banking Support Solution
**Track:** Data Analytics


---

## Project Overview

This repository documents a 4-week data analytics engagement for FinTrust Digital Bank, covering data quality assessment, SQL analysis, exploratory data analysis, dashboard development, and business insight generation across two core datasets: **Customer_Data** (1,500 records) and **Transaction_Data** (12,000 records), linked via `Customer_ID`.

## Repository Structure

```
├── Week1/                          Week 1 submission — architecture, KPI planning,
│                                    analytical questions, project structure
│
├── Week2/                          Week 2 submission — Analyse & Prepare
│   ├── 01_Data_Quality/            Data quality findings (PDF) + cleaning log (Excel)
│   ├── 02_SQL_Analysis/            8 business questions answered in PostgreSQL
│   ├── 03_Python_EDA/              Executed Jupyter notebook, 8 visualizations
│   ├── 04_PowerBI_Dashboard/       Interactive dashboard, source data, custom theme
│   ├── 05_Business_Findings/       6 findings (Finding → Evidence → Business Meaning)
│   ├── 06_Documentation/           Full decision log, testing evidence, limitations
│   └── FinTrust_Week2_Project_Summary.docx   Concise cross-week summary
│
└── data/
    ├── raw/                        Original, unmodified source files
    └── processed/                  Cleaned datasets used in all Week 2 analysis
```

## Week 2 Deliverables

| # | Deliverable | Format | Location |
|---|---|---|---|
| 1 | Data Quality Documentation | PDF (+ editable .docx) | `Week2/01_Data_Quality/` |
| 2 | Data Cleaning Log | Excel | `Week2/01_Data_Quality/` |
| 3 | SQL Business Analysis | .sql | `Week2/02_SQL_Analysis/` |
| 4 | Python EDA Notebook | .ipynb | `Week2/03_Python_EDA/` |
| 5 | Power BI Dashboard | .pbix | `Week2/04_PowerBI_Dashboard/` |
| 6 | Business Findings | .docx | `Week2/05_Business_Findings/` |
| 7 | Week 2 Documentation | .docx | `Week2/06_Documentation/` |
| 8 | Week 2 Project Summary | .docx | `Week2/` |

## Tools Used

Microsoft Excel · PostgreSQL · Python (Pandas, NumPy, Matplotlib, Seaborn) · Jupyter Notebook · Power BI

## Key Findings (Week 2)

- **International transactions carry ~2x the risk-flag rate** of domestic transactions (36.9% vs 18.9%), and the gap holds — often widens — within every individual channel.
- **Customer segment does not reliably identify individual high-value customers** — several of FinTrust's top 10 customers by spend sit in the "Everyday" segment, not "Premium."
- **~1 in 10 transactions doesn't complete cleanly**, representing NGN49.7M tied up in Failed, Reversed, or Pending status.
- **Higher-value transactions are flagged more**, but only in the top value quartile (25.3% vs ~17-18% for the rest) — a real but concentrated effect.

Full detail: `Week2/05_Business_Findings/` and `Week2/06_Documentation/`.

## Verification & Testing

Every technical deliverable was independently verified, not just written:
- SQL analysis executed end-to-end against a freshly created **PostgreSQL 16** database with `PRIMARY KEY`/`FOREIGN KEY` constraints enforced — zero errors.
- Python notebook executed top-to-bottom with a live kernel — zero errors, all 8 charts rendered.
- Power BI KPI cards cross-checked against the SQL and Python outputs — all values matched exactly.

## Status

Week 2 deliverables complete. Power BI dashboard in final polish stage (theming, layout, sizing).

## Roadmap

| Week | Focus |
|---|---|
| 1 | Architecture, KPI planning, analytical questions |
| 2 | Data quality, SQL analysis, EDA, dashboard build, business findings *(this submission)* |
| 3 | Complete dashboard, deepen analysis, validate findings, prepare outputs for integration |
| 4 | Cross-track integration and validation |
