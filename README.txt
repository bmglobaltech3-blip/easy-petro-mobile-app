EASY PETRO — MULTI-LOCATION LOCAL IMPLEMENTATION

Files:
- index.html — standalone, responsive implementation. Open directly in a browser.
- README.txt — this file.

Implemented:
- Compact KPI boxes for Sales, Gallons, Transactions, and Locations.
- Expand/collapse location rows using native HTML <details>/<summary>.
- Fuel Type Totals replaces Payment Mix.
- No external libraries, fonts, images, or network calls are required.
- Existing Easy Petro visual language is retained from the supplied mockup.

Data:
The displayed values are mockup/example values for implementation. Replace them
with live API/database values when wiring the production application.

Suggested integration points:
1. Replace KPI values in .compact-kpis.
2. Generate each <details> location block from your locations dataset.
3. Replace fuel total values in .fuel-totals.
4. Connect the date/location controls to your reporting endpoint.
5. Keep the native <details> interaction for lightweight expand/collapse behavior.
