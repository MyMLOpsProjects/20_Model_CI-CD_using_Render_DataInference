import pandas as pd
from deepchecks.tabular import Dataset
import numpy as np
from deepchecks.tabular.checks import TrainTestDrift
np.Inf = np.inf # because deepcheck is not able to handle np.Inf, hence np.inf

ref = pd.read_csv('ref-data/ref_data.csv')
live = pd.read_csv('live_inputs.csv')

ref_ds = Dataset(ref)
live_ds = Dataset(live)

check = TrainTestDrift()
result = check.run(ref_ds, live_ds)

result.save_as_html('drift_report.html')
print(result)
