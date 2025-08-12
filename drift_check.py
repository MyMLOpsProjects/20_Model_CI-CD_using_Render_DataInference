import pandas as pd
from deepchecks.tabular.checks import TrainTestFeatureDrift
from deepchecks.tabular import Dataset

# Load datasets
ref = pd.read_csv('ref-data/ref_data.csv')
live = pd.read_csv('live_inputs.csv')

# Create Dataset objects
train_ds = Dataset(ref.iloc[:,:-1])
test_ds = Dataset(live)

check = TrainTestFeatureDrift()
result = check.run(train_ds, test_ds)
# result.show()
result.save_as_html('drift_report.html',as_widget=False)
