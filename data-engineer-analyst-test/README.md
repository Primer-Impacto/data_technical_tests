# Data Engineer & Analyst — Technical test

Thanks for taking the time to do this. This is not a coding test. We want to see how you
**think**: how you investigate messy data, how you decide what matters, how you design something
that runs without you, and how you explain it to people who are not technical.

- **Time:** about **2 hours**. Please stop at 2.5 hours at the latest, and tell us how long you
  spent. You will probably not finish everything, and that is fine: deciding what to do first is
  part of what we look at. A partial solution with clear notes beats a polished one that took a
  weekend. If time runs short, do **1A and 2A first**; for the other parts, a few bullets are
  enough. We do not expect you to find every problem in the data.
- **Tools:** use whatever you would use at work: Python, SQL (DuckDB is great for this), a
  notebook, a spreadsheet, Apps Script... Explain your choice.
- **AI assistants:** allowed and expected. Two conditions: you must be able to explain every line
  and every number you submit (we will ask), and you add a short note on how you used AI (see the
  template).
- **Questions:** nobody will be available over the weekend. If something is ambiguous, make a
  reasonable assumption, write it down and move on. That is part of the job, and of the test.
- **Data:** everything in this package is synthetic. The brand, retailers, stores and people are
  fictional.

---

## 1. Context

We are the data team of a field marketing agency. In Spain we run an in-store programme for
**Orbit**, a global consumer-electronics brand, with two product lines:

- **WEAR**: smartwatches and earbuds.
- **XR**: mixed-reality headsets.

A team of 10 field reps visits 36 stores of 3 retailers (**MegaElectro**, **Galerías Prado** and
**Cultura+**). On each visit they check the product display, run demos, and train the retailer's
sales staff (we call them **RSAs**, retail sales associates). They log every visit in a field app,
and they also send short voice or text notes about what they see in store.

The client is demanding and lives in Google Workspace. They own a set of Google Sheets where we
must report our KPIs, and they are strict about their rules: for example, **their weeks run from
Sunday to Saturday**. Today all of these sheets are filled in **by hand**: the raw-data tabs every
day, and the KPI tab every Monday morning.

Internally we run a modern data platform (Snowflake, dbt, Airflow). **You do not need any of them,
or any cloud account, for this test.** A laptop is enough.

## 2. Monday morning

It is **Monday 16 November 2026, 9:00**. The data exports were taken at 07:00. You find this
message from Laura, the project manager:

> Hi! Welcome to the project 🙂
>
> Monday again, which means 3 hours copying numbers into the client's **WEEKLY KPI** tab before
> 12:00. Plus every day someone pastes the visits export into their RAW DATA tabs. It's killing us.
>
> Two more things:
>
> 1. The client's Iberia retail lead says our numbers are wrong. For **week 45** they count **44**
>    WEAR visits at Galerías Prado and we reported **56**. They "don't trust our numbers" anymore.
>    I filtered the app export by the `app_week` column as always, so I really don't know what
>    happened.
> 2. She also asked this morning: *"Our dashboard shows XR sell-out at MegaElectro down about 50%
>    this week. What happened, and what are you doing about it?"* She wants an answer today.
>
> Oh, and the field team sends ~300 voice notes a week. We summarise them with an AI tool for the
> client's weekly "store sentiment" report, but honestly I'm not sure anyone trusts it.
>
> Can you help? 🙏

## 3. The data

| File | What it is |
|---|---|
| `data/field_visits.csv` | Export from the field app (taken Mon 16 Nov 07:00). One row per visit record. |
| `data/retailer_sellout.csv` | Weekly units sold per store and SKU, as reported by each retailer and consolidated by our ingestion. |
| `data/store_master.csv` | Our list of stores, with each retailer's own store code. |
| `data/product_master.csv` | SKUs and their product line. |
| `data/weekly_goals.csv` | Weekly goals agreed with the client, by retailer, product line and KPI. |
| `data/field_notes.csv` | Field notes from the last 3 weeks. Voice notes are transcribed automatically. |
| `client_sheet/README.md` | The client's rules for the WEEKLY KPI tab. **Read this first.** |
| `client_sheet/weekly_kpi_template.csv` | The block of rows you must fill for week 46. |
| `client_sheet/weekly_kpi_2026-W45_as_submitted.csv` | What Laura filled in by hand last week (she added the Cultura+ sell-out on Wednesday, when their file arrived). |

Column notes:

- `field_visits.csv`: `checkin_at` / `checkout_at` are local time. `product_focus` is `WEAR`, `XR`
  or `WEAR & XR`. `demo_units_working` says whether the XR demo units worked during the visit (blank
  when not applicable). `app_week` is the week label computed by the field app. `synced_at` is when
  the record reached our servers (reps are sometimes offline).
- `retailer_sellout.csv`: `week_ending` is the Saturday that closes the week. Returns are reported
  separately in `units_returned`. `source_file` and `loaded_at` tell you which retailer file each
  row came from and when we loaded it.
- `field_notes.csv`: `store_code` is attached by the app when the rep picks a store. It can be
  empty.

---

## 4. Your tasks

Suggested time in brackets. It is a guide, not a rule.

### Part 1: Automate the Monday sheet (≈ 60 min)

**1A. Build it (≈ 45 min).** Write code that produces the client's **WEEKLY KPI** block for
**week 46** (Sun 8 Nov to Sat 14 Nov 2026) and saves it as `output/weekly_kpi_2026-W46.csv`, with
exactly the layout of `client_sheet/weekly_kpi_template.csv`.

- It should run with **one command** and work for any other week.
- Do not trust the data blindly. Tell us what you found, what you decided, and why.
- Is there anything Laura should know, or tell the client, before this goes into their sheet?
  How would you communicate it, given that the layout cannot change?
- Use what you learn to answer Laura's question about week 45.

**1B. Make it run without us (≈ 15 min).** In **one page maximum** (bullets or a diagram are fine),
describe how you would run this in production, so that nobody fills these sheets by hand any more:
the daily RAW DATA tabs and the Monday KPI tab. Keep in mind that:

- The client owns the sheets and their Google Workspace. We can only ask for access.
- The client's analysts build their own formulas and charts on top of these tabs.
- Data arrives late or incomplete sometimes, and the client is strict about deadlines.

We are interested in how it is triggered, how it gets access, how you would know it is right before
the client sees it, what happens when something fails, and what happens when data arrives late.
There is no single right architecture.

### Part 2: Go deeper than the sheet (≈ 35 min)

The client wants us to bring **insight**, not only numbers. Our ambition is that the Spanish team
becomes the example the other European countries copy.

**2A. Answer the client (≈ 20 min).** Draft the reply to the Iberia retail lead's question about
XR sell-out at MegaElectro: **at most 200 words**, in English, ready to send. Add the evidence
behind it (a table, a chart or a query) separately. She is senior and busy: the first two lines
matter most.

**2B. From voice notes to something the client can trust (≈ 15 min).**

1. From the week 46 notes in `data/field_notes.csv`, pick the **5 things the client should hear
   about**: issue, stores, sentiment, evidence (note IDs) and a suggested action. Any method is
   fine: an LLM, rules, or reading them yourself. Tell us how you did it.
2. In **a few bullets**: how would you run this for ~300 notes a week, and how would you know the
   output is right? Think about quality, risks, cost, and how notes connect to the numbers.

**2C. Surprise us (optional).** One insight from this data that nobody asked for. Five lines
maximum, plus the evidence.

### Part 3: Be the reference (≈ 10 min)

In **150 words maximum**: if you joined us, what would you build or standardise in your first
90 days, and how would you make it reusable by the agencies running the same programme in other
European countries?

---

## 5. Getting started and what to send us

1. **Fork this repository** to your own GitHub account, clone your fork, and work only inside
   this folder (`data-engineer-analyst-test/`):

   ```bash
   git clone https://github.com/<your-github-username>/data_technical_tests.git
   cd data_technical_tests/data-engineer-analyst-test
   ```

2. Add to this folder:
   - `SOLUTION.md`, based on `SOLUTION_TEMPLATE.md`. This is the most important file.
   - Your code, with instructions to run it in one command.
   - `output/weekly_kpi_2026-W46.csv`.
   - Anything else that helps: a chart, a notebook, a prompt, a diagram.
3. Push everything to your fork and reply to the email thread where you received this test with
   your fork URL, by **Monday 23 November 2026, 09:00 CET**.

Your fork is public: do not commit credentials or personal data.

## 6. How we will review it

We read your work with these questions in mind:

- **Investigation:** did you find what is wrong in the data, and did you treat it sensibly?
- **Judgement:** are your decisions and assumptions reasonable, explicit and easy to challenge?
- **Design:** would your automation survive real life (late data, a client-owned sheet, failures)?
- **Insight:** did you separate data problems from real business problems, and say what to do next?
- **Communication:** could Laura and the client use what you wrote as it is?

Code quality matters, but it is not the main thing. A clear, correct script beats a clever one.

**Next step:** in the follow-up interview (about 60 minutes) you will walk us through your solution
for 10 minutes, and then we will make a small change to it together.

Good luck, and enjoy it!
