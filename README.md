# Airbnb Brussels: Price Driver Analysis

**Does an Airbnb listing's price in Brussels depend more on its location (commune) or its room type?**

This is my data analyst capstone project for the Syntra AB Data Analyst diploma. I built the full pipeline — from raw data to an interactive dashboard to answer one clear business question.

---

## 🎯 The question
Two listings can be priced very differently. Is that mostly about **where** the property is (the commune) or **what** it is (entire place vs. private room)? I built an end-to-end analysis to find out.

## 🛠️ Tools
Python (Pandas) · SQL · Power BI · Star schema · Inside Airbnb dataset

## 🔄 What I did

**1. Data cleaning (Python: Pandas)**
- Loaded real Brussels listing data from the Inside Airbnb dataset
- Parsed and cast the price fields, handled missing values
- Reduced the dataset to the relevant columns for the analysis

**2. Data modeling (SQL: star schema)**
- Built a central `listings` fact table
- Linked it to `neighbourhood` and `room_type` dimension tables
- Exported the model into Power BI

**3. Analysis**
- Compared median price by commune and by room type separately
- Built a commune × room-type matrix to disentangle which factor drives price more
- Choose median over mean to reduce the impact of extreme outliers

**4. Dashboard (Power BI)**
- Interactive Brussels map showing listing prices by location
- KPI cards, bar charts, slicers by commune and room type, and a matrix visual

## 📊 Dashboard preview
<img width="960" height="540" alt="image" src="https://github.com/user-attachments/assets/f35dc6a7-573b-4830-a5ab-add7b443bb0b" />


## 💡 Key finding
Location was the stronger driver of price overall, but room type dominated within the city centre.

## 🗣️ Defense
I presented and defended every analytical decision: granularity, median vs. mean, star schema design, and outlier handling  before an evaluation panel.

---

### 📂 Files in this repo
- `data_cleaning.ipynb` — Python/Pandas cleaning and preparation
- `schema.sql` — star schema definition and queries
- `dashboard.png` — Power BI dashboard screenshot

### 👤 About me
Junior Data Analyst with a background in marketing analytics, transitioning into data.
Power BI · SQL · Python · DAX | FR · EN · NL · AR
[LinkedIn](https://www.linkedin.com/in/fatima-zahra-b-349b45242)

