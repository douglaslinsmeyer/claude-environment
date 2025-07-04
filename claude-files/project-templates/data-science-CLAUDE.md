# Data Science Project Configuration

This Claude configuration is optimized for data science and machine learning projects.

## Project Context

### Tech Stack
- **Languages**: Python 3.9+, R (optional)
- **Core Libraries**: pandas, numpy, scikit-learn, matplotlib, seaborn
- **Deep Learning**: TensorFlow/PyTorch
- **Notebooks**: Jupyter Lab
- **Version Control**: Git with DVC for data versioning
- **Environments**: conda/poetry for dependency management
- **Cloud**: AWS SageMaker / Google Colab / Azure ML

### Project Structure
```
project-root/
├── data/
│   ├── raw/           # Original, immutable data
│   ├── interim/       # Intermediate transformed data
│   ├── processed/     # Final data for modeling
│   └── external/      # External data sources
├── notebooks/
│   ├── exploratory/   # EDA and experiments
│   └── reports/       # Polished notebooks for presentation
├── src/
│   ├── data/         # Data loading and processing
│   ├── features/     # Feature engineering
│   ├── models/       # Model definitions and training
│   ├── visualization/# Plotting utilities
│   └── utils/        # Helper functions
├── models/           # Trained model artifacts
├── reports/          # Generated analysis reports
│   └── figures/      # Generated graphics
├── tests/            # Unit and integration tests
└── config/           # Configuration files
```

## Development Standards

### Data Loading Pattern
```python
import pandas as pd
import numpy as np
from pathlib import Path
from typing import Tuple, Optional
import logging

logger = logging.getLogger(__name__)

class DataLoader:
    """Handles data loading with validation and caching."""
    
    def __init__(self, data_dir: Path = Path("data")):
        self.data_dir = data_dir
        self._cache = {}
    
    def load_dataset(
        self, 
        name: str, 
        stage: str = "processed",
        validate: bool = True
    ) -> pd.DataFrame:
        """Load dataset with optional validation."""
        cache_key = f"{stage}/{name}"
        
        if cache_key in self._cache:
            logger.info(f"Loading {name} from cache")
            return self._cache[cache_key]
        
        filepath = self.data_dir / stage / f"{name}.parquet"
        
        if not filepath.exists():
            raise FileNotFoundError(f"Dataset not found: {filepath}")
        
        df = pd.read_parquet(filepath)
        
        if validate:
            self._validate_dataframe(df, name)
        
        self._cache[cache_key] = df
        logger.info(f"Loaded {name}: shape={df.shape}")
        
        return df
    
    def _validate_dataframe(self, df: pd.DataFrame, name: str) -> None:
        """Basic validation of dataframe."""
        if df.empty:
            raise ValueError(f"Dataset {name} is empty")
        
        # Check for unexpected nulls in key columns
        # Add project-specific validation here
```

### Feature Engineering Pattern
```python
from sklearn.base import BaseEstimator, TransformerMixin
from typing import List, Union

class FeatureEngineer(BaseEstimator, TransformerMixin):
    """Custom feature engineering pipeline."""
    
    def __init__(self, 
                 numeric_features: List[str],
                 categorical_features: List[str],
                 target_encode: bool = False):
        self.numeric_features = numeric_features
        self.categorical_features = categorical_features
        self.target_encode = target_encode
        self.encoders_ = {}
        
    def fit(self, X: pd.DataFrame, y: Optional[pd.Series] = None):
        """Fit feature transformations."""
        # Fit scalers for numeric features
        self._fit_numeric(X[self.numeric_features])
        
        # Fit encoders for categorical features
        if self.target_encode and y is not None:
            self._fit_target_encoding(X[self.categorical_features], y)
        else:
            self._fit_label_encoding(X[self.categorical_features])
            
        return self
    
    def transform(self, X: pd.DataFrame) -> pd.DataFrame:
        """Apply feature transformations."""
        X_transformed = X.copy()
        
        # Transform numeric features
        X_transformed[self.numeric_features] = self._transform_numeric(
            X[self.numeric_features]
        )
        
        # Transform categorical features
        for col in self.categorical_features:
            X_transformed[col] = self.encoders_[col].transform(X[col])
        
        # Add engineered features
        X_transformed = self._add_engineered_features(X_transformed)
        
        return X_transformed
```

### Model Training Pattern
```python
from sklearn.model_selection import cross_val_score, StratifiedKFold
from sklearn.metrics import classification_report, confusion_matrix
import mlflow
import joblib

class ModelTrainer:
    """Handles model training with experiment tracking."""
    
    def __init__(self, model, experiment_name: str):
        self.model = model
        self.experiment_name = experiment_name
        mlflow.set_experiment(experiment_name)
        
    def train(self, 
              X_train: pd.DataFrame, 
              y_train: pd.Series,
              X_val: Optional[pd.DataFrame] = None,
              y_val: Optional[pd.Series] = None,
              cv_folds: int = 5) -> Dict:
        """Train model with cross-validation and tracking."""
        
        with mlflow.start_run():
            # Log parameters
            mlflow.log_params(self.model.get_params())
            
            # Cross-validation
            cv_scores = cross_val_score(
                self.model, X_train, y_train,
                cv=StratifiedKFold(n_splits=cv_folds),
                scoring='roc_auc'
            )
            
            mlflow.log_metric("cv_mean_auc", cv_scores.mean())
            mlflow.log_metric("cv_std_auc", cv_scores.std())
            
            # Fit on full training set
            self.model.fit(X_train, y_train)
            
            # Validation metrics if provided
            if X_val is not None and y_val is not None:
                val_score = self.model.score(X_val, y_val)
                val_pred = self.model.predict(X_val)
                
                mlflow.log_metric("val_accuracy", val_score)
                mlflow.log_text(
                    classification_report(y_val, val_pred),
                    "classification_report.txt"
                )
            
            # Save model
            mlflow.sklearn.log_model(self.model, "model")
            
            return {
                "cv_scores": cv_scores,
                "model": self.model,
                "run_id": mlflow.active_run().info.run_id
            }
```

## Claude Instructions

### When Doing EDA
1. Start with data quality assessment
2. Check distributions of all variables
3. Identify missing patterns
4. Look for outliers and anomalies
5. Examine correlations
6. Create informative visualizations
7. Document findings clearly
8. Generate data quality report

### When Building Models
1. Start simple, iterate complexity
2. Always use train/validation/test splits
3. Implement proper cross-validation
4. Track experiments with MLflow/similar
5. Check for data leakage
6. Validate assumptions
7. Interpret model results
8. Document model decisions

### When Writing Code
1. Use type hints throughout
2. Write docstrings for all functions
3. Follow PEP 8 style guide
4. Create modular, reusable functions
5. Handle edge cases gracefully
6. Log important steps
7. Write unit tests for utilities
8. Use meaningful variable names

## Notebook Standards

### Structure Template
```python
# %% [markdown]
# # Project Title
# 
# ## Objectives
# - Objective 1
# - Objective 2
# 
# ## Summary of Findings
# [Fill in after analysis]

# %% [markdown]
# ## 1. Setup and Imports

# %%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Project imports
import sys
sys.path.append('..')
from src.data import DataLoader
from src.features import FeatureEngineer

# Configuration
pd.set_option('display.max_columns', None)
plt.style.use('seaborn-v0_8-darkgrid')
sns.set_palette("husl")

# Set random seeds for reproducibility
np.random.seed(42)

# %% [markdown]
# ## 2. Load Data

# %%
loader = DataLoader()
df = loader.load_dataset("train", stage="processed")
print(f"Dataset shape: {df.shape}")
df.head()

# %% [markdown]
# ## 3. Exploratory Data Analysis
# [Continue with analysis sections...]
```

### Visualization Standards
```python
def create_distribution_plot(df: pd.DataFrame, 
                           column: str,
                           hue: Optional[str] = None) -> plt.Figure:
    """Create standardized distribution plot."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Histogram
    df[column].hist(bins=30, ax=ax1, alpha=0.7)
    ax1.set_title(f'Distribution of {column}')
    ax1.set_xlabel(column)
    ax1.set_ylabel('Frequency')
    
    # Box plot
    if hue:
        df.boxplot(column=column, by=hue, ax=ax2)
    else:
        df.boxplot(column=column, ax=ax2)
    ax2.set_title(f'Box Plot of {column}')
    
    plt.tight_layout()
    return fig

# Always save figures
fig = create_distribution_plot(df, 'feature_1')
fig.savefig('reports/figures/feature_1_distribution.png', dpi=300, bbox_inches='tight')
```

## Testing Requirements

### Unit Tests for Data Processing
```python
import pytest
import pandas as pd
from src.data import DataProcessor

class TestDataProcessor:
    
    @pytest.fixture
    def sample_data(self):
        """Create sample data for testing."""
        return pd.DataFrame({
            'numeric': [1, 2, 3, np.nan, 5],
            'categorical': ['A', 'B', 'A', 'B', None]
        })
    
    def test_handle_missing_values(self, sample_data):
        """Test missing value handling."""
        processor = DataProcessor()
        result = processor.handle_missing(sample_data)
        
        assert result['numeric'].isna().sum() == 0
        assert result['categorical'].isna().sum() == 0
        
    def test_scaling(self, sample_data):
        """Test feature scaling."""
        processor = DataProcessor()
        result = processor.scale_features(sample_data[['numeric']])
        
        assert result['numeric'].mean() == pytest.approx(0, abs=1e-10)
        assert result['numeric'].std() == pytest.approx(1, abs=1e-10)
```

### Model Validation Tests
```python
def test_no_data_leakage():
    """Ensure no data leakage in pipeline."""
    # Load data
    X_train, X_test, y_train, y_test = load_data()
    
    # Fit preprocessor only on training data
    preprocessor = Pipeline([...])
    preprocessor.fit(X_train)
    
    # Transform both sets
    X_train_transformed = preprocessor.transform(X_train)
    X_test_transformed = preprocessor.transform(X_test)
    
    # Check that test set wasn't used in fitting
    assert preprocessor.steps[0][1].statistics_ is not None
    # Add specific checks for your pipeline
```

## Performance Optimization

### Data Processing
```python
# Use vectorized operations
df['new_feature'] = df['col1'] * df['col2']  # Good
# Avoid iterrows()
for idx, row in df.iterrows():  # Bad
    df.loc[idx, 'new_feature'] = row['col1'] * row['col2']

# Use categorical dtypes for low-cardinality columns
df['category_col'] = df['category_col'].astype('category')

# Chunk large files
for chunk in pd.read_csv('large_file.csv', chunksize=10000):
    process_chunk(chunk)
```

### Model Training
```python
# Use joblib for parallel processing
from joblib import Parallel, delayed

results = Parallel(n_jobs=-1)(
    delayed(train_model)(params) 
    for params in param_grid
)

# Enable GPU when available
import torch
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model.to(device)
```

## Documentation Standards

### Project Documentation
```markdown
# Project Name

## Overview
Brief description of the project goals and approach.

## Data Sources
- Source 1: Description, update frequency, quality notes
- Source 2: Description, update frequency, quality notes

## Model Performance
| Model | Validation Score | Test Score | Notes |
|-------|-----------------|------------|-------|
| Baseline | 0.75 | 0.73 | Logistic Regression |
| Model 1 | 0.82 | 0.80 | Random Forest |

## Reproducibility
```bash
# Create environment
conda env create -f environment.yml

# Activate environment
conda activate project-name

# Run pipeline
python src/train_pipeline.py --config config/train_config.yaml
```
```

### Code Documentation
```python
def calculate_feature_importance(
    model: Union[RandomForestClassifier, XGBClassifier],
    feature_names: List[str],
    top_n: int = 20
) -> pd.DataFrame:
    """
    Calculate and return top feature importances.
    
    Parameters
    ----------
    model : Union[RandomForestClassifier, XGBClassifier]
        Trained model with feature_importances_ attribute
    feature_names : List[str]
        List of feature names corresponding to model features
    top_n : int, default=20
        Number of top features to return
        
    Returns
    -------
    pd.DataFrame
        DataFrame with features and their importance scores,
        sorted by importance descending
        
    Examples
    --------
    >>> rf = RandomForestClassifier().fit(X_train, y_train)
    >>> importance_df = calculate_feature_importance(rf, X_train.columns)
    >>> importance_df.head()
       feature  importance
    0  feature_A   0.152
    1  feature_B   0.134
    """
    importance_df = pd.DataFrame({
        'feature': feature_names,
        'importance': model.feature_importances_
    }).sort_values('importance', ascending=False).head(top_n)
    
    return importance_df
```

---

*This configuration is optimized for data science projects. Adjust based on your specific domain and requirements.*