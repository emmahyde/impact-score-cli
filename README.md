# impact-score-cli

Compute engineering impact scores from a CSV and compare users, with tunable weights.

- Default weights (multiples of 5): PRs 75%, Quality Reviews 5%, Cycle Time 15%, Reviews 5%
- Commands: `calc` (single user) and `compare` (two users)

## Install

RubyGems (once published):

```bash
gem install impact_score
```

Homebrew (HEAD for latest):

```bash
brew tap emmahyde/tap
brew install --HEAD emmahyde/tap/impact-score
```

## Usage

Compare two users:

```bash
impact-score compare dx_report.csv user_one user_two
```

Single user:

```bash
impact-score calc dx_report.csv user_one
```

Custom weights:

```bash
impact-score compare dx_report.csv user_one user_two --weights 50,40,5,5
```

CSV must include columns: `github_username`, `prs_per_week`, `avg_cycle_time_days`, `quality_reviews_per_week`, `reviews_per_week`.

## Releasing

- Set repo secret `RUBYGEMS_API_KEY`
- Tag a release: `git tag v0.1.0 && git push --tags`
- GitHub Actions will build and push to RubyGems
