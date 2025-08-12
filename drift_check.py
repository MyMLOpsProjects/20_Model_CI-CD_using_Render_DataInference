import pandas as pd
from deepchecks.tabular.checks import TrainTestFeatureDrift
from deepchecks.tabular import Dataset

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
