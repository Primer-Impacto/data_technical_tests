# Data Engineer & Analyst — Technical test

Thanks for taking the time to do this. This is not a coding test. We want to see how you
**think**: how you look at messy data, what you decide matters, and how you explain it to people
who are not technical.

- **Time:** about **1.5 to 2 hours**. Please stop at 2 hours and tell us how long you spent. You
  will probably not finish everything, and that is fine. If time runs short, do **1A and 2A
  first**; for the rest, a few bullets are enough. We do not expect you to find every problem in
  the data.
- **Tools:** whatever you would use at work: Python, SQL (DuckDB is great for this), a notebook,
  a spreadsheet...
- **AI assistants:** allowed. You must be able to explain every number you submit, and please add
  two or three lines on how you used AI (see the template).
- **Questions:** nobody will be available over the weekend. If something is unclear, make a
  reasonable assumption, write it down and move on.
- **Data:** everything here is synthetic. The brand, retailers, stores and people are fictional.

---

## 1. Context

We are the data team of a field marketing agency. In Spain we run an in-store programme for
**Orbit**, a consumer-electronics brand with two product lines: **WEAR** (smartwatches and earbuds)
and **XR** (mixed-reality headsets).

Ten field reps visit 36 stores of 3 retailers (**MegaElectro**, **Galerías Prado** and
**Cultura+**). In each visit they check the display, run demos and train the store's sales staff
(**RSAs**, retail sales associates). They log visits in a field app and send short voice or text
notes about what they see.

The client is demanding and lives in Google Workspace. We report our KPIs in **their Google
Sheets**, and today we fill them in **by hand**. Their weeks run from **Sunday to Saturday**.

You do not need any cloud account for this test. A laptop is enough.

## 2. Monday morning

It is **Monday 16 November 2026, 9:00**. The exports were taken at 07:00. Laura, the project
manager, writes to you:

> Hi! Welcome to the project 🙂
>
> Every Monday I spend hours copying numbers into the client's **WEEKLY KPI** tab. It's killing us.
>
> Two more things:
>
> 1. The client says our numbers are wrong. For **week 45** they count **44** WEAR visits at
>    Galerías Prado and we reported **56**. I filtered the app export by the `app_week` column as
>    always, so I don't know what happened.
> 2. She also asked: *"Our dashboard shows XR sell-out at MegaElectro down about 50% this week.
>    What happened, and what are you doing about it?"*
>
> Can you help? 🙏

## 3. The data

| File | What it is |
|---|---|
| `client_sheet/README.md` | The client's rules for the WEEKLY KPI tab. **Read this first.** |
| `client_sheet/weekly_kpi_template.csv` | The block of rows to fill for week 46. |
| `client_sheet/weekly_kpi_2026-W45_as_submitted.csv` | What Laura filled in by hand last week (she added Cultura+'s sell-out on Wednesday, when their file arrived). |
| `data/field_visits.csv` | Field app export. One row per visit record. |
| `data/retailer_sellout.csv` | Weekly units sold per store and product, as sent by each retailer. |
| `data/store_master.csv` | Our stores, with each retailer's own store code. |
| `data/product_master.csv` | Products and their product line. |
| `data/field_notes.csv` | Field notes from the last 3 weeks (voice notes are transcribed automatically). |

A few column notes: `app_week` is the week label computed by the field app; `synced_at` is when
the visit reached our servers (reps are sometimes offline); `week_ending` is the Saturday that
closes the week; `loaded_at` is when we loaded each retailer file.

---

## 4. Your tasks

### Part 1: Automate the Monday sheet (≈ 50 min)

**1A. Build it (≈ 40 min).** Write code that produces the **WEEKLY KPI** block for **week 46**
(Sun 8 to Sat 14 November 2026) and saves it as `output/weekly_kpi_2026-W46.csv`, with the layout
of the template. It has 3 KPIs: **Visits**, **RSAs Trained** and **Sell-out Units**.

- It should run with **one command**.
- Do not trust the data blindly. Tell us what you found and what you decided.
- Tell us what Laura should know before this goes into the client's sheet.
- Answer Laura's question about week 45.

**1B. Make it run without us (≈ 10 min).** In a few bullets (half a page maximum): how would you
run this every Monday without anyone touching it? Keep in mind that the sheet belongs to the
client, and that data sometimes arrives late.

### Part 2: Go deeper than the sheet (≈ 30 min)

**2A. Answer the client (≈ 20 min).** Draft the reply to the XR question in **150 words
maximum**, in English, ready to send. Add the evidence behind it (a small table or chart).

**2B. Field notes (≈ 10 min).** From the week 46 notes in `data/field_notes.csv`, pick the
**3 things the client should hear about**, with the note IDs as evidence. Then, in two or three
bullets: if we received 300 notes a week, how would you make this reliable?

**2C. Optional.** One insight from the data that nobody asked for, in five lines maximum.

### Part 3: Be the reference (≈ 5 min)

Three bullets: what would you build first in your first 90 days, so that other countries could
reuse it?

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
   - Your code, with the command to run it.
   - `output/weekly_kpi_2026-W46.csv`.
3. Push everything to your fork and reply to the email thread where you received this test with
   your fork URL, by **Monday 23 November 2026, 09:00 CET**.

Your fork is public: do not commit credentials or personal data.

## 6. How we will review it

- Did you notice what is wrong in the data, and handle it sensibly?
- Are your decisions clear and easy to challenge?
- Did you separate data problems from real business problems?
- Could Laura and the client use what you wrote as it is?

A clear, simple script beats a clever one. In the follow-up interview (about 60 minutes) you will
walk us through your solution and we will make a small change to it together.

Good luck, and enjoy it!
