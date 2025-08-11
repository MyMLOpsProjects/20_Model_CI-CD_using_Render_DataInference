import pandas as pd
from deepchecks.tabular import Dataset
from deepchecks.tabular.checks import FeatureDrift  # Use new class instead of deprecated

# Load datasets
ref = pd.read_csv('ref-data/ref_data.csv')
live = pd.read_csv('live_inputs.csv')

# Align columns
live = live[ref.columns]  # Reorder and drop extra columns

# Define label (if you have one)
label_col = None  # e.g., 'species'

ref_ds = Dataset(ref, label=label_col)
live_ds = Dataset(live, label=label_col)

# Run drift check
check = FeatureDrift()
result = check.run(train_dataset=ref_ds, test_dataset=live_ds)

# Save report
result.save_as_html('drift_report.html',as_widget=False)
print(result)
