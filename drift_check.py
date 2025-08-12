import pandas as pd
from deepchecks.tabular.checks import TrainTestFeatureDrift
from deepchecks.tabular import Dataset
import re

# Path to your live data
live_data_path = "live_inputs.csv"

# Read raw text and clean merge markers + extra headers
with open(live_data_path, "r") as f:
    lines = f.readlines()

clean_lines = []
seen_header = False
for line in lines:
    # Remove git conflict markers
    if line.startswith(("<<<<<<<", "=======", ">>>>>>>")):
        continue
    # Remove duplicate headers
    if re.match(r"^\s*sepal_length", line):
        if seen_header:
            continue
        seen_header = True
    clean_lines.append(line)

# Overwrite the file with cleaned content
with open(live_data_path, "w") as f:
    f.writelines(clean_lines) 

# Load datasets
ref = pd.read_csv('ref-data/ref_data.csv')
live = pd.read_csv('live_inputs.csv')


# Detect categorical features from ref dataset
categorical_features = ref.drop(columns=[ref.columns[-1]]).select_dtypes(include=['object', 'category']).columns.tolist()

# Create Dataset objects
train_ds = Dataset(ref.iloc[:,:-1],label=None,cat_features=categorical_features)
test_ds = Dataset(live,label=None,cat_features=categorical_features)

check = TrainTestFeatureDrift()
result = check.run(train_ds, test_ds)
# result.show()
result.save_as_html('drift_report.html',as_widget=False)
